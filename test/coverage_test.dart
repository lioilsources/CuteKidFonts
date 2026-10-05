import 'package:cute_kid_fonts/cute_kid_fonts.dart';
import 'package:cute_kid_fonts/src/coverage.g.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/gen_coverage.dart';

void main() {
  test('generated coverage table matches fonts/ (run tool/gen_coverage.dart)', () {
    expect(kidCoverageRanges, computeCoverage('fonts'));
  });

  const czech = 'Příliš žluťoučký kůň úpěl ďábelské ódy';
  const vietnamese = 'Tiếng Việt rất đẹp: ạảấầẩẫậắằẳẵặơưếềểễệ';
  const pinyin = 'Nǐ hǎo, lǜsè Ǐ';
  const russian = 'Привет, мир! ёЁ';
  const ukrainian = 'Ґанок, їжак, єнот';
  const serbian = 'Ђурђевак, љубав, њива, ћуприја, џак';
  const bulgarian = 'Здравей, свят';
  const polishTurkishRomanian = 'Zażółć gęślą jaźń · Iğdır şişe · Știință țară';
  const nordic = 'Æble, ødelagt, Åse · Straße';
  const hindi = 'नमस्ते दुनिया';
  const greek = 'Γειά σου κόσμε';
  const hebrew = 'שלום עולם';
  const arabic = 'مرحبا بالعالم';
  const japanese = 'こんにちは';

  final cases = <(String, KidRole, String?)>[
    (czech, KidRole.title, KidFonts.dynaPuff),
    (polishTurkishRomanian, KidRole.title, KidFonts.dynaPuff),
    (nordic, KidRole.title, KidFonts.dynaPuff),
    (czech, KidRole.body, KidFonts.baloo2),
    (czech, KidRole.titleItalic, KidFonts.grandstanderItalic),
    // DynaPuff lacks these → the whole string moves to the next face.
    (vietnamese, KidRole.title, KidFonts.baloo2),
    (pinyin, KidRole.title, KidFonts.baloo2),
    (vietnamese, KidRole.titleItalic, KidFonts.grandstanderItalic),
    (hindi, KidRole.title, KidFonts.baloo2),
    (hindi, KidRole.body, KidFonts.baloo2),
    // Cyrillic: only Nunito.
    for (final t in [russian, ukrainian, serbian, bulgarian]) ...[
      (t, KidRole.title, KidFonts.nunito),
      (t, KidRole.body, KidFonts.nunito),
    ],
    // No bundled face → null, caller uses the system font.
    for (final t in [greek, hebrew, arabic, japanese]) (t, KidRole.title, null),
  ];

  for (final (text, role, expected) in cases) {
    test('familyFor("$text", ${role.name}) → ${expected?.split('/').last}', () {
      expect(KidFonts.familyFor(text, role: role), expected);
    });
  }

  test('emoji, joiners and whitespace do not break coverage', () {
    expect(KidFonts.familyFor('Ahoj 🐱👨‍👩‍👧 ✨ kůň', role: KidRole.title), KidFonts.dynaPuff);
  });

  test('styles and bubble text use the covering face for the whole string', () {
    expect(KidRole.title.style(forText: vietnamese).fontFamily, KidFonts.baloo2);
    expect(KidRole.title.style(forText: greek).fontFamily, KidFonts.dynaPuff, reason: 'no cover → role face');
    expect(KidRole.title.style().fontFamily, KidFonts.dynaPuff);
    expect(const KidThemeData().style(KidRole.dialog, forText: russian).fontFamily, KidFonts.nunito);
  });

  test('KidBubblePainter resolves one face for the whole string', () {
    String familyOf(String text) {
      final p = KidBubblePainter(text: text, role: KidRole.upper);
      addTearDown(p.dispose);
      return p.fontFamily;
    }

    expect(familyOf(vietnamese), KidFonts.baloo2);
    expect(familyOf(czech), KidFonts.dynaPuff);
    expect(familyOf(russian), KidFonts.nunito);
    expect(familyOf(greek), KidFonts.dynaPuff);
  });
}
