// Project imports:
import '/core/models/editor_callbacks/standalone_editor_callbacks.dart';

/// A class representing callbacks for the emoji editor.
class EmojiEditorCallbacks extends StandaloneEditorCallbacks {
  /// Creates a new instance of [EmojiEditorCallbacks].
  const EmojiEditorCallbacks({
    super.onInit,
    super.onAfterViewInit,
  });

  /// Creates a copy with modified editor callbacks.
  EmojiEditorCallbacks copyWith({
    Function()? onInit,
    Function()? onAfterViewInit,
  }) {
    return EmojiEditorCallbacks(
      onInit: onInit ?? this.onInit,
      onAfterViewInit: onAfterViewInit ?? this.onAfterViewInit,
    );
  }
}
