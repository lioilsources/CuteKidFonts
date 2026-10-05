import 'package:cute_kid_fonts/cute_kid_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    test('KidTextTheme.apply keeps sizes/colours, swaps faces ($brightness)', () {
      final base = ThemeData(brightness: brightness).textTheme;
      final kid = KidTextTheme.apply(base);
      final display = [kid.displayLarge, kid.headlineMedium, kid.titleLarge, kid.titleSmall];
      final body = [kid.bodyLarge, kid.bodyMedium, kid.bodySmall];
      final label = [kid.labelLarge, kid.labelSmall];
      for (final s in display) {
        expect(s!.fontFamily, KidFonts.dynaPuff);
        expect(s.fontWeight, FontWeight.w700);
      }
      for (final s in body) {
        expect(s!.fontFamily, KidFonts.baloo2);
        expect(s.fontWeight, FontWeight.w400);
      }
      for (final s in label) {
        expect(s!.fontFamily, KidFonts.baloo2);
        expect(s.fontWeight, FontWeight.w600);
      }
      expect(kid.bodyLarge!.fontFamilyFallback, KidFonts.fallback);
      expect(kid.displayLarge!.fontSize, base.displayLarge!.fontSize);
      expect(kid.bodyMedium!.color, base.bodyMedium!.color);
      expect(kid.labelLarge!.height, base.labelLarge!.height);
    });
  }

  testWidgets('Material widgets pick up the kid faces', (tester) async {
    final base = ThemeData();
    await tester.pumpWidget(
      MaterialApp(
        theme: base.copyWith(textTheme: KidTextTheme.apply(base.textTheme)),
        home: Scaffold(
          appBar: AppBar(title: const Text('Lexify')),
          body: const Text('Ahoj'),
        ),
      ),
    );
    TextStyle styleOf(String t) => tester
        .widget<RichText>(find.descendant(of: find.text(t), matching: find.byType(RichText)))
        .text
        .style!;
    expect(styleOf('Lexify').fontFamily, KidFonts.dynaPuff);
    expect(styleOf('Ahoj').fontFamily, KidFonts.baloo2);
  });
}
