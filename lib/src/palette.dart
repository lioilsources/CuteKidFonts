import 'dart:ui' show Color;

/// Five named pastel pairs: a soft face (light → mid gradient) and a dark
/// outline/extrusion colour. Apps pick a palette by name, never by hex.
enum KidPalette {
  /// Peach face, brick outline.
  peach(light: Color(0xFFFFE3D1), mid: Color(0xFFFFAE85), dark: Color(0xFFA23E22)),

  /// Mint face, forest outline.
  mint(light: Color(0xFFDDF8E8), mid: Color(0xFF86DBA9), dark: Color(0xFF1D6641)),

  /// Lavender face, plum outline.
  lavender(light: Color(0xFFF0E6FF), mid: Color(0xFFC1A3F2), dark: Color(0xFF5A2A82)),

  /// Lemon face, mustard outline.
  lemon(light: Color(0xFFFFF8C9), mid: Color(0xFFFFDC5C), dark: Color(0xFF7A5C00)),

  /// Sky face, navy outline.
  sky(light: Color(0xFFDFF1FF), mid: Color(0xFF88C6F4), dark: Color(0xFF1C3767));

  const KidPalette({required this.light, required this.mid, required this.dark});

  /// Top of the face gradient.
  final Color light;

  /// Bottom of the face gradient.
  final Color mid;

  /// Outline, extrusion and flat-text colour.
  final Color dark;
}

/// WCAG 2 contrast ratio between two opaque colours (1.0 – 21.0).
double kidContrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
