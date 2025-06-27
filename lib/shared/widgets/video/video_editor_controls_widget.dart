import 'package:flutter/material.dart';

import '/core/models/editor_configs/video_editor_configs.dart';
import '/shared/widgets/video/toolbar/video_editor_trim_info_widget.dart';
import 'toolbar/video_editor_info_banner.dart';
import 'trimmer/video_editor_trim_bar.dart';
import 'video_editor_configurable.dart';
import 'video_editor_state_widget.dart';

/// A widget that manages the video editor's control elements.
///
/// This includes the trim bar, mute button, info banner, and state indicator.
class VideoEditorControlsWidget extends StatelessWidget {
  /// Creates a [VideoEditorControlsWidget] widget.
  const VideoEditorControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final player = VideoEditorConfigurable.of(context);
    final style = player.style;

    bool isAudioSupported = player.configs.isAudioSupported;
    bool alignTop = player.configs.controlsPosition == VideoEditorControlPosition.top;
    bool enablePlayButton = player.configs.enablePlayButton;
    final toolbarPadding = player.style.toolbarPadding;

    return Stack(
      children: [
        player.widgets.headerToolbar ??
            Column(
              spacing: 10,
              // verticalDirection: alignTop ? VerticalDirection.down : VerticalDirection.up,
              mainAxisAlignment: alignTop ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                Padding(
                  padding: toolbarPadding.copyWith(top: 0),
                  child: LayoutBuilder(builder: (_, constraints) {
                    return Row(
                      spacing: constraints.maxWidth < 340 ? 6 : 12,
                      children: [
                        const VideoEditorInfoBanner(),
                        if (constraints.maxWidth >= 300) VideoEditorTrimInfoWidget(),
                        // if (enablePlayButton) const VideoEditorPlayButton(),
                        // if (isAudioSupported) const VideoEditorMuteButton(),
                      ],
                    );
                  }),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: toolbarPadding.top,
                    left: toolbarPadding.left - style.trimBarHandlerButtonSize,
                    right: toolbarPadding.right - style.trimBarHandlerButtonSize,
                  ),
                  child: const VideoEditorTrimBar(),
                ),
              ],
            ),
        const VideoEditorStateWidget(),
        // if (!enablePlayButton) const VideoEditorStateWidget(),
      ],
    );
  }
}
