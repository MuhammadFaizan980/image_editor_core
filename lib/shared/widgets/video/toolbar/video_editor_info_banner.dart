import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '/core/models/video/trim_duration_span_model.dart';
import '/shared/controllers/video_controller.dart';
import '/shared/extensions/duration_extension.dart';
import '/shared/widgets/video/video_editor_configurable.dart';

/// Displays an informational banner in the video editor.
///
/// This widget shows the selected trim duration and the estimated
/// file size based on the trimmed portion.
class VideoEditorInfoBanner extends StatelessWidget {
  /// Creates a [VideoEditorInfoBanner] widget.
  const VideoEditorInfoBanner({super.key});

  /// Calculate estimated file size based on trimmed duration and bitrate.
  int _estimatedFileSize(
    ProVideoController controller,
    TrimDurationSpan durationSpan,
  ) {
    final bitrate = controller.bitrate;
    int durationSec = durationSpan.duration.inSeconds;
    return (bitrate! * durationSec / 8.0).toInt();
  }

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);
    ProVideoController controller = player.controller;

    return ValueListenableBuilder(
      valueListenable: controller.trimDurationSpanNotifier,
      builder: (_, durationSpan, __) {
        // If a custom info banner widget is provided, use it
        if (player.configs.widgets.infoBanner != null) {
          return player.configs.widgets.infoBanner!(durationSpan);
        }

        return IgnorePointer(
          child: Container(
            padding: EdgeInsets.all(12.w),
            // padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black,
              // color: player.style.infoBannerBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'TOTAL DURATION:\n',
                    style: player.style.infoBannerTextStyle ??
                        TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.withOpacity(0.85),
                          // color: player.style.infoBannerTextColor ,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextSpan(
                    text: durationSpan.duration.toTimeString(),
                    style: player.style.infoBannerTextStyle ??
                        TextStyle(
                          fontSize: 18.sp,
                          height: 1.5,
                          color: const Color(0xFF57CCAB),
                          // color: player.style.infoBannerTextColor,
                        ),
                  ),
                  // if (player.configs.enableEstimatedFileSize && controller.bitrate != null) ...[
                  //   WidgetSpan(
                  //     alignment: PlaceholderAlignment.middle,
                  //     child: Container(
                  //       margin: const EdgeInsets.symmetric(horizontal: 7),
                  //       width: 3,
                  //       height: 3,
                  //       decoration: BoxDecoration(
                  //         color: player.style.infoBannerTextColor,
                  //         shape: BoxShape.circle,
                  //       ),
                  //     ),
                  //   ),
                  //   TextSpan(
                  //     text: _estimatedFileSize(controller, durationSpan).toBytesString(1),
                  //   ),
                  // ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
