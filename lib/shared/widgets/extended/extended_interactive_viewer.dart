import 'package:flutter/widgets.dart';
import '/core/models/editor_configs/utils/zoom_configs.dart';

/// A widget that provides interactive viewing capabilities with zoom and pan
/// functionality.
///
/// The [ExtendedInteractiveViewer] wraps a given child widget and allows users
/// to interact with it through zooming and panning.
/// ```
class ExtendedInteractiveViewer extends StatefulWidget {
  /// Creates an [ExtendedInteractiveViewer] with the given parameters.
  const ExtendedInteractiveViewer({
    super.key,
    required this.child,
    this.enableInteraction = true,
    required this.zoomConfigs,
    required this.onInteractionStart,
    required this.onInteractionUpdate,
    required this.onInteractionEnd,
    this.onMatrix4Change,
    this.initialMatrix4,
  });

  /// Configuration options that control zoom behavior and limits.
  ///
  /// Provides settings such as whether zoom is enabled, min/max scale factors,
  /// double-tap zoom behavior, and boundary constraints.
  final ZoomConfigs zoomConfigs;

  /// The child widget to be displayed and interacted with.
  final Widget child;

  /// Indicates whether user interactions such as panning and zooming are
  /// enabled.
  ///
  /// Default value is `true`.
  final bool enableInteraction;

  /// Called when the user ends a pan or scale gesture on the widget.
  ///
  /// At the time this is called, the [TransformationController] will have
  /// already been updated to reflect the change caused by the interaction,
  /// though a pan may cause an inertia animation after this is called as well.
  ///
  /// {@template flutter.widgets.InteractiveViewer.onInteractionEnd}
  /// Will be called even if the interaction is disabled with [panEnabled] or
  /// [scaleEnabled] for both touch gestures and mouse interactions.
  ///
  /// A [GestureDetector] wrapping the InteractiveViewer will not respond to
  /// [GestureDetector.onScaleStart], [GestureDetector.onScaleUpdate], and
  /// [GestureDetector.onScaleEnd]. Use [onInteractionStart],
  /// [onInteractionUpdate], and [onInteractionEnd] to respond to those
  /// gestures.
  /// {@endtemplate}
  ///
  /// See also:
  ///
  ///  * [onInteractionStart], which handles the start of the same interaction.
  ///  * [onInteractionUpdate], which handles an update to the same interaction.
  final GestureScaleEndCallback? onInteractionEnd;

  /// Called when the user begins a pan or scale gesture on the widget.
  ///
  /// At the time this is called, the [TransformationController] will not have
  /// changed due to this interaction.
  ///
  /// {@macro flutter.widgets.InteractiveViewer.onInteractionEnd}
  ///
  /// The coordinates provided in the details' `focalPoint` and
  /// `localFocalPoint` are normal Flutter event coordinates, not
  /// InteractiveViewer scene coordinates. See
  /// [TransformationController.toScene] for how to convert these coordinates to
  /// scene coordinates relative to the child.
  ///
  /// See also:
  ///
  ///  * [onInteractionUpdate], which handles an update to the same interaction.
  ///  * [onInteractionEnd], which handles the end of the same interaction.
  final GestureScaleStartCallback? onInteractionStart;

  /// Called when the user updates a pan or scale gesture on the widget.
  ///
  /// At the time this is called, the [TransformationController] will have
  /// already been updated to reflect the change caused by the interaction, if
  /// the interaction caused the matrix to change.
  ///
  /// {@macro flutter.widgets.InteractiveViewer.onInteractionEnd}
  ///
  /// The coordinates provided in the details' `focalPoint` and
  /// `localFocalPoint` are normal Flutter event coordinates, not
  /// InteractiveViewer scene coordinates. See
  /// [TransformationController.toScene] for how to convert these coordinates to
  /// scene coordinates relative to the child.
  ///
  /// See also:
  ///
  ///  * [onInteractionStart], which handles the start of the same interaction.
  ///  * [onInteractionEnd], which handles the end of the same interaction.
  final GestureScaleUpdateCallback? onInteractionUpdate;

  /// Called when the Matrix4 value changes.
  final Function(Matrix4 value)? onMatrix4Change;

  /// The initial Matrix4 value.
  final Matrix4? initialMatrix4;

  @override
  State<ExtendedInteractiveViewer> createState() =>
      ExtendedInteractiveViewerState();
}

/// The state for [ExtendedInteractiveViewer], managing the interactivity state.
class ExtendedInteractiveViewerState extends State<ExtendedInteractiveViewer>
    with TickerProviderStateMixin {
  late TransformationController _transformCtrl;
  late final AnimationController _animationCtrl;
  late bool _enableInteraction;

  @override
  void initState() {
    super.initState();
    _transformCtrl = TransformationController(widget.initialMatrix4)
      ..addListener(() {
        widget.onMatrix4Change?.call(_transformCtrl.value);
      });
    _animationCtrl = AnimationController(
      vsync: this,
      duration: widget.zoomConfigs.doubleTapZoomDuration,
    );
    _enableInteraction = widget.enableInteraction;
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    _animationCtrl.dispose();
    super.dispose();
  }

  /// Gets the current transform matrix.
  Matrix4 get transformMatrix4 => _transformCtrl.value;

  /// Sets the transform matrix.
  set transformMatrix4(Matrix4 value) => _transformCtrl.value = value;

  /// Sets the interaction state to the given value and updates the UI
  /// accordingly.
  void setEnableInteraction(bool value) {
    if (_enableInteraction != value) {
      _enableInteraction = value;
      setState(() {});
    }
  }

  /// Reset the transformations
  void reset() {
    _transformCtrl.value = Matrix4.identity();
  }

  /// Instantly sets the zoom transformation to a specific [offset] and [scale].
  ///
  /// If [offset] is null, [Offset.zero] is used. If [scale] is null, 1.0 is
  /// used.
  /// This method bypasses animation and immediately updates the view.
  void zoomTo({Offset? offset, double? scale}) {
    final effectiveOffset = offset ?? Offset.zero;
    final effectiveScale = scale ?? 1.0;

    _transformCtrl.value = Matrix4.identity()
      ..translate(effectiveOffset.dx, effectiveOffset.dy)
      ..scale(effectiveScale);
  }

  /// Animates zooming to a specific [offset] and [scale] over [duration].
  ///
  /// The transition uses the provided [curve] to control easing. If [offset]
  /// or [scale] is null, they default to [Offset.zero] and 1.0 respectively.
  Future<void> animateZoomToPoint({
    Offset? offset,
    double? scale,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    if (_animationCtrl.isAnimating) return;
    final effectiveOffset = offset ?? Offset.zero;
    final effectiveScale = scale ?? 1.0;

    final targetMatrix = Matrix4.identity()
      ..translate(effectiveOffset.dx, effectiveOffset.dy)
      ..scale(effectiveScale);

    final tween = Matrix4Tween(
      begin: _transformCtrl.value,
      end: targetMatrix,
    );

    _animationCtrl
      ..duration = duration
      ..reset();

    final animation = tween.animate(CurvedAnimation(
      parent: _animationCtrl,
      curve: curve,
    ));

    void listener() {
      _transformCtrl.value = animation.value;
    }

    _animationCtrl.addListener(listener);
    await _animationCtrl.forward();
    _animationCtrl.removeListener(listener);
  }

  /// Quickly toggles zoom in or out based on the current [scaleFactor].
  ///
  /// If the view is currently zoomed in (scale > 1), this will reset to the
  /// default scale and position. Otherwise, it will zoom in to [scale] centered
  /// around the given [offset]. Uses animation with optional [duration] and
  /// [curve].
  Future<void> quickZoomTo(
    Offset offset,
    double scale, {
    Duration? duration,
    Curve? curve,
  }) async {
    if (!_enableInteraction) return;
    if (scaleFactor > 1) {
      await animateZoomToPoint(offset: Offset.zero, scale: 1);
    } else {
      await animateZoomToPoint(offset: -offset, scale: scale);
    }
  }

  /// The factor by which the current transformation is scaled.
  /// Returns the maximum scale factor applied on any axis.
  double get scaleFactor {
    return _transformCtrl.value.getMaxScaleOnAxis();
  }

  /// The current translation offset applied to the transformation.
  /// Returns an [Offset] representing the translation values on the x and y
  /// axes.
  Offset get offset {
    return Offset(
      _transformCtrl.value.getTranslation().x,
      _transformCtrl.value.getTranslation().y,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.zoomConfigs.enableZoom) return widget.child;

    /// If we disable the interaction we need to return it as Transform widget
    /// that the InteractiveViewer will not absorb the scale events.
    if (!_enableInteraction) {
      return Transform(
        transform: _transformCtrl.value,
        child: widget.child,
      );
    }
    return InteractiveViewer(
      boundaryMargin: widget.zoomConfigs.boundaryMargin,
      transformationController: _transformCtrl,
      panEnabled: _enableInteraction,
      scaleEnabled: _enableInteraction,
      minScale: widget.zoomConfigs.editorMinScale,
      maxScale: widget.zoomConfigs.editorMaxScale,
      onInteractionStart: widget.onInteractionStart,
      onInteractionUpdate: widget.onInteractionUpdate,
      onInteractionEnd: widget.onInteractionEnd,
      child: widget.child,
    );
  }
}
