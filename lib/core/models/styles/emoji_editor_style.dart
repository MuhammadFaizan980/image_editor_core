import 'package:flutter/widgets.dart';

import '/plugins/emoji_picker_flutter/emoji_picker_flutter.dart'
    show
        BottomActionBarConfig,
        CategoryViewConfig,
        DefaultEmojiTextStyle,
        EmojiPickerItem,
        EmojiViewConfig,
        SearchViewConfig,
        SkinToneConfig,
        ViewOrderConfig;
import '../../constants/editor_style_constants.dart';
import 'draggable_sheet_style.dart';
import 'types/style_types.dart';

export '/plugins/emoji_picker_flutter/emoji_picker_flutter.dart'
    show
        BottomActionBarConfig,
        CategoryViewConfig,
        DefaultEmojiTextStyle,
        ButtonMode,
        EmojiViewConfig,
        SearchViewConfig,
        SkinToneConfig;

/// The `EmojiEditorStyle` class defines the styles for the emoji editor in the
/// image editor.
///
/// Usage:
///
/// ```dart
/// EmojiEditorStyle emojiEditorStyle = EmojiEditorStyle();
/// ```
class EmojiEditorStyle {
  /// Creates an instance of the `EmojiEditorStyle` class with the specified
  /// style properties.
  ///
  /// Example:
  ///
  /// ```dart
  /// EmojiEditorStyle(
  ///   bottomActionBarConfig: BottomActionBarConfig(...),
  ///   skinToneConfig: SkinToneConfig(...),
  ///   ...
  /// )
  /// ```
  const EmojiEditorStyle({
    this.editorBoxConstraintsBuilder,
    this.backgroundColor = const Color(0xFF121B22),
    this.scrollToDuration = Duration.zero,
    this.themeDraggableSheet = const DraggableSheetStyle(
      minChildSize: 0.4,
      maxChildSize: 0.4,
      initialChildSize: 0.4,
    ),
    this.showDragHandle = true,
    this.bottomActionBarConfig = const BottomActionBarConfig(
      buttonIconColor: kImageEditorTextColor,
      backgroundColor: Color(0xFF121B22),
      buttonColor: Color(0xFF121B22),
      showBackspaceButton: false,
    ),
    this.skinToneConfig = const SkinToneConfig(
      enabled: true,
      dialogBackgroundColor: Color(0xFF252728),
      indicatorColor: Color(0xFF9E9E9E),
    ),
    this.searchViewConfig,
    this.categoryViewConfig,
    this.emojiViewConfig,
    this.textStyle = DefaultEmojiTextStyle,
    this.viewOrderConfig = const ViewOrderConfig(
      top: EmojiPickerItem.searchBar,
      middle: EmojiPickerItem.emojiView,
      bottom: EmojiPickerItem.categoryBar,
    ),
    this.categoryTitlePadding = const EdgeInsets.only(left: 10),
    this.categoryTitleStyle = const TextStyle(
      color: Color(0xFF86959C),
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
  });

  /// Configuration for the skin tone.
  ///
  /// This configures the appearance and behavior of the skin tone for emojis.
  final SkinToneConfig skinToneConfig;

  /// Configuration for the bottom action bar.
  ///
  /// This configures the appearance and behavior of the bottom action bar.
  final BottomActionBarConfig bottomActionBarConfig;

  /// Configuration for the search view.
  ///
  /// This configures the appearance and behavior of the search view.
  final SearchViewConfig? searchViewConfig;

  /// Configuration for the category view.
  ///
  /// This configures the appearance and behavior of the category view.
  final CategoryViewConfig? categoryViewConfig;

  /// Configuration for the emoji view.
  ///
  /// This configures the appearance and behavior of the emoji view.
  final EmojiViewConfig? emojiViewConfig;

  /// Custom emoji text style to apply to emoji characters in the grid.
  ///
  /// If you define a custom fontFamily or use GoogleFonts to set this property,
  /// be sure to set [checkPlatformCompatibility] to false. It will improve
  /// initialization performance and prevent technically supported glyphs from
  /// being filtered out.
  final TextStyle textStyle;

  /// View order config
  final ViewOrderConfig viewOrderConfig;

  /// Specifies whether a drag handle is shown on the bottom sheet.
  final bool showDragHandle;

  /// Configuration settings for the draggable bottom sheet component.
  final DraggableSheetStyle themeDraggableSheet;

  /// Padding for the category title.
  final EdgeInsets categoryTitlePadding;

  /// Text style for the category title.
  final TextStyle categoryTitleStyle;

  /// Background color for the emoji editor.
  final Color backgroundColor;

  /// Duration for the scroll animation.
  final Duration scrollToDuration;

  /// Use this to build custom [BoxConstraints] that will be applied to
  /// the modal bottom sheet displaying the [EmojiEditor].
  ///
  /// Otherwise, it falls back to
  /// [ProImageEditorConfigs.editorBoxConstraintsBuilder].
  final EditorBoxConstraintsBuilder? editorBoxConstraintsBuilder;

  /// Creates a copy of this `EmojiEditorStyle` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [EmojiEditorStyle] with some properties updated while keeping the
  /// others unchanged.
  EmojiEditorStyle copyWith({
    SkinToneConfig? skinToneConfig,
    BottomActionBarConfig? bottomActionBarConfig,
    SearchViewConfig? searchViewConfig,
    CategoryViewConfig? categoryViewConfig,
    EmojiViewConfig? emojiViewConfig,
    TextStyle? textStyle,
    ViewOrderConfig? viewOrderConfig,
    bool? showDragHandle,
    DraggableSheetStyle? themeDraggableSheet,
    EdgeInsets? categoryTitlePadding,
    TextStyle? categoryTitleStyle,
    Color? backgroundColor,
    Duration? scrollToDuration,
    EditorBoxConstraintsBuilder? editorBoxConstraintsBuilder,
  }) {
    return EmojiEditorStyle(
      skinToneConfig: skinToneConfig ?? this.skinToneConfig,
      bottomActionBarConfig:
          bottomActionBarConfig ?? this.bottomActionBarConfig,
      searchViewConfig: searchViewConfig ?? this.searchViewConfig,
      categoryViewConfig: categoryViewConfig ?? this.categoryViewConfig,
      emojiViewConfig: emojiViewConfig ?? this.emojiViewConfig,
      textStyle: textStyle ?? this.textStyle,
      viewOrderConfig: viewOrderConfig ?? this.viewOrderConfig,
      showDragHandle: showDragHandle ?? this.showDragHandle,
      themeDraggableSheet: themeDraggableSheet ?? this.themeDraggableSheet,
      categoryTitlePadding: categoryTitlePadding ?? this.categoryTitlePadding,
      categoryTitleStyle: categoryTitleStyle ?? this.categoryTitleStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      scrollToDuration: scrollToDuration ?? this.scrollToDuration,
      editorBoxConstraintsBuilder:
          editorBoxConstraintsBuilder ?? this.editorBoxConstraintsBuilder,
    );
  }
}
