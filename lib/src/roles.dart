import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';

import 'palette.dart';

/// Font family names, already prefixed for use from any app that depends on
/// this package.
abstract final class KidFonts {
  static const package = 'cute_kid_fonts';

  /// Chubby rounded display face (titles, keys).
  static const dynaPuff = 'packages/$package/DynaPuff';

  /// Rounded text face (body, dialog, numbers — has tabular figures).
  static const baloo2 = 'packages/$package/Baloo2';

  /// True italic display face.
  static const grandstanderItalic = 'packages/$package/GrandstanderItalic';

  /// Fallback for anything the primary faces miss.
  static const nunito = 'packages/$package/Nunito';

  static const fallback = <String>[nunito];
}

/// Typographic roles shared by all apps.
enum KidRole { title, titleItalic, upper, lower, body, dialog, key, number }

/// Text transformation applied before layout.
enum KidCase { none, upper, lower }

/// Everything a role needs to be rendered: face, weight, size, spacing and
/// the default bubble effect parameters.
@immutable
class KidRoleSpec {
  const KidRoleSpec({
    required this.family,
    required this.weight,
    required this.size,
    this.italic = false,
    this.letterSpacing = 0,
    this.height = 1.15,
    this.textCase = KidCase.none,
    this.flat = false,
    this.strokeFactor = 0.14,
    this.extrusionLayers = 3,
    this.extrusionFactor = 0.035,
    this.gloss = true,
    this.features = const [],
  });

  final String family;
  final double weight;
  final double size;
  final bool italic;

  /// Letter spacing in logical px at [size]; scaled with the actual size.
  final double letterSpacing;
  final double height;
  final KidCase textCase;

  /// Flat roles render as plain dark text without outline/extrusion.
  final bool flat;

  /// Outline width as a fraction of font size.
  final double strokeFactor;

  /// Number of stacked copies forming the 3D extrusion.
  final int extrusionLayers;

  /// Vertical offset of each extrusion copy as a fraction of font size.
  final double extrusionFactor;
  final bool gloss;
  final List<FontFeature> features;

  String apply(String text) => switch (textCase) {
    KidCase.none => text,
    KidCase.upper => text.toUpperCase(),
    KidCase.lower => text.toLowerCase(),
  };

  /// Plain [TextStyle] for this role (no paint/colour set unless given).
  TextStyle textStyle({double? size, Color? color, Paint? foreground}) {
    final s = size ?? this.size;
    return TextStyle(
      fontFamily: family,
      fontFamilyFallback: KidFonts.fallback,
      fontSize: s,
      fontWeight: _nearestWeight(weight),
      fontVariations: [FontVariation.weight(weight)],
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      letterSpacing: letterSpacing * s / this.size,
      height: height,
      fontFeatures: features,
      color: foreground == null ? color : null,
      foreground: foreground,
    );
  }
}

FontWeight _nearestWeight(double w) {
  final i = ((w / 100).round() - 1).clamp(0, 8);
  return FontWeight.values[i];
}

const _title = KidRoleSpec(family: KidFonts.dynaPuff, weight: 700, size: 48, letterSpacing: 0.5);

extension KidRoleX on KidRole {
  KidRoleSpec get spec => switch (this) {
    KidRole.title => _title,
    KidRole.titleItalic => const KidRoleSpec(
      family: KidFonts.grandstanderItalic,
      weight: 900,
      size: 48,
      italic: true,
      letterSpacing: 0.5,
    ),
    KidRole.upper => const KidRoleSpec(
      family: KidFonts.dynaPuff,
      weight: 700,
      size: 48,
      letterSpacing: 1.5,
      textCase: KidCase.upper,
    ),
    KidRole.lower => const KidRoleSpec(
      family: KidFonts.dynaPuff,
      weight: 700,
      size: 48,
      textCase: KidCase.lower,
    ),
    KidRole.body => const KidRoleSpec(
      family: KidFonts.baloo2,
      weight: 400,
      size: 18,
      height: 1.35,
      flat: true,
      gloss: false,
    ),
    KidRole.dialog => const KidRoleSpec(
      family: KidFonts.baloo2,
      weight: 600,
      size: 20,
      height: 1.3,
      flat: true,
      gloss: false,
    ),
    KidRole.key => const KidRoleSpec(
      family: KidFonts.dynaPuff,
      weight: 700,
      size: 36,
      height: 1.0,
      strokeFactor: 0.10,
      extrusionLayers: 2,
    ),
    KidRole.number => const KidRoleSpec(
      family: KidFonts.baloo2,
      weight: 800,
      size: 32,
      height: 1.0,
      flat: true,
      gloss: false,
      features: [FontFeature.tabularFigures()],
    ),
  };

  /// Plain [TextStyle] in the palette's dark colour, e.g. for `Text()`.
  TextStyle style({KidPalette palette = KidPalette.sky, double? size, Color? color}) =>
      spec.textStyle(size: size, color: color ?? palette.dark);
}
