import 'package:cricket_scorer/core/translations/hi.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'the Hindi OTP description uses Western digits, as the CMS serves it',
    () {
      final text = hi[TranslationKeys.otpVerificationDesc]!;

      expect(text, 'हमने @target पर 6-अंकीय कोड भेजा है');
      expect(RegExp('[०-९]').hasMatch(text), isFalse);
    },
  );
}
