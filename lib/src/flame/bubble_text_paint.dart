import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../palette.dart';
import '../roles.dart';
import 'rasterize.dart';

/// Flame [TextPaint] factory for dynamic text (score, timer…).
///
/// Flame's `TextPaint` draws a single paint, so this is a cheap
/// approximation: face colour + a dark drop shadow as extrusion. For the full
/// bubble effect on static text use [KidBubbleComponent].
abstract final class KidTextPaint {
  ///
  /// [onDark]: flat roles use the palette's light colour instead of dark.
  static TextPaint of(KidRole role, KidPalette palette, {double? size, bool onDark = false}) {
    final spec = role.spec;
    final s = size ?? spec.size;
    if (spec.flat) {
      return TextPaint(
        style: spec.textStyle(size: s, color: onDark ? palette.light : palette.dark),
      );
    }
    return TextPaint(
      style: spec
          .textStyle(size: s, color: palette.mid)
          .copyWith(
            shadows: [
              Shadow(color: palette.dark, offset: Offset(0, s * spec.extrusionFactor * spec.extrusionLayers)),
              Shadow(color: palette.dark, blurRadius: s * 0.02),
            ],
          ),
    );
  }

  /// Flame-side text with [KidRoleSpec.textCase] applied.
  static String text(KidRole role, String text) => role.spec.apply(text);
}

/// Static bubble text ("LEVEL 3", "GAME OVER") as a sprite rasterised once
/// and cached in [KidRasterCache].
class KidBubbleComponent extends SpriteComponent {
  KidBubbleComponent({
    required String text,
    KidRole role = KidRole.title,
    KidPalette palette = KidPalette.sky,
    this.fontSize,
    this.flat,
    this.pixelRatio = 2.0,
    KidRasterCache? cache,
    super.position,
    super.anchor,
    super.priority,
    super.scale,
    super.angle,
    super.key,
  }) : _text = text,
       _role = role,
       _palette = palette,
       cache = cache ?? KidRasterCache.instance;

  String _text;
  KidRole _role;
  KidPalette _palette;
  final double? fontSize;
  final bool? flat;

  /// Raster resolution relative to logical size; raise for zoomed cameras.
  final double pixelRatio;
  final KidRasterCache cache;

  String get text => _text;
  set text(String value) {
    if (value == _text) return;
    _text = value;
    _refresh();
  }

  KidPalette get palette => _palette;
  set palette(KidPalette value) {
    if (value == _palette) return;
    _palette = value;
    _refresh();
  }

  KidRole get role => _role;
  set role(KidRole value) {
    if (value == _role) return;
    _role = value;
    _refresh();
  }

  int _generation = 0;

  @override
  FutureOr<void> onLoad() => _refresh();

  Future<void> _refresh() async {
    final gen = ++_generation;
    final raster = await cache.get(
      _text,
      role: _role,
      palette: _palette,
      size: fontSize,
      flat: flat,
      pixelRatio: pixelRatio,
    );
    if (gen != _generation) return; // a newer text won the race
    sprite = Sprite(raster.image);
    size = Vector2(raster.size.width, raster.size.height);
  }
}
