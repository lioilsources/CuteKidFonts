# Changelog

## 0.2.1

- Fix: `KidTextTheme.apply` no longer sets `fontVariations`. They were inherited
  by `merge`/`copyWith` and overrode any descendant `fontWeight`, so
  `TextStyle(fontWeight: FontWeight.bold)` rendered regular. `fontWeight` alone
  drives the variable fonts' `wght` axis (verified on Flutter 3.44.4; a test
  fails on engines where it doesn't). Role styles used by `BubbleText` keep the
  explicit variation. Reported by the Lexify session.

## 0.2.0

**Breaking:** Flame moved out of the core package.

- The core `cute_kid_fonts` no longer depends on `flame`. `KidTextPaint` and
  `KidBubbleComponent` moved to the new `cute_kid_fonts_flame` package in
  `packages/cute_kid_fonts_flame` (git dependency with
  `path: packages/cute_kid_fonts_flame`). Replace the
  `package:cute_kid_fonts/cute_kid_fonts_flame.dart` import with
  `package:cute_kid_fonts_flame/cute_kid_fonts_flame.dart`.
  `rasterizeBubble()` / `KidRasterCache` / `KidRasterText` stay in the core.
  Games depend on `cute_kid_fonts_flame` only — it re-exports the core and
  `loadKidFonts()` (`cute_kid_fonts_flame_testing.dart`).
- `KidTextTheme.apply(TextTheme)`: Material entry point (display/headline/title →
  DynaPuff 700, body → Baloo 2 400, label → Baloo 2 600; base sizes and colours kept).
- One face per string: `KidFonts.familyFor(text, role:)`, `KidFonts.firstCovering`,
  `KidFonts.covers`, `KidBubblePainter.fontFamily`, and `forText:` on
  `KidRoleSpec.textStyle` / `KidRole.style` / `KidThemeData.style`. `BubbleText` and
  `KidBubblePainter` use it automatically, so a Vietnamese title renders entirely
  in Baloo 2 and a Russian one entirely in Nunito instead of mixing faces glyph by
  glyph. Czech/Latin text is unchanged (goldens identical).
- Coverage table generated from the fonts (`tool/gen_coverage.dart`) and tests for
  Vietnamese, pinyin, Hindi, Cyrillic, extended Latin, Greek/Hebrew/Arabic/CJK → null.

## 0.1.1

- Fallback chain is now Baloo 2 → Nunito (was Nunito only), so pinyin tone
  marks (Ǐ ǒ ǚ ǜ…) in DynaPuff roles no longer drop to the system font.
  Czech/Latin rendering and layout geometry are unchanged (goldens identical).

## 0.1.0

- First release.
- Bundled OFL fonts: DynaPuff (title/upper/lower/key), Baloo 2 (body/dialog/number),
  Grandstander Italic (titleItalic), Nunito (fallback). Fredoka from the original plan
  was dropped — it fails the Czech diacritics test.
- `KidPalette` (peach, mint, lavender, lemon, sky), `KidRole` + `KidRoleSpec`.
- `BubbleText` (extrusion, outline, gradient face, gloss; `flat` mode),
  `KidKeyLabel`, `KidTheme` / `KidThemeData` (default palette, key-group palettes,
  size scale, `onDark`).
- Flame: `KidTextPaint`, `KidBubbleComponent`, `rasterizeBubble`, `KidRasterCache`.
- `loadKidFonts()` test helper for apps' golden tests.
- Tests: cmap-based diacritics acceptance, contrast, layout, goldens (every role on
  light and dark backgrounds), Flame raster cache.
