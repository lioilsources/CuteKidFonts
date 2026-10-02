/// Test helper for apps: loads the bundled fonts so widget/golden tests
/// render real glyphs instead of the Ahem placeholder.
///
/// ```dart
/// // test/flutter_test_config.dart
/// Future<void> testExecutable(FutureOr<void> Function() testMain) async {
///   TestWidgetsFlutterBinding.ensureInitialized();
///   await loadKidFonts();
///   await testMain();
/// }
/// ```
library;

import 'package:flutter/services.dart';

import 'src/roles.dart';

const _files = {
  KidFonts.dynaPuff: ['DynaPuff-Variable.ttf'],
  KidFonts.baloo2: ['Baloo2-Variable.ttf'],
  KidFonts.grandstanderItalic: ['Grandstander-Italic-Variable.ttf'],
  KidFonts.nunito: ['Nunito-Variable.ttf', 'Nunito-Italic-Variable.ttf'],
};

/// Loads every bundled face under its package-prefixed family name.
Future<void> loadKidFonts([AssetBundle? bundle]) async {
  final b = bundle ?? rootBundle;
  for (final MapEntry(key: family, value: files) in _files.entries) {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(b.load('packages/${KidFonts.package}/fonts/$f'));
    }
    await loader.load();
  }
}
