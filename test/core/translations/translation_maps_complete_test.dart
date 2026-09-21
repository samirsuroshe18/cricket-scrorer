import 'dart:io';

import 'package:cricket_scorer/core/translations/en.dart';
import 'package:cricket_scorer/core/translations/hi.dart';
import 'package:cricket_scorer/core/translations/mr.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every key declared in `translation_keys.dart` must have text in all three
/// bundled maps. The CMS replaces these maps once translations sync, but the
/// bundled maps are what renders before the first successful sync (an offline
/// first launch), and a key missing there shows as raw snake_case text.
///
/// Declarations are read from the source file because Dart has no reflection
/// over `static const` fields; the pattern tolerates a value on the next line.
void main() {
  final declared = RegExp(r"static const String (\w+)\s*=\s*'([^']*)'\s*;")
      .allMatches(
        File('lib/core/translations/translation_keys.dart').readAsStringSync(),
      )
      .map((m) => (name: m.group(1)!, key: m.group(2)!))
      .toList();

  test('the declared keys were actually found', () {
    expect(declared.length, greaterThan(400));
  });

  final maps = {'en': en, 'hi': hi, 'mr': mr};
  for (final MapEntry(key: language, value: map) in maps.entries) {
    test('$language has text for every declared key', () {
      final missing = [
        for (final d in declared)
          if ((map[d.key] ?? '').trim().isEmpty) d.name,
      ];

      expect(missing, isEmpty);
    });
  }
}
