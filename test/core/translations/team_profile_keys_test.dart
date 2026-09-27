import 'package:cricket_scorer/core/translations/en.dart';
import 'package:cricket_scorer/core/translations/hi.dart';
import 'package:cricket_scorer/core/translations/mr.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every string the team profile's stats strip, matches filter and roster
/// management show must exist in the bundled maps, not only in the CMS: the
/// bundled maps are what renders before the first successful translation
/// sync, and a key missing there shows as raw snake_case text.
void main() {
  const keys = {
    'teamMatchesSection': TranslationKeys.teamMatchesSection,
    'winPercentage': TranslationKeys.winPercentage,
    'recentForm': TranslationKeys.recentForm,
    'playerNameRequired': TranslationKeys.playerNameRequired,
    'makeCaptain': TranslationKeys.makeCaptain,
    'makeViceCaptain': TranslationKeys.makeViceCaptain,
    'removeCaptain': TranslationKeys.removeCaptain,
    'removeViceCaptain': TranslationKeys.removeViceCaptain,
    'formWon': TranslationKeys.formWon,
    'formLost': TranslationKeys.formLost,
    'formTied': TranslationKeys.formTied,
    'formNoResult': TranslationKeys.formNoResult,
  };
  final maps = {'en': en, 'hi': hi, 'mr': mr};

  for (final MapEntry(key: language, value: map) in maps.entries) {
    test('$language has every team profile string', () {
      final missing = [
        for (final entry in keys.entries)
          if ((map[entry.value] ?? '').trim().isEmpty) entry.key,
      ];

      expect(missing, isEmpty);
    });
  }
}
