import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/video/trim_duration_span_model.dart';
import '/shared/widgets/video/trimmer/video_editor_play_time_indicator.dart';
import '../../../utils/debounce.dart';
import '../video_editor_configurable.dart';
import 'video_editor_trim_handle.dart';
import 'video_editor_trim_thumbnail_bar.dart';

/// A widget representing the trim bar in the video editor.
///
/// This allows users to select and adjust the trim duration of the video.
class VideoEditorTrimBar extends StatefulWidget {
  /// Creates a [VideoEditorTrimBar] widget.
  const VideoEditorTrimBar({super.key});

  @override
  State<VideoEditorTrimBar> createState() => _VideoEditorTrimBarState();
}

class _VideoEditorTrimBarState extends State<VideoEditorTrimBar> {
  double _trimStart = 0;
  double _trimEnd = 1;
  double _scale = 1.0;
  double _baseScale = 1.0;
  final _scrollCtrl = ScrollController();
  final _trimTimeDebounce = Debounce(const Duration(milliseconds: 350));

  VideoEditorConfigurable get _player => VideoEditorConfigurable.of(context);

  int get _videoDuration => _player.controller.videoDuration.inMicroseconds;

  double get _minTrimPercentage => _player.configs.minTrimDuration.inMicroseconds / _videoDuration;

  bool _isUpdatingTrimBar = false;

  final _leftHandlerActiveNotifier = ValueNotifier(false);
  final _rightHandlerActiveNotifier = ValueNotifier(false);

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _trimTimeDebounce.dispose();
    _leftHandlerActiveNotifier.dispose();
    _rightHandlerActiveNotifier.dispose();
    super.dispose();
  }

  void _updateTrimSpan() {
    _player.controller.setTrimSpan(
      TrimDurationSpan(
        start: Duration(microseconds: (_trimStart * _videoDuration).toInt()),
        end: Duration(microseconds: (_trimEnd * _videoDuration).toInt()),
      ),
    );
    _player.showTrimTimeSpanNotifier.value = true;

    _isUpdatingTrimBar = true;
    setState(() {});
  }

  void _updateTrimStart(double value) {
    double minEnd = value + _minTrimPercentage;
    _trimStart = value;
    _trimEnd = max(_trimEnd, minEnd);

    if (_trimEnd > 1) {
      _trimStart = 1 - _minTrimPercentage;
      _trimEnd = 1;
    }

    _updateTrimSpan();
  }

  void _updateTrimEnd(double value) {
    double minStart = value - _minTrimPercentage;
    _trimEnd = value;
    _trimStart = min(_trimStart, minStart);

    if (_trimStart < 0) {
      _trimStart = 0;
      _trimEnd = _minTrimPercentage;
    }

    _updateTrimSpan();
  }

  void _updateScrollbar(double value) {
    _scrollCtrl.jumpTo(
      max(
        0,
        min(
          _scrollCtrl.position.maxScrollExtent,
          _scrollCtrl.offset - value,
        ),
      ),
    );
  }

  void _updateDragTrimBar(DragUpdateDetails details, double scaledWidth) {
    double factor = details.primaryDelta! / scaledWidth;
    double newValueStart = _trimStart + factor;
    double newValueEnd = _trimEnd + factor;

    if (newValueStart >= 0 && newValueEnd <= 1) {
      _updateTrimStart(newValueStart);
      _updateTrimEnd(newValueEnd);
    } else if (newValueEnd > 1 && _trimEnd != 1) {
      double diff = 1 - _trimEnd;
      _updateTrimStart(_trimStart + diff);
      _updateTrimEnd(_trimEnd + diff);
    } else if (newValueStart < 0 && _trimStart != 0) {
      _updateTrimStart(0);
      _updateTrimEnd(_trimEnd - _trimStart);
    } else {
      _updateScrollbar(details.delta.dx);
    }
  }

  void _triggerTrimSpanEnd() {
    _player.callbacks.onTrimSpanEnd?.call(
      TrimDurationSpan(
        start: Duration(microseconds: (_trimStart * _videoDuration).toInt()),
        end: Duration(microseconds: (_trimEnd * _videoDuration).toInt()),
      ),
    );
    _isUpdatingTrimBar = false;
    _trimTimeDebounce(() {
      _player.showTrimTimeSpanNotifier.value = false;
    });
    setState(() {});
  }

  void _handleMouseScroll(PointerSignalEvent event, double trimBarWidth) {
    if (event is! PointerScrollEvent) return;

    // Define zoom factor dynamically based on scroll speed
    double factor = 0.05 * (event.scrollDelta.dy / 50).abs().clamp(0.5, 2);

    double deltaY = event.scrollDelta.dy * (_player.configs.trimBarInvertMouseScroll ? -1 : 1);

    double startZoom = _scale;
    double newZoom = _scale;

    // Adjust zoom based on scroll direction
    if (deltaY > 0) {
      newZoom -= factor;
      newZoom = max(_player.configs.trimBarMinScale, newZoom);
    } else if (deltaY < 0) {
      newZoom += factor;
      newZoom = min(_player.configs.trimBarMaxScale, newZoom);
    }

    /// Get the local mouse position relative to the trim bar
    double mouseX = event.localPosition.dx;

    /// Get the total scrollable width
    double scaledWidth = trimBarWidth * startZoom;
    double newScaledWidth = trimBarWidth * newZoom;

    /// Convert mouse position to percentage in the current zoom level
    double mousePositionPercent = (mouseX + _scrollCtrl.offset) / scaledWidth;

    /// Compute the new scroll offset so that zooming happens around
    /// the mouse pointer
    double newScrollOffset = (mousePositionPercent * newScaledWidth) - mouseX;

    /// Ensure new scroll offset is within valid range
    double clampedScrollOffset = max(
      0,
      min(_scrollCtrl.position.maxScrollExtent, newScrollOffset),
    );

    setState(() {
      _scale = newZoom;
    });

    // Apply the new scroll position
    _scrollCtrl.jumpTo(clampedScrollOffset);
  }

  @override
  Widget build(BuildContext context) {
    if (_player.widgets.trimBar != null) return _player.widgets.trimBar!;

    var style = _player.style;
    var handlerButtonSize = style.trimBarHandlerButtonSize;

    return RepaintBoundary(
      child: LayoutBuilder(builder: (_, constraints) {
        double trimBarWidth = constraints.maxWidth - 16;
        double scaledWidth = trimBarWidth * _scale;
        double trimWidth = (_trimEnd - _trimStart) * scaledWidth;
        double offsetLeftHandler = _trimStart * scaledWidth;
        double offsetRightHandler = _trimEnd * scaledWidth - _player.style.trimBarHandlerWidth;

        /// Ensure there is always a small gap between the handlers
        if (offsetLeftHandler + _player.style.trimBarHandlerWidth + 4 >= offsetRightHandler) {
          offsetRightHandler = offsetLeftHandler + 4;
        }

        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF57CCAB),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: SingleChildScrollView(
            controller: _scrollCtrl,
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Listener(
              onPointerSignal: (ev) => _handleMouseScroll(ev, trimBarWidth),
              child: GestureDetector(
                onScaleStart: (ScaleStartDetails details) {
                  _baseScale = _scale;
                },
                onScaleUpdate: (ScaleUpdateDetails details) {
                  _scale = (_baseScale * details.scale).clamp(
                    _player.configs.trimBarMinScale,
                    _player.configs.trimBarMaxScale,
                  );
                  setState(() {});
                },
                child: Container(
                  clipBehavior: Clip.none,
                  width: scaledWidth,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      /// Trimmer background
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: handlerButtonSize,
                        ),
                        child: GestureDetector(
                          onHorizontalDragEnd: !isDesktop ? null : (_) => _triggerTrimSpanEnd(),
                          onHorizontalDragUpdate: !isDesktop
                              ? null
                              : (details) {
                                  _updateScrollbar(details.delta.dx);
                                },
                          child: const VideoEditorTrimThumbnailBar(),
                        ),
                      ),

                      /// Outside shadows
                      ..._buildOutsideShadows(
                        offsetLeftHandler,
                        offsetRightHandler,
                        scaledWidth,
                      ),

                      /// Trim body area
                      _buildTrimBodyArea(
                        offsetLeftHandler + handlerButtonSize,
                        offsetRightHandler - handlerButtonSize,
                        scaledWidth,
                        trimWidth,
                      ),

                      /// Trim handler left
                      _buildResizeHandler(true, offsetLeftHandler, scaledWidth),

                      /// Trim handler right
                      _buildResizeHandler(false, offsetRightHandler, scaledWidth),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  List<Widget> _buildOutsideShadows(
    double offsetLeftHandler,
    double offsetRightHandler,
    double scaledWidth,
  ) {
    var style = _player.style;
    double radiusWidth = style.trimBarHandlerRadius;
    var handlerButtonSize = style.trimBarHandlerButtonSize;
    return [
      Positioned(
        left: handlerButtonSize,
        width: offsetLeftHandler + radiusWidth,
        height: 80.h,
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              color: _player.style.trimBarOutsideAreaBackground,
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(_player.style.trimBarHandlerRadius),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: offsetRightHandler + handlerButtonSize,
        width: scaledWidth - offsetRightHandler - handlerButtonSize * 2,
        height: _player.style.trimBarHeight,
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              color: _player.style.trimBarOutsideAreaBackground,
              borderRadius: BorderRadius.horizontal(
                right: Radius.circular(_player.style.trimBarHandlerRadius),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildTrimBodyArea(
    double offsetLeftHandler,
    double offsetRightHandler,
    double scaledWidth,
    double trimWidth,
  ) {
    return Positioned(
      left: offsetLeftHandler,
      width: offsetRightHandler - offsetLeftHandler + _player.style.trimBarHandlerWidth,
      child: Stack(
        children: [
          /// Play-time indicator
          if (!_isUpdatingTrimBar) VideoEditorPlayTimeIndicator(areaWidth: trimWidth),

          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: (_) => _triggerTrimSpanEnd(),
            onHorizontalDragUpdate: (details) => _updateDragTrimBar(details, scaledWidth),
            child: MouseRegion(
              cursor: SystemMouseCursors.move,
              child: Container(
                width: trimWidth,
                height: 80.h,
                // height: _player.style.trimBarHeight,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF57CCAB),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(
                    _player.style.trimBarHandlerRadius,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResizeHandler(bool isLeft, double offset, double scaledWidth) {
    var notifier = isLeft ? _leftHandlerActiveNotifier : _rightHandlerActiveNotifier;
    return Positioned(
      left: offset,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (_) {
          notifier.value = true;
        },
        onHorizontalDragUpdate: (details) {
          if (isLeft) {
            double newValue = _trimStart + details.primaryDelta! / scaledWidth;
            _updateTrimStart(max(0, newValue));
          } else {
            double newValue = _trimEnd + details.primaryDelta! / scaledWidth;
            _updateTrimEnd(min(1, newValue));
          }
        },
        onHorizontalDragEnd: (_) {
          _triggerTrimSpanEnd();
          notifier.value = false;
        },
        child: ValueListenableBuilder(
            valueListenable: notifier,
            builder: (_, value, __) {
              return VideoEditorTrimHandle(
                isSelected: value,
                isLeft: isLeft,
              );
            }),
      ),
    );
  }
}
