import 'dart:async';

import 'package:cute_kid_fonts_flame/cute_kid_fonts_flame_testing.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadKidFonts();
  await testMain();
}
