# Changelog

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
