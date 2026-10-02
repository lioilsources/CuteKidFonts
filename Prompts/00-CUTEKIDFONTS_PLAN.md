# CUTEKIDFONTS_PLAN.md — CuteKidFonts: sdílená dětská typografie pro Flutter + Flame

## Cíl
Jeden přenositelný Dart balíček **CuteKidFonts** (`cute_kid_fonts`, samostatné repo `lioilsources/CuteKidFonts`), který dá všem Ol1nových appkám (Flutter widgety i Flame komponenty) stejné „baculaté, vystouplé, pastelové" písmo. Fáze 1 = nejjednodušší cesta: hotové OFL fonty + efekt vrstvený v kódu. Vlastní řez písma je mimo rozsah tohoto plánu.

Feedback, který řešíme: „fonty v appkách jsou nudné", přitom většina appek je pro děti.

## Rozsah fáze 1
- Role písma: **title**, **titleItalic**, **upper** (titulek velkými), **lower** (titulek malými), **body** (text), **dialog** (přímá řeč), **key** (popisky kláves ve SwypeKids), **number** (skóre/čas, tabulární číslice).
- Efekt: obrys + extruze (2–3 px dolů) + gradient plocha + volitelný lesk. Vypínatelný (`flat: true`) pro body/dialog.
- Paleta: 5 pastelových dvojic (plocha → obrys/stín): peach/brick, mint/forest, lavender/plum, lemon/mustard, sky/navy. Pojmenované, žádné hex v appkách.
- Platformy: Flutter widget + Flame `TextPaint` wrapper + export do PNG pro statické nápisy.

## Fonty (OFL, ověřit češtinu!)
- Title: **Fredoka** (variabilní, wght 300–700) — hlavní.
- Dialog/body: **Baloo 2** (SemiBold / Regular), fallback **Nunito**.
- Kurzíva (`titleItalic`): třetí font s **pravým italic řezem** — primárně **Grandstander** (variabilní, má Italic osu, hravý kulatý tvar, Latin Extended), fallback **Nunito ExtraBold Italic**. Žádný syntetický skew. Grandstander musí projít stejným diakritickým testem; pokud neprojde, Nunito.
- **Akceptační test diakritiky**: vyrenderovat `ěščřžýáíéúůďťňó ĚŠČŘŽÝÁÍÉÚŮĎŤŇÓ 0123456789` v každém řezu; chybějící glyf = font vyřazen.
- Fonty bundlovat uvnitř balíčku (`cute_kid_fonts/fonts/`), ne přes `google_fonts` (offline appky, deterministický build).

## Struktura balíčku
```
cute_kid_fonts/
  lib/
    cute_kid_fonts.dart            # export
    src/palette.dart        # KidPalette (enum + colors)
    src/roles.dart          # KidRole enum + default TextStyle per role
    src/bubble_text.dart    # BubbleText widget (vrstvený efekt)
    src/key_label.dart      # KidKeyLabel — popisek klávesy, pevný box
    src/flame/bubble_text_paint.dart   # Flame TextPaint / TextComponent
    src/flame/rasterize.dart           # BubbleText → ui.Image (cache)
  fonts/
  example/                  # ukázková galerie všech rolí × palet
  pubspec.yaml
```
Samostatné repo `lioilsources/CuteKidFonts`; appky importují přes git dependency v `pubspec.yaml` (`git: url + ref: tag`), při vývoji lokální path override. Semver, první tag v0.1.0. Připravit na případné zveřejnění na pub.dev (LICENSE, CHANGELOG, OFL licence fontů v `fonts/`).

## API (návrh, Opus může upravit)
```dart
enum KidRole { title, titleItalic, upper, lower, body, dialog, key, number }
enum KidPalette { peach, mint, lavender, lemon, sky }

BubbleText(
  'Ahoj!',
  role: KidRole.title,
  palette: KidPalette.mint,
  size: 48,           // volitelný override
  flat: false,        // bez obrysu/extruze
  align: TextAlign.center,
);

KidKeyLabel('Ž', palette: KidPalette.peach, size: 36); // čtvercový box, centrováno
KidTheme.of(context).style(KidRole.body);                 // čistý TextStyle pro Text()

// Flame
KidTextPaint.of(KidRole.title, KidPalette.sky, size: 40);   // vrací TextPaint
KidBubbleComponent(text: 'LEVEL 3', role: KidRole.upper, ...); // PositionComponent
```
- `upper`/`lower` = `title` + `toUpperCase()` / `toLowerCase()` + jiný letterSpacing (upper +1.5, lower 0).
- `number` = Fredoka + `FontFeature.tabularFigures()`, flat, bez extruze (čitelnost na skóre).
- `dialog` = Baloo 2 SemiBold, flat, barva z palety „obrys" na světlém pozadí.

## Implementace BubbleText (vrstvy odspodu)
1. Obrys: `Text` s `foreground: Paint()..style = stroke..strokeWidth = size*0.14..color = palette.dark`.
2. Extruze: 2–3 kopie textu posunuté `Offset(0, i*size*0.035)` v `palette.dark`.
3. Plocha: `foreground: Paint()..shader = LinearGradient(top: palette.light, bottom: palette.mid)`.
4. Lesk (volitelný): bílý text s opacity 0.35, `ClipRect` na horní 40 % výšky.
Vše ve `Stack` + jeden `RepaintBoundary`. Shader rect počítat z `TextPainter` layoutu, ne z constraints.

## Flame
- `KidTextPaint` sestaví `TextStyle` jen pro plochu + obrys (Flame `TextPaint` umí jeden Paint) → pro plný efekt použít `rasterize()`: vyrenderovat `BubbleText` přes `TextPainter` do `ui.Image`, cache podle (text, role, palette, size), zobrazit jako `SpriteComponent`.
- Dynamické texty (skóre) → `TextPaint` flat. Statické (názvy levelů, „GAME OVER") → rasterizovaný sprite.

## SwypeKids — pojmenované klávesy
- Každá klávesa dostane `KidKeyLabel`; velikost písma se odvozuje z velikosti klávesy (`size = keyHeight * 0.55`), aby „Ž" i „CH" seděly ve stejném boxu.
- Dvojznaky (CH) a diakritika musí projít testem výše; obrys tenčí (`size*0.10`) kvůli malým rozměrům.
- Barvy kláves: mapa skupina → paleta (samohlásky peach, souhlásky sky, diakritika mint) — nastavitelné z appky, default v balíčku.

## Pořadí práce
1. Založit balíček, bundlovat fonty, diakritický test (screenshot do `example/`).
2. `KidPalette`, `KidRole` + čisté `TextStyle`.
3. `BubbleText` (title, flat varianta), golden test 3 palety.
4. Kurzíva — bundlovat Grandstander Italic, diakritický test, `titleItalic` přes BubbleText (stejné vrstvy, jen jiná rodina).
5. `upper`, `lower`, `number`, `dialog`, `body`.
6. `KidKeyLabel` + integrace do SwypeKids (první reálná appka).
7. Flame: `KidTextPaint` + `rasterize()`, integrace do Kiran nebo ImmunoRun (jeden nápis).
8. Example galerie, README s ukázkami, tag v0.1.0.

## Ověření
- Golden testy pro každou roli × 1 paletu (světlé i tmavé pozadí).
- Čitelnost: dialog min. 18 pt na telefonu, kontrast plocha/obrys ≥ 4.5:1 pro body/dialog.
- Výkon: BubbleText v listu 50 položek bez jank na středním Androidu; Flame sprite cache hit.
- Diakritika: automatický test, že žádný glyf nespadne do fallback fontu (`TextPainter` + `getBoxesForSelection` výška, nebo porovnání renderu s notdef).

## Mimo rozsah (další fáze)
- Vlastní / odvozený řez písma (FontForge), obrázková abeceda z ComfyUI, animované písmo (bounce při vstupu), COLR barevné fonty.

## Rozhodnuto
- Název: CuteKidFonts (`cute_kid_fonts`), samostatné repo, samostatně importovatelný balíček.
- Kurzíva: Grandstander Italic, fallback Nunito ExtraBold Italic.
