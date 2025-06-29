// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

const double kDefaultInnerRadius = 8.0;
const double kDefaultOuterRadius = 10.0;

/// Gets the foreground color based on [backgroundColor]
Color? foregroundColor(Color? backgroundColor) {
  return backgroundColor == null || backgroundColor.a == 0
      ? null
      : backgroundColor.computeLuminance() >= 0.5
          ? Colors.black
          : Colors.white;
}

/// Creates a paragraph with rounded background.
///
/// See also:
///
///  * [RichText], which this widget uses to render text.
///  * [TextPainter], which is used to calculate the line metrics.
///  * [TextStyle], used to customize the text look and feel.
///  * [RoundedBackgroundTextPainter], the painter used to draw the background.
class RoundedBackgroundText extends StatelessWidget {
  /// Creates a rounded background text with a single style.
  RoundedBackgroundText(
    String text, {
    super.key,
    TextStyle? style,
    this.textDirection,
    this.textAlign,
    this.backgroundColor,
    this.textWidthBasis,
    this.ellipsis,
    this.locale,
    this.strutStyle,
    this.textScaler = TextScaler.noScaling,
    this.maxLines,
    this.textHeightBehavior,
    this.innerRadius = kDefaultInnerRadius,
    this.outerRadius = kDefaultOuterRadius,
    this.onHitTestResult,
    this.enableHorizontalHitBox = true,
  }) : text = TextSpan(text: text, style: style);

  /// Creates a rounded background text based on an [InlineSpan], that can have
  /// multiple styles
  const RoundedBackgroundText.rich({
    super.key,
    required this.text,
    this.textDirection,
    this.backgroundColor,
    this.textAlign,
    this.textWidthBasis,
    this.ellipsis,
    this.locale,
    this.strutStyle,
    this.textScaler = TextScaler.noScaling,
    this.maxLines,
    this.textHeightBehavior,
    this.innerRadius = kDefaultInnerRadius,
    this.outerRadius = kDefaultOuterRadius,
    this.onHitTestResult,
    this.enableHorizontalHitBox = true,
  })  : assert(innerRadius >= 0.0 && innerRadius <= 20.0),
        assert(outerRadius >= 0.0 && outerRadius <= 20.0);

  final Function(bool hasHit)? onHitTestResult;

  /// The text to display in this widget.
  final InlineSpan text;

  /// The directionality of the text.
  final TextDirection? textDirection;

  /// {@template rounded_background_text.background_color}
  /// The text background color.
  ///
  /// If null, a transparent color will be used.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// {@macro flutter.painting.textPainter.textWidthBasis}
  final TextWidthBasis? textWidthBasis;

  /// An optional maximum number of lines for the text to span, wrapping if
  /// necessary.
  /// If the text exceeds the given number of lines, it will be truncated.
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  final int? maxLines;

  /// {@macro flutter.dart:ui.textHeightBehavior}
  final TextHeightBehavior? textHeightBehavior;

  /// The string used to ellipsize overflowing text.
  final String? ellipsis;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale.
  ///
  /// It's rarely necessary to set this property. By default its value
  /// is inherited from the enclosing app with
  /// `Localizations.localeOf(context)`.
  ///
  /// See [RenderParagraph.locale] for more information.
  final Locale? locale;

  /// {@macro flutter.painting.textPainter.strutStyle}
  final StrutStyle? strutStyle;

  /// The number of font pixels for each logical pixel.
  ///
  /// For example, if the text scale factor is 1.5, text will be 50% larger than
  /// the specified font size.
  final TextScaler textScaler;

  /// {@template rounded_background_text.innerRadius}
  /// The radius of the inner corners.
  ///
  /// The radius is dynamically calculated based on the line height and the
  /// provided factor.
  ///
  /// Defaults to 8.0
  /// {@endtemplate}
  final double innerRadius;

  /// {@template rounded_background_text.outerRadius}
  /// The radius of the inner corners.
  ///
  /// The radius is dynamically calculated based on the line height and the
  /// provided factor.
  ///
  /// Defaults to 10.0
  /// {@endtemplate}
  final double outerRadius;

  final bool enableHorizontalHitBox;

  double getLineHeight(TextStyle style) {
    final span = TextSpan(text: 'X', style: style);
    final painter = TextPainter(
      text: span,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.preferredLineHeight;
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    final style = text.style ?? defaultTextStyle.style;

    final painter = TextPainter(
      text: TextSpan(
        children: [text],
        style: TextStyle(
          color: foregroundColor(backgroundColor),
          leadingDistribution: TextLeadingDistribution.proportional,
          fontSize: style.fontSize,
        ).merge(style),
      ),
      textDirection:
          textDirection ?? Directionality.maybeOf(context) ?? TextDirection.ltr,
      maxLines: maxLines ?? defaultTextStyle.maxLines,
      textAlign: textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start,
      textWidthBasis: textWidthBasis ?? defaultTextStyle.textWidthBasis,
      textScaler: textScaler,
      strutStyle: strutStyle,
      locale: locale,
      textHeightBehavior:
          textHeightBehavior ?? defaultTextStyle.textHeightBehavior,
      ellipsis: ellipsis,
    );

    double height = getLineHeight(style);
    const horizontalPaddingFactor = 0.3;
    double horizontalSpace =
        enableHorizontalHitBox ? height * horizontalPaddingFactor : 0;
    double bottomSpace = height * 0.0875;

    return LayoutBuilder(builder: (context, constraints) {
      painter.layout(
        maxWidth: constraints.maxWidth,
        minWidth: constraints.minWidth,
      );
      return CustomPaint(
        isComplex: true,
        foregroundPainter: RoundedBackgroundTextPainter(
          backgroundColor: backgroundColor ?? Colors.transparent,
          text: painter,
          innerRadius: innerRadius,
          outerRadius: outerRadius,
          onHitTestResult: onHitTestResult,
          horizontalPadding: horizontalSpace,
        ),
        child: SizedBox(
          width: painter.width.clamp(0, constraints.maxWidth) +
              horizontalSpace * 2,
          height: painter.height.clamp(0, constraints.maxHeight) + bottomSpace,
        ),
      );
    });
  }
}

class RoundedBackgroundTextPainter extends CustomPainter {
  const RoundedBackgroundTextPainter({
    required this.backgroundColor,
    required this.text,
    required this.innerRadius,
    required this.outerRadius,
    required this.onHitTestResult,
    required this.horizontalPadding,
  });

  final Function(bool hasHit)? onHitTestResult;

  final Color backgroundColor;
  final TextPainter text;

  final double horizontalPadding;
  final double innerRadius;
  final double outerRadius;

  /// Compute the lines used by [RoundedBackgroundTextPainter].
  ///
  /// The text [painter] must have been already laid out:
  /// ```dart
  /// final painter = TextPainter(
  ///  text: const TextSpan(text: testText),
  /// );
  /// painter.layout();
  /// final lines = RoundedBackgroundTextPainter.computeLines(painter);
  /// ```
  static List<List<LineMetricsHelper>> computeLines(TextPainter painter) {
    final metrics = painter.computeLineMetrics();

    final helpers = metrics.map((lineMetric) {
      return LineMetricsHelper(lineMetric, metrics.length);
    });

    final List<List<LineMetricsHelper>> lineInfos = [[]];

    for (final line in helpers) {
      if (line.isEmpty) {
        lineInfos.add([]);
      } else {
        lineInfos.last.add(line);
      }
    }

    return lineInfos;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final lineInfos = computeLines(text);

    for (final lineInfo in lineInfos) {
      paintBackground(canvas, lineInfo);
    }

    text.paint(canvas, Offset(horizontalPadding, 0));
  }

  RRect _getRRect(LineMetricsHelper info) {
    return RRect.fromLTRBR(
      info.x + horizontalPadding,
      info.y,
      info.fullWidth + horizontalPadding,
      info.fullHeight,
      Radius.circular(info.outerRadius(outerRadius)),
    );
  }

  void paintBackground(Canvas canvas, List<LineMetricsHelper> lineInfo) {
    if (lineInfo.isEmpty) return;
    if (lineInfo.length == 1) {
      final info = lineInfo.first;
      if (!info.isEmpty) {
        canvas.drawRRect(_getRRect(info), Paint()..color = backgroundColor);
      }
      return;
    }

    // This ensures the normalization will be done for all lines in the
    // paragraph and not only for the next one
    for (final info in lineInfo) {
      normalize(lineInfo.elementAtOrNull(lineInfo.indexOf(info) + 1), info);
    }

    final path = Path();
    final firstInfo = lineInfo.elementAt(0);
    final lastInfo = lineInfo.elementAt(lineInfo.length - 1);

    path.moveTo(
        (firstInfo.x + horizontalPadding) + firstInfo.outerRadius(outerRadius),
        firstInfo.y);

    LineMetricsHelper previous = firstInfo;

    for (final info in lineInfo) {
      final next = lineInfo.elementAtOrNull(lineInfo.indexOf(info) + 1);

      final outerRadius = info.outerRadius(this.outerRadius);
      final innerRadius = info.innerRadius(this.innerRadius);

      void drawTopLeftCorner(LineMetricsHelper info) {
        final x = info.x + horizontalPadding;
        final previousX = previous.x + horizontalPadding;

        final localOuterRadius = previous == info
            ? outerRadius
            : (previousX - x).clamp(0, outerRadius);
        final controlPoint = Offset(x, info.y);
        final endPoint = Offset(x, info.y + localOuterRadius);

        path
          ..lineTo(x + localOuterRadius, info.y)
          ..quadraticBezierTo(
              controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
      }

      void drawBottomLeftCorner(LineMetricsHelper info) {
        final x = info.x + horizontalPadding;
        path.lineTo(x, info.fullHeight - outerRadius);

        final iControlPoint = Offset(x, info.fullHeight);
        final iEndPoint = Offset(x + outerRadius, info.fullHeight);

        path.quadraticBezierTo(
            iControlPoint.dx, iControlPoint.dy, iEndPoint.dx, iEndPoint.dy);
      }

      void drawInnerCorner(LineMetricsHelper info, [bool toLeft = true]) {
        final x = info.x + horizontalPadding;
        if (toLeft) {
          final formattedHeight =
              info.fullHeight - info._innerLinePadding.bottom;

          final nextX = next!.x + horizontalPadding;
          final localInnerRadius = (x - nextX).clamp(0, innerRadius);
          path.lineTo(x, info.fullHeight - localInnerRadius);
          final iControlPoint = Offset(x, formattedHeight);
          final iEndPoint = Offset(x - localInnerRadius, formattedHeight);

          path.quadraticBezierTo(
              iControlPoint.dx, iControlPoint.dy, iEndPoint.dx, iEndPoint.dy);
        } else {
          final formattedY = next!.y + info._innerLinePadding.bottom;

          final nextX = next.x + horizontalPadding;
          final localInnerRadius = (nextX - x).clamp(0, innerRadius);
          path.lineTo(nextX - localInnerRadius, formattedY);
          final iControlPoint = Offset(nextX, formattedY);
          final iEndPoint = Offset(nextX, formattedY + localInnerRadius);

          path.quadraticBezierTo(
              iControlPoint.dx, iControlPoint.dy, iEndPoint.dx, iEndPoint.dy);
        }
      }

      if (next != null) {
        final x = info.x + horizontalPadding;
        final nextX = next.x + horizontalPadding;
        final previousX = previous.x + horizontalPadding;

        // If it's the first line OR the previous line is bigger than the
        // current one, draw the top left corner
        if (info == firstInfo || previousX > x) {
          drawTopLeftCorner(info);
        }
        if (x > nextX) {
          // If the current one is less than the next, draw the inner corner
          drawInnerCorner(info);
          // drawBottomLeftCorner(info);
        } else
        // If the next one is more to the right, draw the bottom left
        if (x < nextX) {
          // Draw bottom right corner
          drawBottomLeftCorner(info);

          // Otherwise draw the inverse inner corner
          drawInnerCorner(info, false);
        }
      } else {
        // If it's in the last one, draw the top and bottom corners
        drawTopLeftCorner(info);
        drawBottomLeftCorner(info);
      }

      previous = info;
    }

    // Draw the last line only to the half of it
    path.lineTo(
        (lastInfo.fullWidth + horizontalPadding) / 2, lastInfo.fullHeight);

    final reversedInfo = lineInfo.reversed.toList(growable: false);
    previous = reversedInfo.first;

    // !Goes horizontal and up
    for (final info in reversedInfo) {
      final next = reversedInfo.elementAtOrNull(reversedInfo.indexOf(info) + 1);

      final outerRadius = info.outerRadius(this.outerRadius);
      final innerRadius = info.innerRadius(this.innerRadius);

      void drawTopRightCorner(
        LineMetricsHelper info, [
        double? factor,
      ]) {
        final fullWidth = info.fullWidth + horizontalPadding;
        factor ??= outerRadius;
        final controlPoint = Offset(fullWidth, info.y);
        final endPoint = Offset(fullWidth - factor, info.y);

        path
          ..lineTo(fullWidth, info.y + factor)
          ..quadraticBezierTo(
              controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
      }

      void drawBottomRightCorner(LineMetricsHelper info) {
        final fullWidth = info.fullWidth + horizontalPadding;
        path.lineTo(fullWidth - outerRadius, info.fullHeight);

        final iControlPoint = Offset(fullWidth, info.fullHeight);
        final iEndPoint = Offset(fullWidth, info.fullHeight - outerRadius);

        path.quadraticBezierTo(
            iControlPoint.dx, iControlPoint.dy, iEndPoint.dx, iEndPoint.dy);
      }

      void drawInnerCorner(LineMetricsHelper info, [bool toRight = true]) {
        final fullWidth = info.fullWidth + horizontalPadding;
        // To left
        if (!toRight) {
          final formattedHeight =
              info.fullHeight - info._innerLinePadding.bottom;
          path.lineTo(fullWidth + innerRadius, formattedHeight);

          final controlPoint = Offset(fullWidth, formattedHeight);
          final endPoint = Offset(fullWidth, formattedHeight - innerRadius);

          path.quadraticBezierTo(
              controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
        } else {
          final formattedY = info.y + info._innerLinePadding.bottom;
          path.lineTo(fullWidth, formattedY + innerRadius);

          final controlPoint = Offset(fullWidth, formattedY);
          final endPoint = Offset(fullWidth + innerRadius, formattedY);

          path.quadraticBezierTo(
              controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
        }
      }

      final fullWidth = info.fullWidth + horizontalPadding;
      final previousFullWidth = previous.fullWidth + horizontalPadding;
      if (next != null) {
        if (info == previous) {
          // if it's the last line
          drawBottomRightCorner(info);
        } else if (fullWidth < previousFullWidth) {
          // if the current one is less than the previous one
          drawTopRightCorner(previous);
          drawInnerCorner(info, false);
          // drawInnerCorner(info);
        } else if (fullWidth > previousFullWidth) {
          // if the current one is bigger than the previous one
          drawInnerCorner(previous, true);
          drawBottomRightCorner(info);
        } else {
          // if the current one is equal to the previous one, ignore it
        }
      } else {
        // if it's the first line
        if (previousFullWidth < fullWidth) {
          // if the current one is bigger than the previous one
          drawInnerCorner(previous);
          drawBottomRightCorner(info);
        } else if (previousFullWidth > fullWidth) {
          drawTopRightCorner(previous);
          drawInnerCorner(info, false);
        }
        drawTopRightCorner(info);
      }

      previous = info;
    }

    // First line horizontal
    path
      ..lineTo((firstInfo.fullWidth + horizontalPadding) / 2, firstInfo.y)
      ..close();
    canvas.drawPath(path, Paint()..color = backgroundColor);
  }

  @override
  bool shouldRepaint(covariant RoundedBackgroundTextPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.text.width != text.width ||
        oldDelegate.text.height != text.height ||
        oldDelegate.text.ellipsis != text.ellipsis ||
        oldDelegate.text.plainText != text.plainText ||
        oldDelegate.text.textAlign != text.textAlign ||
        oldDelegate.text.preferredLineHeight != text.preferredLineHeight ||
        oldDelegate.innerRadius != innerRadius ||
        oldDelegate.outerRadius != outerRadius;
  }

  // Normalize the width of the next element based on the difference between
  // the width of the current element and the next one. This is responsible
  // to not let the next element go too little away from the current one
  void normalize(LineMetricsHelper? next, LineMetricsHelper info) {
    // There is no need to normalize the last element, since it'll have already
    // been normalized
    if (next != null) {
      final outerRadius = info.outerRadius(this.outerRadius);
      var difference = () {
        final width = (info.rawWidth - next.rawWidth);
        return width.roundToDouble();
      }();

      // If the difference is negative, it means that the next element is a
      // little bigger than the current one. The current one takes the
      //dimensions of the next one
      if (difference.isNegative) {
        difference = -difference;
      }
      final differenceBigger = difference > outerRadius;
      if (!differenceBigger) {
        info
          .._overridenX = next.x + horizontalPadding
          .._overridenWidth = next.fullWidth;
      }
      // If the difference is positive, it means that the current element is a
      // little bigger than the next one. The next one takes the dimensions of
      // the current one
      else {
        final differenceBigger = difference > outerRadius;
        if (!differenceBigger) {
          next
            .._overridenX = info.x + horizontalPadding
            .._overridenWidth = info.fullWidth;
        }
      }
    }
  }

  @override
  bool? hitTest(Offset position) {
    // Retrieve the line information
    final lineInfos = computeLines(text);

    // Check each line
    for (final lineInfo in lineInfos) {
      for (final info in lineInfo) {
        // Construct the rounded rectangle for this line
        final rRect = _getRRect(info);

        // Check if the position is within this rectangle
        if (rRect.contains(position)) {
          onHitTestResult?.call(true);
          return true;
        }
      }
    }

    // If the position was not within any line's bounding box
    onHitTestResult?.call(false);
    return false;
  }
}

/// A helper class that holds important information about a single line metrics.
/// This is used to calculate the position of the line in the paragraph.
class LineMetricsHelper {
  /// Creates a new line metrics helper
  LineMetricsHelper(this.metrics, this.length);

  /// The original line metrics, which stores the measurements and statistics of
  /// a single line in the paragraph.
  final LineMetrics metrics;

  /// The amount of lines in the text.
  ///
  /// See also:
  ///
  ///  * [isLast], which uses this property to check the amount of lines
  final int length;

  /// The override width of the line
  ///
  /// This allows another line to affect the width of this line based on the
  /// difference between the two. If the difference is minimal, the width may
  /// be the same
  double? _overridenWidth;

  /// The overriden x of the line
  ///
  /// This allows another line to affect the x of this line based on the
  /// difference between the two. If the difference is minimal, the x may
  /// be the same
  double? _overridenX;

  /// Whether this line has no content
  bool get isEmpty => rawWidth == 0.0;

  /// Whether this line is the first line in the paragraph
  bool get isFirst => metrics.lineNumber == 0;

  /// Whether this line is the last line in the paragraph
  bool get isLast => metrics.lineNumber == length - 1;

  static const _horizontalPaddingFactor = 0.3;
  late final EdgeInsets _firstLinePadding = EdgeInsets.only(
    left: height * _horizontalPaddingFactor,
    right: height * _horizontalPaddingFactor,
    top: height * 0.3,
    bottom: height * 0.175 / 2,
  );
  late final EdgeInsets _innerLinePadding = EdgeInsets.only(
    left: height * _horizontalPaddingFactor,
    right: height * _horizontalPaddingFactor,
    top: 0.0,
    bottom: height * 0.175 / 2,
  );
  late final EdgeInsets _lastLinePadding = EdgeInsets.only(
    left: height * _horizontalPaddingFactor,
    right: height * _horizontalPaddingFactor,
    top: 0.0,
    bottom: height * 0.175 / 2,
  );

  /// Dynamically calculate the outer factor based on the provided [outerRadius]
  double outerRadius(double outerRadius) {
    return (height * outerRadius) / 35;
  }

  /// Dynamically calculate the inner factor based on the provided [innerRadius]
  double innerRadius(double innerRadius) {
    return (height * innerRadius) / 35;
  }

  /// The x position of the line
  double get x {
    if (_overridenX != null) return _overridenX!;
    final result = metrics.left;

    if (isFirst) {
      return (result - _firstLinePadding.left).roundToDouble();
    } else if (isLast) {
      return (result - _lastLinePadding.left).roundToDouble();
    } else {
      return (result - _innerLinePadding.left).roundToDouble();
    }
  }

  /// The y position of the line
  double get y {
    final y = metrics.baseline - metrics.ascent;
    if (isFirst) {
      return y;
    } else if (isLast) {
      return y + (_lastLinePadding.top / 2);
    } else {
      return y - _innerLinePadding.top;
    }
  }

  /// The entire height of the line, including its [y] and padding
  double get fullHeight {
    final result = y + height;

    if (isLast) {
      return result + _lastLinePadding.bottom;
    } else {
      return result + _innerLinePadding.bottom;
    }
  }

  /// The raw height of the line, without any additional padding
  double get height => metrics.height;

  /// The raw width of the line, without any additional padding
  double get rawWidth => metrics.width;

  /// The entire width of the line, including the padding
  double get width {
    if (metrics.lineNumber == 0) {
      return (rawWidth + _firstLinePadding.right).roundToDouble();
    } else if (isLast) {
      return (rawWidth + _lastLinePadding.right).roundToDouble();
    } else {
      return (rawWidth + _innerLinePadding.right).roundToDouble();
    }
  }

  /// The entire width of the line, including the padding and its [x]
  double get fullWidth {
    if (_overridenWidth != null) return _overridenWidth!;
    final result = x + width;

    if (!isEmpty) {
      // The padding is subtracted on [x]. Add it back in here
      if (isFirst) {
        return (result + _firstLinePadding.left).roundToDouble();
      } else if (isLast) {
        return (result + _lastLinePadding.left).roundToDouble();
      } else {
        return (result + _innerLinePadding.left).roundToDouble();
      }
    }
    return (x + rawWidth).roundToDouble();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LineMetricsHelper &&
        other.metrics == metrics &&
        other.length == length &&
        other._overridenWidth == _overridenWidth &&
        other._overridenX == _overridenX;
  }

  @override
  int get hashCode {
    return metrics.hashCode ^
        length.hashCode ^
        _overridenWidth.hashCode ^
        _overridenX.hashCode;
  }

  @override
  String toString() {
    return 'LineMetricsHelper(x: $x, y: $y, w: $fullWidth, h: $fullHeight)';
  }
}
