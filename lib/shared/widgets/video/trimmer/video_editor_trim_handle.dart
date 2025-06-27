import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../video_editor_configurable.dart';

/// A handle for trimming video in the editor.
///
/// This widget represents the draggable trim handles on both ends of
/// the trim bar.
class VideoEditorTrimHandle extends StatelessWidget {
  /// Creates a [VideoEditorTrimHandle] widget.
  ///
  /// The [isLeft] parameter determines whether the handle is on the left
  /// or right side.
  const VideoEditorTrimHandle({
    super.key,
    required this.isLeft,
    required this.isSelected,
  });

  /// Determines if this is the left trim handle.
  final bool isLeft;

  /// Indicates if the handler is selected.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);
    var style = player.style;
    var handlerSize = style.trimBarHandlerButtonSize * (isSelected ? 1.2 : 1);
    return SizedBox(
      width: style.trimBarHandlerWidth,
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 14.w,
                height: 80.h,
                alignment: Alignment.center,
                // width: style.trimBarBorderWidth,
                // height: style.trimBarHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF57CCAB),
                  // color: style.trimBarBackground,
                  borderRadius: BorderRadius.horizontal(
                    left: isLeft ? Radius.circular(8.r) : Radius.zero,
                    right: isLeft ? Radius.zero : Radius.circular(8.r),
                  ),
                ),
                child: Icon(
                  isLeft ? Icons.chevron_left : Icons.chevron_right,
                  size: 18,
                  color: Colors.black,
                ),
              ),
              // Center(
              //   child: AnimatedContainer(
              //     duration: const Duration(milliseconds: 150),
              //     decoration: BoxDecoration(
              //       shape: BoxShape.circle,
              //       color: style.trimBarColor,
              //     ),
              //     width: handlerSize,
              //     height: handlerSize,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
