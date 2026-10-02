import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'bubble_painter.dart';
import 'palette.dart';
import 'roles.dart';
import 'theme.dart';

/// Chubby pastel text with outline, extrusion, gradient face and gloss.
///
/// ```dart
/// BubbleText('Ahoj!', role: KidRole.title, palette: KidPalette.mint)
/// ```
///
/// Flat roles ([KidRole.body], [KidRole.dialog], [KidRole.number]) render as
/// plain dark text; any role can be forced flat with `flat: true`.
class BubbleText extends StatelessWidget {
  const BubbleText(
    this.text, {
    super.key,
    this.role = KidRole.title,
    this.palette,
    this.size,
    this.flat,
    this.gloss,
    this.strokeFactor,
    this.align = TextAlign.center,
    this.maxLines,
    this.textScaler,
  });

  final String text;
  final KidRole role;

  /// Defaults to [KidThemeData.palette].
  final KidPalette? palette;

  /// Font size override; defaults to the role's size × [KidThemeData.sizeScale].
  final double? size;

  /// Disable outline/extrusion/gloss. Defaults to the role's setting.
  final bool? flat;
  final bool? gloss;

  /// Outline width as a fraction of font size.
  final double? strokeFactor;
  final TextAlign align;
  final int? maxLines;

  /// Defaults to `MediaQuery.textScalerOf(context)`.
  final TextScaler? textScaler;

  @override
  Widget build(BuildContext context) {
    final theme = KidTheme.of(context);
    final pal = palette ?? theme.palette;
    return RepaintBoundary(
      child: _BubbleLeaf(
        text: text,
        role: role,
        palette: pal,
        flatColor: theme.flatColor(pal),
        size: theme.sizeOf(role, size),
        flat: flat,
        gloss: gloss,
        strokeFactor: strokeFactor,
        align: align,
        maxLines: maxLines,
        textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
        textScaler: textScaler ?? MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling,
      ),
    );
  }
}

class _BubbleLeaf extends LeafRenderObjectWidget {
  const _BubbleLeaf({
    required this.text,
    required this.role,
    required this.palette,
    required this.size,
    required this.flat,
    required this.gloss,
    required this.strokeFactor,
    required this.align,
    required this.maxLines,
    required this.textDirection,
    required this.textScaler,
    required this.flatColor,
  });

  final String text;
  final KidRole role;
  final KidPalette palette;
  final double size;
  final bool? flat;
  final bool? gloss;
  final double? strokeFactor;
  final TextAlign align;
  final int? maxLines;
  final TextDirection textDirection;
  final TextScaler textScaler;
  final Color flatColor;

  KidBubblePainter _createPainter() => KidBubblePainter(
    text: text,
    role: role,
    palette: palette,
    size: size,
    flat: flat,
    gloss: gloss,
    strokeFactor: strokeFactor,
    align: align,
    maxLines: maxLines,
    textDirection: textDirection,
    textScaler: textScaler,
    flatColor: flatColor,
  );

  @override
  RenderBubbleText createRenderObject(BuildContext context) => RenderBubbleText(_createPainter());

  @override
  void updateRenderObject(BuildContext context, RenderBubbleText renderObject) {
    final changed = renderObject.painter.update(
      text: text,
      role: role,
      palette: palette,
      size: size,
      flat: flat,
      gloss: gloss,
      strokeFactor: strokeFactor,
      align: align,
      maxLines: maxLines,
      textDirection: textDirection,
      textScaler: textScaler,
      flatColor: flatColor,
    );
    if (changed) renderObject.markNeedsLayout();
  }
}

/// Render object behind [BubbleText]; owns one [KidBubblePainter].
class RenderBubbleText extends RenderBox {
  RenderBubbleText(this.painter);

  final KidBubblePainter painter;

  @override
  void markNeedsLayout() {
    super.markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  void _layout(BoxConstraints constraints) {
    painter.layout(
      // A tight/min width lets TextPainter apply TextAlign within it.
      minWidth: constraints.minWidth,
      maxWidth: constraints.maxWidth,
    );
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    painter.layout();
    return painter.size.width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    painter.layout();
    return painter.size.width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    painter.layout(maxWidth: width);
    return painter.size.height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) => computeMinIntrinsicHeight(width);

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    _layout(constraints);
    return constraints.constrain(painter.size);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) => painter.baseline;

  @override
  void performLayout() {
    _layout(constraints);
    size = constraints.constrain(painter.size);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    // Re-layout in case an intrinsic query used a different width.
    _layout(constraints);
    painter.paint(context.canvas, offset);
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..isSemanticBoundary = true
      ..label = painter.spec.apply(painter.text)
      ..textDirection = TextDirection.ltr;
  }

  @override
  void dispose() {
    painter.dispose();
    super.dispose();
  }
}
