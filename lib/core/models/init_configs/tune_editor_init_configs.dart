// Project imports:
import 'editor_init_configs.dart';

/// TODO: Remove deprecated callbacks

/// Configuration class for initializing the tune editor.
///
/// This class extends [EditorInitConfigs] and adds a parameter to determine
/// whether to return the image as a Uint8List when closing the editor.
class TuneEditorInitConfigs extends EditorInitConfigs {
  /// Creates a new instance of [TuneEditorInitConfigs].
  ///
  /// The [theme] parameter specifies the theme data for the editor.
  /// The [convertToUint8List] parameter determines whether to return the image
  /// as a Uint8List when closing the editor.
  /// The other parameters are inherited from [EditorInitConfigs].
  const TuneEditorInitConfigs({
    super.transformConfigs,
    super.configs,
    super.callbacks,
    super.mainImageSize,
    super.mainBodySize,
    super.layers,
    super.appliedFilters,
    super.appliedTuneAdjustments,
    super.appliedBlurFactor,
    @Deprecated('Use [callbacks.onCloseEditor] instead') super.onCloseEditor,
    @Deprecated('Use [callbacks.onImageEditingComplete] instead')
    super.onImageEditingComplete,
    @Deprecated('Use [callbacks.onImageEditingStarted] instead')
    super.onImageEditingStarted,
    super.convertToUint8List,
    required super.theme,
  });
}
