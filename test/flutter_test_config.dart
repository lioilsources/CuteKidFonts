import 'dart:async';

import 'package:cute_kid_fonts/cute_kid_fonts_testing.dart';
import 'package:flutter_test/flutter_test.dart';

/// Real glyphs instead of the Ahem test font for widget and golden tests.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadKidFonts();
  await testMain();
}
