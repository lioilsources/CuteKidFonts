import 'package:cute_kid_fonts_flame/cute_kid_fonts_flame.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('KidTextPaint: flat roles are plain dark text, bubble roles get an extrusion shadow', () {
    final score = KidTextPaint.of(KidRole.number, KidPalette.sky);
    expect(score.style.color, KidPalette.sky.dark);
    expect(score.style.shadows, isNull);
    expect(KidTextPaint.of(KidRole.number, KidPalette.sky, onDark: true).style.color, KidPalette.sky.light);

    final title = KidTextPaint.of(KidRole.title, KidPalette.mint, size: 40);
    expect(title.style.fontSize, 40);
    expect(title.style.shadows!.first.color, KidPalette.mint.dark);
    expect(KidTextPaint.text(KidRole.upper, 'konec hry'), 'KONEC HRY');
  });

  testWidgets('KidBubbleComponent sizes itself from the raster', (tester) async {
    final game = FlameGame();
    final c = KidBubbleComponent(
      text: 'Level 3',
      role: KidRole.upper,
      palette: KidPalette.sky,
      cache: KidRasterCache(),
    );
    await tester.runAsync(() async {
      await game.onLoad();
      await c.onLoad();
    });
    expect(c.sprite, isNotNull);
    expect(c.size.x, greaterThan(100));
    expect(c.size.y, greaterThan(40));
  });
}
