import 'dart:io';

import 'package:cute_kid_fonts/cute_kid_fonts.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cmap.dart';

/// Acceptance test from the plan: a face missing any glyph of
/// [kidDiacriticsSample] is rejected (it would silently fall back).
void main() {
  const extra = 'CH?!.,:;\'"-()…';
  final faces = {
    'DynaPuff-Variable.ttf': 'title/upper/lower/key',
    'Baloo2-Variable.ttf': 'body/dialog/number',
    'Grandstander-Italic-Variable.ttf': 'titleItalic',
    'Nunito-Variable.ttf': 'fallback',
    'Nunito-Italic-Variable.ttf': 'italic fallback',
  };

  for (final MapEntry(key: file, value: roles) in faces.entries) {
    test('$file ($roles) covers all Czech diacritics', () {
      final cmap = readCmap(File('fonts/$file').readAsBytesSync());
      final missing = (kidDiacriticsSample + extra).runes
          .where((c) => c != 0x20 && !cmap.contains(c))
          .map(String.fromCharCode)
          .toList();
      expect(missing, isEmpty, reason: '$file is missing glyphs');
    });
  }

  test('every role uses a bundled face', () {
    const bundled = {KidFonts.dynaPuff, KidFonts.baloo2, KidFonts.grandstanderItalic};
    for (final role in KidRole.values) {
      expect(bundled, contains(role.spec.family), reason: role.name);
    }
  });
}
