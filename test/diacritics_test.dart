import 'dart:io';

import 'package:cute_kid_fonts/cute_kid_fonts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/cmap.dart';

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

  test('every role + fallback chain covers pinyin tone marks', () {
    const pinyin = 'āáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜüĀÁǍÀĒÉĚÈĪÍǏÌŌÓǑÒŪÚǓÙǕǗǙǛÜ';
    const files = {
      KidFonts.dynaPuff: 'DynaPuff-Variable.ttf',
      KidFonts.baloo2: 'Baloo2-Variable.ttf',
      KidFonts.grandstanderItalic: 'Grandstander-Italic-Variable.ttf',
      KidFonts.nunito: 'Nunito-Variable.ttf',
    };
    final cmaps = {
      for (final e in files.entries) e.key: readCmap(File('fonts/${e.value}').readAsBytesSync()),
    };
    for (final role in KidRole.values) {
      final chain = [role.spec.family, ...KidFonts.fallback];
      final missing = pinyin.runes
          .where((c) => !chain.any((f) => cmaps[f]!.contains(c)))
          .map(String.fromCharCode)
          .join();
      expect(missing, isEmpty, reason: '${role.name} falls back to the system font');
    }
  });

  test('every role uses a bundled face', () {
    const bundled = {KidFonts.dynaPuff, KidFonts.baloo2, KidFonts.grandstanderItalic};
    for (final role in KidRole.values) {
      expect(bundled, contains(role.spec.family), reason: role.name);
    }
  });
}
