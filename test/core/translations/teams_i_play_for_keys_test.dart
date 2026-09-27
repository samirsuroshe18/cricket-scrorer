import 'package:cricket_scorer/core/translations/en.dart';
import 'package:cricket_scorer/core/translations/hi.dart';
import 'package:cricket_scorer/core/translations/mr.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final maps = {'en': en, 'hi': hi, 'mr': mr};
  const keys = [
    TranslationKeys.teamsIPlayFor,
    TranslationKeys.playingAs,
    TranslationKeys.readOnlyTeamNote,
  ];

  for (final MapEntry(key: language, value: map) in maps.entries) {
    test('$language has every teams-I-play-for string', () {
      for (final key in keys) {
        expect(map[key], isNotNull, reason: '$language is missing $key');
        expect(map[key]!.trim(), isNotEmpty);
      }
    });

    test('$language keeps the @player token in playingAs', () {
      expect(map[TranslationKeys.playingAs], contains('@player'));
    });
  }
}
