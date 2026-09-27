import 'package:cricket_scorer/core/translations/en.dart';
import 'package:cricket_scorer/core/translations/hi.dart';
import 'package:cricket_scorer/core/translations/mr.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter_test/flutter_test.dart';

/// `trParams` substitutes `@name` tokens, so a translation that drops or
/// renames one renders a sentence with a hole in it.
void main() {
  final maps = {'en': en, 'hi': hi, 'mr': mr};

  for (final MapEntry(key: language, value: map) in maps.entries) {
    test(
      '$language invite message keeps its inviter, team and player tokens',
      () {
        final text = map[TranslationKeys.playerInviteMessage]!;

        expect(text, contains('@inviter'));
        expect(text, contains('@team'));
        expect(text, contains('@player'));
      },
    );
  }
}
