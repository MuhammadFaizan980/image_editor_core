import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/models/editor_configs/video_editor_configs.dart';
import '../../../extensions/duration_extension.dart';
import '../video_editor_configurable.dart';

/// Displays the trim duration information in the video editor.
///
/// This widget shows the start and end time of the selected trim span.
class VideoEditorTrimInfoWidget extends StatelessWidget {
  /// Creates a [VideoEditorTrimInfoWidget] widget.
  const VideoEditorTrimInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);
    return ValueListenableBuilder(
        valueListenable: player.showTrimTimeSpanNotifier,
        builder: (_, showTrimTimeSpan, __) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              final scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(animation);
              return ScaleTransition(
                scale: scaleAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: _buildTimeSpanText(player),
            // child: showTrimTimeSpan
            //     ? _buildTimeSpanText(player)
            //     : const SizedBox.shrink(),
          );
        });
  }

  Widget _buildTimeSpanText(VideoEditorConfigurable player) {
    return ValueListenableBuilder(
      valueListenable: player.controller.trimDurationSpanNotifier,
      builder: (_, value, __) {
        if (player.configs.widgets.trimDurationInfo != null) {
          return player.configs.widgets.trimDurationInfo!(value);
        }

        return IgnorePointer(
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.black,
                // color: player.style.trimDurationBackground,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: _buildTimeWidget(
                style: player.style,
                from: value.start.toTimeString(),
                to: value.end.toTimeString(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeWidget({required VideoEditorStyle? style, required String from, required String to}) {
    return Wrap(
      direction: Axis.horizontal,
      children: [
        Text(
          'From ',
          style: style?.trimDurationTextStyle ??
              TextStyle(
                fontSize: 14.sp,
                color: style?.trimDurationTextColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        _buildTimeWithBg(val: from, style: style),
        Text(
          ' to ',
          style: style?.trimDurationTextStyle ??
              TextStyle(
                fontSize: 14.sp,
                color: style?.trimDurationTextColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        _buildTimeWithBg(val: to, style: style),
      ],
    );
  }

  Widget _buildTimeWithBg({required String val, required VideoEditorStyle? style}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.35),
      ),
      child: Text(
        val,
        style: style?.trimDurationTextStyle ??
            TextStyle(
              fontSize: 14.sp,
              color: style?.trimDurationTextColor,
            ),
      ),
    );
  }
}
