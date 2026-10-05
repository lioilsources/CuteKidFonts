import 'package:cute_kid_fonts/cute_kid_fonts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
