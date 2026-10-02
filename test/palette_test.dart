import 'package:cute_kid_fonts/cute_kid_fonts.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('contrast ≥ 4.5:1 for flat body/dialog text', () {
    for (final p in KidPalette.values) {
      test('${p.name}: dark on white', () {
        expect(kidContrastRatio(p.dark, const Color(0xFFFFFFFF)), greaterThanOrEqualTo(4.5));
      });
      test('${p.name}: dark on its light face', () {
        expect(kidContrastRatio(p.dark, p.light), greaterThanOrEqualTo(4.5));
      });
      test('${p.name}: light on dark background (onDark)', () {
        expect(kidContrastRatio(p.light, const Color(0xFF26233A)), greaterThanOrEqualTo(4.5));
      });
      test('${p.name}: outline vs face mid', () {
        expect(kidContrastRatio(p.dark, p.mid), greaterThanOrEqualTo(3.0));
      });
    }
  });

  test('key groups', () {
    expect(kidKeyGroupOf('A'), KidKeyGroup.vowel);
    expect(kidKeyGroupOf('y'), KidKeyGroup.vowel);
    expect(kidKeyGroupOf('K'), KidKeyGroup.consonant);
    expect(kidKeyGroupOf('CH'), KidKeyGroup.consonant);
    expect(kidKeyGroupOf('Ž'), KidKeyGroup.diacritic);
    expect(kidKeyGroupOf('Á'), KidKeyGroup.diacritic);
    expect(const KidThemeData().paletteForKey('Ů'), KidPalette.mint);
    expect(const KidThemeData().paletteForKey('E'), KidPalette.peach);
    expect(const KidThemeData().paletteForKey('B'), KidPalette.sky);
  });

  test('upper/lower transform and spacing', () {
    expect(KidRole.upper.spec.apply('žluťoučký'), 'ŽLUŤOUČKÝ');
    expect(KidRole.lower.spec.apply('ŽLUŤOUČKÝ'), 'žluťoučký');
    expect(KidRole.upper.spec.letterSpacing, 1.5);
    expect(KidRole.lower.spec.letterSpacing, 0);
  });

  test('number role uses tabular figures and is flat', () {
    expect(KidRole.number.spec.features, contains(const FontFeature.tabularFigures()));
    expect(KidRole.number.spec.flat, isTrue);
    expect(KidRole.dialog.spec.size, greaterThanOrEqualTo(18));
  });
}
