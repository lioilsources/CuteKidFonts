import 'package:flutter/widgets.dart';

import 'palette.dart';
import 'roles.dart';

/// Groups used to colour keyboard keys.
enum KidKeyGroup { vowel, consonant, diacritic }

const _diacritics = 'áčďéěíňóřšťúůýžäöüÁČĎÉĚÍŇÓŘŠŤÚŮÝŽÄÖÜ';
const _vowels = 'aeiouyAEIOUY';

/// Classifies a key label: anything with a diacritic mark wins, then vowels;
/// everything else (incl. digraphs like CH) is a consonant.
KidKeyGroup kidKeyGroupOf(String label) {
  if (label.characters.any(_diacritics.contains)) return KidKeyGroup.diacritic;
  if (label.isNotEmpty && label.characters.every(_vowels.contains)) return KidKeyGroup.vowel;
  return KidKeyGroup.consonant;
}

/// App-wide defaults for kid typography.
@immutable
class KidThemeData {
  const KidThemeData({
    this.palette = KidPalette.sky,
    this.keyPalettes = const {
      KidKeyGroup.vowel: KidPalette.peach,
      KidKeyGroup.consonant: KidPalette.sky,
      KidKeyGroup.diacritic: KidPalette.mint,
    },
    this.sizeScale = 1.0,
    this.onDark = false,
  });

  /// Palette used when a widget does not specify one.
  final KidPalette palette;

  /// Key group → palette for [KidKeyLabel].
  final Map<KidKeyGroup, KidPalette> keyPalettes;

  /// Multiplier applied to every role's default size.
  final double sizeScale;

  /// Text sits on a dark background: flat text switches from the palette's
  /// dark colour to its light one.
  final bool onDark;

  /// Colour of flat text (body, dialog, number, `flat: true`).
  Color flatColor(KidPalette palette) => onDark ? palette.light : palette.dark;

  KidPalette paletteForKey(String label) => keyPalettes[kidKeyGroupOf(label)] ?? palette;

  double sizeOf(KidRole role, [double? size]) => size ?? role.spec.size * sizeScale;

  /// Plain [TextStyle] for `Text()` — no bubble effect, [flatColor].
  ///
  /// Pass [forText] to pick the face that covers the whole string.
  TextStyle style(KidRole role, {KidPalette? palette, double? size, Color? color, String? forText}) => role
      .style(size: sizeOf(role, size), color: color ?? flatColor(palette ?? this.palette), forText: forText);

  KidThemeData copyWith({
    KidPalette? palette,
    Map<KidKeyGroup, KidPalette>? keyPalettes,
    double? sizeScale,
    bool? onDark,
  }) => KidThemeData(
    palette: palette ?? this.palette,
    keyPalettes: keyPalettes ?? this.keyPalettes,
    sizeScale: sizeScale ?? this.sizeScale,
    onDark: onDark ?? this.onDark,
  );

  @override
  bool operator ==(Object other) =>
      other is KidThemeData &&
      other.palette == palette &&
      other.sizeScale == sizeScale &&
      other.onDark == onDark &&
      _mapEquals(other.keyPalettes, keyPalettes);

  @override
  int get hashCode => Object.hash(
    palette,
    sizeScale,
    onDark,
    Object.hashAllUnordered(keyPalettes.entries.map((e) => (e.key, e.value))),
  );
}

bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) =>
    a.length == b.length && a.entries.every((e) => b[e.key] == e.value);

/// Provides [KidThemeData] to the subtree. Optional — without it,
/// [KidTheme.of] returns defaults.
class KidTheme extends InheritedWidget {
  const KidTheme({super.key, required this.data, required super.child});

  final KidThemeData data;

  static KidThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<KidTheme>()?.data ?? const KidThemeData();

  @override
  bool updateShouldNotify(KidTheme oldWidget) => data != oldWidget.data;
}
