import 'package:flutter/material.dart';

import 'roles.dart';

/// Material entry point: maps a [TextTheme] onto the kid faces.
///
/// ```dart
/// final base = ThemeData(colorSchemeSeed: …);
/// ThemeData(colorSchemeSeed: …, textTheme: KidTextTheme.apply(base.textTheme));
/// ```
///
/// - display / headline / title → DynaPuff 700 (flat — no bubble effect),
/// - body → Baloo 2 400, label (buttons, chips) → Baloo 2 600.
///
/// Sizes, colours, heights and spacing of [base] are kept; only family,
/// weight and [KidFonts.fallback] change. The theme cannot know the text, so
/// for content in other scripts pick a face per string with
/// [KidFonts.familyFor] (or `KidTheme.of(context).style(role, forText: …)`).
abstract final class KidTextTheme {
  static TextTheme apply(TextTheme base) => base.copyWith(
    displayLarge: _display(base.displayLarge),
    displayMedium: _display(base.displayMedium),
    displaySmall: _display(base.displaySmall),
    headlineLarge: _display(base.headlineLarge),
    headlineMedium: _display(base.headlineMedium),
    headlineSmall: _display(base.headlineSmall),
    titleLarge: _display(base.titleLarge),
    titleMedium: _display(base.titleMedium),
    titleSmall: _display(base.titleSmall),
    bodyLarge: _face(base.bodyLarge, KidFonts.baloo2, 400),
    bodyMedium: _face(base.bodyMedium, KidFonts.baloo2, 400),
    bodySmall: _face(base.bodySmall, KidFonts.baloo2, 400),
    labelLarge: _face(base.labelLarge, KidFonts.baloo2, 600),
    labelMedium: _face(base.labelMedium, KidFonts.baloo2, 600),
    labelSmall: _face(base.labelSmall, KidFonts.baloo2, 600),
  );

  static TextStyle? _display(TextStyle? s) => _face(s, KidFonts.dynaPuff, 700);

  static TextStyle? _face(TextStyle? s, String family, double weight) => s?.copyWith(
    fontFamily: family,
    fontFamilyFallback: KidFonts.fallback,
    fontWeight: kidFontWeight(weight),
    fontVariations: [FontVariation.weight(weight)],
  );
}
