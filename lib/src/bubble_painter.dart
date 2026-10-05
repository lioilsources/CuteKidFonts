import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'palette.dart';
import 'roles.dart';

/// Lays out and paints the layered "bubble" text effect. Shared by the
/// [BubbleText] widget and the Flame rasteriser so both look identical.
///
/// Layers, bottom to top:
/// 1. extrusion — [KidRoleSpec.extrusionLayers] dark copies shifted down,
/// 2. outline — dark stroke,
/// 3. face — light → mid vertical gradient,
/// 4. gloss — translucent white, clipped to the upper part of each line.
///
/// Flat mode paints only the text, in `flatColor` (default: the palette's
/// dark colour).
class KidBubblePainter {
  KidBubblePainter({
    required String text,
    KidRole role = KidRole.title,
    KidPalette palette = KidPalette.sky,
    double? size,
    bool? flat,
    bool? gloss,
    double? strokeFactor,
    TextAlign align = TextAlign.center,
    TextDirection textDirection = TextDirection.ltr,
    TextScaler textScaler = TextScaler.noScaling,
    int? maxLines,
    Color? flatColor,
  }) : _text = text,
       _role = role,
       _palette = palette,
       _size = size,
       _flat = flat,
       _gloss = gloss,
       _strokeFactor = strokeFactor,
       _align = align,
       _textDirection = textDirection,
       _textScaler = textScaler,
       _maxLines = maxLines,
       _flatColor = flatColor;

  String _text;
  KidRole _role;
  KidPalette _palette;
  double? _size;
  bool? _flat;
  bool? _gloss;
  double? _strokeFactor;
  TextAlign _align;
  TextDirection _textDirection;
  TextScaler _textScaler;
  int? _maxLines;
  Color? _flatColor;

  String get text => _text;
  KidRole get role => _role;
  KidPalette get palette => _palette;

  /// Updates the configuration; returns true if anything changed (and the
  /// painter must be laid out again before painting).
  bool update({
    required String text,
    required KidRole role,
    required KidPalette palette,
    required double? size,
    required bool? flat,
    required bool? gloss,
    required double? strokeFactor,
    required TextAlign align,
    required TextDirection textDirection,
    required TextScaler textScaler,
    required int? maxLines,
    Color? flatColor,
  }) {
    if (text == _text &&
        role == _role &&
        palette == _palette &&
        size == _size &&
        flat == _flat &&
        gloss == _gloss &&
        strokeFactor == _strokeFactor &&
        align == _align &&
        textDirection == _textDirection &&
        textScaler == _textScaler &&
        maxLines == _maxLines &&
        flatColor == _flatColor) {
      return false;
    }
    _text = text;
    _role = role;
    _palette = palette;
    _size = size;
    _flat = flat;
    _gloss = gloss;
    _strokeFactor = strokeFactor;
    _align = align;
    _textDirection = textDirection;
    _textScaler = textScaler;
    _maxLines = maxLines;
    _flatColor = flatColor;
    _disposePainters();
    return true;
  }

  KidRoleSpec get spec => _role.spec;

  bool get isFlat => _flat ?? spec.flat;

  /// Face actually used: the role's, or the first fallback that covers the
  /// whole text (see [KidFonts.firstCovering]).
  String get fontFamily => KidFonts.firstCovering(spec.apply(_text), spec.family) ?? spec.family;

  /// Effective (scaled) font size.
  double get fontSize => _textScaler.scale(_size ?? spec.size);

  double get strokeWidth => isFlat ? 0 : fontSize * (_strokeFactor ?? spec.strokeFactor);

  double get _extrusionStep => fontSize * spec.extrusionFactor;

  int get _extrusionLayers => isFlat ? 0 : spec.extrusionLayers;

  /// Space around the glyph box taken by outline and extrusion.
  EdgeInsets get padding {
    final half = strokeWidth / 2;
    return EdgeInsets.fromLTRB(half, half, half, half + _extrusionLayers * _extrusionStep);
  }

  TextPainter? _base; // dark fill (flat text / extrusion)
  TextPainter? _stroke;
  TextPainter? _face;
  TextPainter? _glossPainter;
  double? _laidOutMaxWidth;
  double? _laidOutMinWidth;

  Size _layoutSize = Size.zero;

  /// Size including [padding]; valid after [layout].
  Size get size => _layoutSize;

  TextPainter _painter(Paint? foreground, {Color? color}) {
    // Sizes are pre-scaled, so painters themselves never scale again.
    final text = spec.apply(_text);
    return TextPainter(
      text: TextSpan(
        text: text,
        // One face for the whole string (e.g. Vietnamese title → Baloo 2).
        style: spec.textStyle(size: fontSize, color: color, foreground: foreground, forText: text),
      ),
      textAlign: _align,
      textDirection: _textDirection,
      maxLines: _maxLines,
      ellipsis: _maxLines == null ? null : '…',
    );
  }

  /// Lays out all layers. Cheap when called again with the same width.
  void layout({double minWidth = 0, double maxWidth = double.infinity}) {
    if (_base != null && _laidOutMaxWidth == maxWidth && _laidOutMinWidth == minWidth) return;
    _disposePainters();
    _laidOutMaxWidth = maxWidth;
    _laidOutMinWidth = minWidth;
    final pad = padding;
    final inner = math.max(0.0, maxWidth - pad.horizontal);
    final innerMin = math.max(0.0, math.min(minWidth - pad.horizontal, inner));

    final base = _base = _painter(null, color: isFlat ? (_flatColor ?? _palette.dark) : _palette.dark)
      ..layout(minWidth: innerMin, maxWidth: inner);
    _layoutSize = Size(base.width + pad.horizontal, base.height + pad.vertical);
    if (isFlat) return;

    _stroke = _painter(
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = _palette.dark,
    )..layout(minWidth: innerMin, maxWidth: inner);

    // Shader rect comes from the laid-out text box, not from constraints.
    final box = Offset.zero & Size(base.width, base.height);
    _face = _painter(
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_palette.light, _palette.mid],
          stops: const [0.25, 0.85],
        ).createShader(box),
    )..layout(minWidth: innerMin, maxWidth: inner);

    if (_gloss ?? spec.gloss) {
      _glossPainter =
          _painter(null, color: const Color(0x59FFFFFF)) // white @ 0.35
            ..layout(minWidth: innerMin, maxWidth: inner);
    }
  }

  /// Distance from the top of [size] to the first line's alphabetic baseline.
  double get baseline => padding.top + (_base?.computeDistanceToActualBaseline(TextBaseline.alphabetic) ?? 0);

  void paint(Canvas canvas, Offset offset) {
    final base = _base;
    assert(base != null, 'KidBubblePainter.layout() must be called first');
    if (base == null) return;
    final origin = offset + padding.topLeft;

    if (isFlat) {
      base.paint(canvas, origin);
      return;
    }

    for (var i = _extrusionLayers; i >= 1; i--) {
      final o = origin + Offset(0, i * _extrusionStep);
      _stroke!.paint(canvas, o);
      base.paint(canvas, o);
    }
    _stroke!.paint(canvas, origin);

    // The gradient shader lives in text-box coordinates.
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    _face!.paint(canvas, Offset.zero);

    final gloss = _glossPainter;
    if (gloss != null) {
      canvas.save();
      final clip = Path();
      for (final line in gloss.computeLineMetrics()) {
        // Top 40 % of the glyph body: from cap height down towards x-height.
        final top = line.baseline - line.ascent;
        final bottom = line.baseline - fontSize * 0.42;
        clip.addRect(
          Rect.fromLTRB(line.left - strokeWidth, top, line.left + line.width + strokeWidth, bottom),
        );
      }
      canvas.clipPath(clip);
      gloss.paint(canvas, Offset.zero);
      canvas.restore();
    }
    canvas.restore();
  }

  void _disposePainters() {
    _base?.dispose();
    _stroke?.dispose();
    _face?.dispose();
    _glossPainter?.dispose();
    _base = _stroke = _face = _glossPainter = null;
    _laidOutMaxWidth = _laidOutMinWidth = null;
  }

  void dispose() => _disposePainters();
}
