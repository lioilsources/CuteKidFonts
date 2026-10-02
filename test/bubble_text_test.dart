import 'package:cute_kid_fonts/cute_kid_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {Color bg = const Color(0xFFFFFBF2), KidThemeData? theme}) => MediaQuery(
  data: const MediaQueryData(),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: KidTheme(
      data: theme ?? const KidThemeData(),
      child: ColoredBox(
        color: bg,
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(padding: const EdgeInsets.all(12), child: child),
        ),
      ),
    ),
  ),
);

void main() {
  group('layout', () {
    testWidgets('bubble text is padded by outline and extrusion', (tester) async {
      await tester.pumpWidget(_wrap(const BubbleText('Ahoj!', size: 50)));
      final bubble = tester.getSize(find.byType(BubbleText));
      await tester.pumpWidget(_wrap(const BubbleText('Ahoj!', size: 50, flat: true)));
      final flat = tester.getSize(find.byType(BubbleText));
      // stroke 0.14*50 = 7 → 3.5 each side; extrusion 3 × 0.035*50 = 5.25.
      expect(bubble.width - flat.width, closeTo(7, 0.01));
      expect(bubble.height - flat.height, closeTo(7 + 5.25, 0.01));
    });

    testWidgets('upper role uppercases and exposes semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const BubbleText('úroveň 3', role: KidRole.upper)));
      expect(find.bySemanticsLabel('ÚROVEŇ 3'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('theme sizeScale applies to defaults', (tester) async {
      await tester.pumpWidget(
        _wrap(const BubbleText('A', flat: true), theme: const KidThemeData(sizeScale: 2)),
      );
      final big = tester.getSize(find.byType(BubbleText));
      await tester.pumpWidget(_wrap(const BubbleText('A', flat: true)));
      final normal = tester.getSize(find.byType(BubbleText));
      expect(big.height, closeTo(normal.height * 2, 1));
    });

    testWidgets('wraps within bounded width', (tester) async {
      await tester.pumpWidget(
        _wrap(const SizedBox(width: 200, child: BubbleText('Příliš žluťoučký kůň', size: 40))),
      );
      final s = tester.getSize(find.byType(BubbleText));
      expect(s.width, lessThanOrEqualTo(200));
      expect(s.height, greaterThan(80)); // more than one line
    });

    testWidgets('number role keeps width for different digits (tabular)', (tester) async {
      await tester.pumpWidget(_wrap(const BubbleText('1111', role: KidRole.number)));
      final ones = tester.getSize(find.byType(BubbleText)).width;
      await tester.pumpWidget(_wrap(const BubbleText('8888', role: KidRole.number)));
      final eights = tester.getSize(find.byType(BubbleText)).width;
      expect(ones, closeTo(eights, 0.5));
    });

    testWidgets('key label: Ž and CH share the same box', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              KidKeyLabel.fit('Ž', keyHeight: 64, key: ValueKey('z')),
              KidKeyLabel.fit('CH', keyHeight: 64, key: ValueKey('ch')),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byKey(const ValueKey('z'))), const Size(64, 64));
      expect(tester.getSize(find.byKey(const ValueKey('ch'))), const Size(64, 64));
      final chText = tester.getSize(
        find.descendant(of: find.byKey(const ValueKey('ch')), matching: find.byType(BubbleText)),
      );
      expect(chText.width, lessThanOrEqualTo(64));
      expect(tester.takeException(), isNull);
    });

    testWidgets('KidTheme.style returns a plain TextStyle in the dark colour', (tester) async {
      late TextStyle style;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              style = KidTheme.of(context).style(KidRole.body, palette: KidPalette.mint);
              return Text('x', style: style);
            },
          ),
        ),
      );
      expect(style.color, KidPalette.mint.dark);
      expect(style.fontFamily, KidFonts.baloo2);
      expect(style.fontSize, 18);
    });
  });

  group('goldens', () {
    Future<void> shoot(
      WidgetTester tester,
      Widget child,
      String name, {
      Size size = const Size(820, 400),
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(child);
      await expectLater(find.byType(ColoredBox).first, matchesGoldenFile('goldens/$name.png'));
    }

    testWidgets('title in three palettes', (tester) async {
      await shoot(
        tester,
        _wrap(
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BubbleText('Ahoj, Lauro!', palette: KidPalette.mint),
              BubbleText('Žluťoučký kůň', palette: KidPalette.peach),
              BubbleText('Úroveň 3', palette: KidPalette.lavender),
            ],
          ),
        ),
        'title_palettes',
        size: const Size(520, 260),
      );
    });

    for (final (bgName, bg) in [('light', Color(0xFFFFFBF2)), ('dark', Color(0xFF26233A))]) {
      testWidgets('every role on $bgName background', (tester) async {
        await shoot(
          tester,
          _wrap(
            bg: bg,
            theme: KidThemeData(onDark: bgName == 'dark'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final role in KidRole.values)
                  Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(
                          role.name,
                          style: TextStyle(
                            fontFamily: KidFonts.nunito,
                            fontSize: 14,
                            color: bg.computeLuminance() > 0.5 ? Colors.black54 : Colors.white70,
                          ),
                        ),
                      ),
                      if (role == KidRole.key)
                        for (final k in ['A', 'Ž', 'CH', 'B']) KidKeyLabel.fit(k, keyHeight: 56)
                      else
                        BubbleText(
                          role == KidRole.number ? '0123 456 789' : 'Žluťoučký kůň',
                          role: role,
                          palette: KidPalette.sky,
                          size: role.spec.size > 40 ? 40 : null,
                        ),
                    ],
                  ),
              ],
            ),
          ),
          'roles_$bgName',
          size: const Size(560, 470),
        );
      });
    }

    testWidgets('diacritics sheet', (tester) async {
      await shoot(
        tester,
        _wrap(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final role in [KidRole.title, KidRole.titleItalic, KidRole.dialog, KidRole.number])
                SizedBox(
                  width: 1180,
                  child: BubbleText(
                    kidDiacriticsSample,
                    role: role,
                    size: 38,
                    align: TextAlign.left,
                    palette: KidPalette.lemon,
                  ),
                ),
            ],
          ),
        ),
        'diacritics',
        size: const Size(1210, 300),
      );
    });
  });
}
