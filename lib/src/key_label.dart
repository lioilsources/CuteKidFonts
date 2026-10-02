import 'package:flutter/widgets.dart';

import 'bubble_text.dart';
import 'palette.dart';
import 'roles.dart';
import 'theme.dart';

/// Label of a keyboard key: [KidRole.key] bubble text centred in a fixed
/// box, so "Ž" and "CH" share the same footprint.
///
/// Either give the font [size] (box defaults to `size / 0.55`) or use
/// [KidKeyLabel.fit] to derive the font size from the key height.
class KidKeyLabel extends StatelessWidget {
  const KidKeyLabel(this.label, {super.key, this.palette, this.size = 36, this.boxWidth, this.boxHeight});

  /// Font size = `keyHeight * 0.55`; box = the whole key.
  const KidKeyLabel.fit(this.label, {super.key, this.palette, required double keyHeight, double? keyWidth})
    : size = keyHeight * fontToKeyRatio,
      boxHeight = keyHeight,
      boxWidth = keyWidth ?? keyHeight;

  /// Font size relative to key height.
  static const fontToKeyRatio = 0.55;

  final String label;

  /// Defaults to the theme's palette for the key's group
  /// (vowel / consonant / diacritic).
  final KidPalette? palette;
  final double size;
  final double? boxWidth;
  final double? boxHeight;

  @override
  Widget build(BuildContext context) {
    final theme = KidTheme.of(context);
    final h = boxHeight ?? size / fontToKeyRatio;
    final w = boxWidth ?? h;
    return SizedBox(
      width: w,
      height: h,
      child: Center(
        // Digraphs (CH) shrink to fit instead of overflowing the key.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: BubbleText(
            label,
            role: KidRole.key,
            palette: palette ?? theme.paletteForKey(label),
            size: size,
            maxLines: 1,
            textScaler: TextScaler.noScaling,
          ),
        ),
      ),
    );
  }
}
