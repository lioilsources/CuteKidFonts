import 'dart:typed_data';

/// Minimal TrueType `cmap` reader: returns every code point mapped to a
/// non-zero glyph (formats 4 and 12, Unicode subtables only).
Set<int> readCmap(Uint8List bytes) {
  final d = ByteData.sublistView(bytes);
  final numTables = d.getUint16(4);
  int? cmapOffset;
  for (var i = 0; i < numTables; i++) {
    final rec = 12 + i * 16;
    final tag = String.fromCharCodes(bytes.sublist(rec, rec + 4));
    if (tag == 'cmap') cmapOffset = d.getUint32(rec + 8);
  }
  if (cmapOffset == null) throw StateError('no cmap table');
  final result = <int>{};
  final n = d.getUint16(cmapOffset + 2);
  for (var i = 0; i < n; i++) {
    final rec = cmapOffset + 4 + i * 8;
    final platform = d.getUint16(rec);
    final encoding = d.getUint16(rec + 2);
    final unicode = platform == 0 || (platform == 3 && (encoding == 1 || encoding == 10));
    if (!unicode) continue;
    final sub = cmapOffset + d.getUint32(rec + 4);
    switch (d.getUint16(sub)) {
      case 4:
        final segX2 = d.getUint16(sub + 6);
        final ends = sub + 14;
        final starts = ends + segX2 + 2;
        final deltas = starts + segX2;
        final ranges = deltas + segX2;
        for (var s = 0; s < segX2 ~/ 2; s++) {
          final end = d.getUint16(ends + s * 2);
          final start = d.getUint16(starts + s * 2);
          final delta = d.getInt16(deltas + s * 2);
          final rangeAt = ranges + s * 2;
          final range = d.getUint16(rangeAt);
          for (var c = start; c <= end && c != 0xFFFF; c++) {
            int glyph;
            if (range == 0) {
              glyph = (c + delta) & 0xFFFF;
            } else {
              final g = d.getUint16(rangeAt + range + (c - start) * 2);
              glyph = g == 0 ? 0 : (g + delta) & 0xFFFF;
            }
            if (glyph != 0) result.add(c);
          }
        }
      case 12:
        final groups = d.getUint32(sub + 12);
        for (var g = 0; g < groups; g++) {
          final at = sub + 16 + g * 12;
          final start = d.getUint32(at);
          final end = d.getUint32(at + 4);
          final glyph = d.getUint32(at + 8);
          for (var c = start; c <= end; c++) {
            if (glyph + (c - start) != 0) result.add(c);
          }
        }
    }
  }
  return result;
}
