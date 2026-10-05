import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'bubble_painter.dart';
import 'palette.dart';
import 'roles.dart';

/// A rasterised bubble text: the image is `pixelRatio`× the logical [size].
class KidRasterText {
  KidRasterText(this.image, this.size, this.pixelRatio);

  final ui.Image image;

  /// Logical size (what a component should occupy).
  final Size size;
  final double pixelRatio;
}

typedef _Key = (String, KidRole, KidPalette, double?, bool?, double);

/// Renders [KidBubblePainter] output into a [ui.Image].
Future<KidRasterText> rasterizeBubble(
  String text, {
  KidRole role = KidRole.title,
  KidPalette palette = KidPalette.sky,
  double? size,
  bool? flat,
  double pixelRatio = 2.0,
  TextAlign align = TextAlign.center,
}) {
  final painter = KidBubblePainter(
    text: text,
    role: role,
    palette: palette,
    size: size,
    flat: flat,
    align: align,
  )..layout();
  final logical = painter.size;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(pixelRatio);
  painter.paint(canvas, Offset.zero);
  painter.dispose();
  final picture = recorder.endRecording();
  final w = (logical.width * pixelRatio).ceil().clamp(1, 8192);
  final h = (logical.height * pixelRatio).ceil().clamp(1, 8192);
  return picture.toImage(w, h).then((image) {
    picture.dispose();
    return KidRasterText(image, logical, pixelRatio);
  });
}

/// LRU cache of rasterised bubble texts keyed by
/// (text, role, palette, size, flat, pixelRatio).
class KidRasterCache {
  KidRasterCache({this.maxEntries = 64});

  /// Shared default cache.
  static final instance = KidRasterCache();

  final int maxEntries;
  final _entries = <_Key, Future<KidRasterText>>{}; // insertion-ordered

  int hits = 0;
  int misses = 0;

  int get length => _entries.length;

  Future<KidRasterText> get(
    String text, {
    KidRole role = KidRole.title,
    KidPalette palette = KidPalette.sky,
    double? size,
    bool? flat,
    double pixelRatio = 2.0,
  }) {
    final key = (text, role, palette, size, flat, pixelRatio);
    final cached = _entries.remove(key);
    if (cached != null) {
      hits++;
      _entries[key] = cached; // move to most-recent
      return cached;
    }
    misses++;
    final future = rasterizeBubble(
      text,
      role: role,
      palette: palette,
      size: size,
      flat: flat,
      pixelRatio: pixelRatio,
    );
    _entries[key] = future;
    while (_entries.length > maxEntries) {
      // Not disposed: a component may still be drawing the evicted image;
      // it is released once nothing references it.
      _entries.remove(_entries.keys.first);
    }
    return future;
  }

  /// Drops all cached entries (images live on while still referenced).
  void clear() {
    _entries.clear();
    hits = misses = 0;
  }
}
