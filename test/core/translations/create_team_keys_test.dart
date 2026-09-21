import 'package:cricket_scorer/core/translations/en.dart';
import 'package:cricket_scorer/core/translations/hi.dart';
import 'package:cricket_scorer/core/translations/mr.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every string the create-team sheet shows must exist in the bundled maps,
/// not only in the CMS: the bundled maps are what renders before the first
/// successful translation sync, and a key missing there shows as raw
/// snake_case text.
void main() {
  const keys = {
    'createTeam': TranslationKeys.createTeam,
    'teamName': TranslationKeys.teamName,
    'teamShortName': TranslationKeys.teamShortName,
    'teamBelongsTo': TranslationKeys.teamBelongsTo,
    'teamIndependent': TranslationKeys.teamIndependent,
    'teamNameExists': TranslationKeys.teamNameExists,
    'teamNameRequired': TranslationKeys.teamNameRequired,
    'teamNameTooLong': TranslationKeys.teamNameTooLong,
    'teamShortNameTooLong': TranslationKeys.teamShortNameTooLong,
    'teamCreated': TranslationKeys.teamCreated,
  };
  final maps = {'en': en, 'hi': hi, 'mr': mr};

  for (final MapEntry(key: language, value: map) in maps.entries) {
    test('$language has every create-team string', () {
      final missing = [
        for (final entry in keys.entries)
          if ((map[entry.value] ?? '').trim().isEmpty) entry.key,
      ];

      expect(missing, isEmpty);
    });
  }
}
