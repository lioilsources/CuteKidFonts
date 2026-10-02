import 'package:cute_kid_fonts/cute_kid_fonts_flame.dart';
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

  testWidgets('rasterize: image matches logical size × pixelRatio and cache hits', (tester) async {
    final cache = KidRasterCache(maxEntries: 2);
    late KidRasterText a, b;
    await tester.runAsync(() async {
      a = await cache.get('GAME OVER', role: KidRole.upper, palette: KidPalette.peach, pixelRatio: 2);
      b = await cache.get('GAME OVER', role: KidRole.upper, palette: KidPalette.peach, pixelRatio: 2);
    });
    expect(identical(a, b), isTrue);
    expect(cache.hits, 1);
    expect(cache.misses, 1);
    expect(a.image.width, (a.size.width * 2).ceil());
    expect(a.image.height, (a.size.height * 2).ceil());

    await tester.runAsync(() async {
      await cache.get('1');
      await cache.get('2');
    });
    expect(cache.length, 2, reason: 'LRU evicts beyond maxEntries');
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
