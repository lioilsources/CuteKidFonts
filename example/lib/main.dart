import 'package:cute_kid_fonts/cute_kid_fonts_flame.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() => runApp(const GalleryApp());

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  bool dark = false;

  @override
  Widget build(BuildContext context) {
    final bg = dark ? const Color(0xFF26233A) : const Color(0xFFFFFBF2);
    return MaterialApp(
      title: 'CuteKidFonts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: dark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: bg,
        colorSchemeSeed: KidPalette.sky.mid,
      ),
      home: KidTheme(
        data: KidThemeData(onDark: dark),
        child: DefaultTabController(
          length: 5,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: bg,
              title: const BubbleText('CuteKidFonts', size: 28, palette: KidPalette.lavender),
              actions: [
                IconButton(
                  tooltip: 'Světlé / tmavé pozadí',
                  icon: Icon(dark ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () => setState(() => dark = !dark),
                ),
              ],
              bottom: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Role × palety'),
                  Tab(text: 'Klávesy'),
                  Tab(text: 'Diakritika'),
                  Tab(text: 'List 50×'),
                  Tab(text: 'Flame'),
                ],
              ),
            ),
            body: const TabBarView(
              children: [RolesPage(), KeysPage(), DiacriticsPage(), PerfListPage(), FlamePage()],
            ),
          ),
        ),
      ),
    );
  }
}

class RolesPage extends StatelessWidget {
  const RolesPage({super.key});

  static String _sample(KidRole role) => switch (role) {
    KidRole.number => '0123 456',
    KidRole.body => 'Pojď si hrát s písmenky.',
    KidRole.dialog => '„Ahoj, jak se máš?"',
    KidRole.key => 'Ž',
    _ => 'Ahoj kůň!',
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final role in KidRole.values) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Text(role.name, style: Theme.of(context).textTheme.labelLarge),
          ),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final p in KidPalette.values)
                role == KidRole.key
                    ? KidKeyLabel.fit(_sample(role), keyHeight: 64, palette: p)
                    : BubbleText(
                        _sample(role),
                        role: role,
                        palette: p,
                        size: role.spec.size > 40 ? 40 : null,
                      ),
            ],
          ),
        ],
      ],
    );
  }
}

class KeysPage extends StatelessWidget {
  const KeysPage({super.key});

  static const rows = [
    ['Ě', 'Š', 'Č', 'Ř', 'Ž', 'Ý', 'Á', 'Í', 'É'],
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'Ú'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ů'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', 'CH', 'Ď', 'Ť', 'Ň'],
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final keyH = ((constraints.maxWidth - 32) / 11.5).clamp(32.0, 72.0);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final row in rows)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final k in row)
                    Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(keyH * 0.2),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: KidKeyLabel.fit(k, keyHeight: keyH),
                    ),
                ],
              ),
            const SizedBox(height: 16),
            Text(
              'Samohlásky peach, souhlásky sky, diakritika mint — nastavitelné přes KidThemeData.keyPalettes.',
              style: KidTheme.of(context).style(KidRole.body),
            ),
          ],
        );
      },
    );
  }
}

class DiacriticsPage extends StatelessWidget {
  const DiacriticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final role in KidRole.values)
          if (role != KidRole.key)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: BubbleText(
                kidDiacriticsSample,
                role: role,
                palette: KidPalette.lemon,
                size: role.spec.size > 32 ? 32 : null,
                align: TextAlign.left,
              ),
            ),
        const SizedBox(height: 12),
        BubbleText(kidSampleLine, role: KidRole.dialog, palette: KidPalette.lavender),
      ],
    );
  }
}

/// Performance check: 50 bubble rows in a scrolling list.
class PerfListPage extends StatelessWidget {
  const PerfListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 50,
      itemBuilder: (context, i) => ListTile(
        leading: KidKeyLabel.fit(String.fromCharCode(0x41 + i % 26), keyHeight: 44),
        title: BubbleText(
          'Úroveň ${i + 1}',
          role: KidRole.title,
          size: 30,
          palette: KidPalette.values[i % KidPalette.values.length],
          align: TextAlign.left,
        ),
        trailing: BubbleText('${(i * 137) % 1000}'.padLeft(3, '0'), role: KidRole.number, size: 24),
      ),
    );
  }
}

class FlamePage extends StatefulWidget {
  const FlamePage({super.key});

  @override
  State<FlamePage> createState() => _FlamePageState();
}

class _FlamePageState extends State<FlamePage> {
  final game = _DemoGame();

  @override
  Widget build(BuildContext context) => GameWidget(game: game);
}

class _DemoGame extends FlameGame {
  late final TextComponent _score;
  double _t = 0;

  @override
  Color backgroundColor() => const Color(0xFF26233A);

  @override
  Future<void> onLoad() async {
    final center = size / 2;
    add(
      KidBubbleComponent(
        text: 'game over',
        role: KidRole.upper,
        palette: KidPalette.peach,
        fontSize: 56,
        position: center,
        anchor: Anchor.center,
      ),
    );
    add(
      KidBubbleComponent(
        text: 'Úroveň 3',
        role: KidRole.titleItalic,
        palette: KidPalette.mint,
        position: center + Vector2(0, 80),
        anchor: Anchor.center,
      ),
    );
    add(
      _score = TextComponent(
        text: '0000',
        textRenderer: KidTextPaint.of(KidRole.number, KidPalette.lemon, onDark: true),
        position: Vector2(16, 16),
      ),
    );
    add(
      TextComponent(
        text: KidTextPaint.text(KidRole.upper, 'skóre'),
        textRenderer: KidTextPaint.of(KidRole.upper, KidPalette.sky, size: 24),
        position: Vector2(size.x - 16, 16),
        anchor: Anchor.topRight,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    _score.text = (_t * 10).floor().toString().padLeft(4, '0');
  }
}
