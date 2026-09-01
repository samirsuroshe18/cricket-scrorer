import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:get/get.dart';

class Validators {
  Validators._();

  // Mirrors the backend's MIN_PASSWORD_LENGTH (password.constants.js) — keep
  // the two in sync, or a password this form accepts as valid can still be
  // rejected by the server with PASSWORD_TOO_SHORT.
  static const int _minPasswordLength = 8;

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.emailRequired.tr;
    }

    if (!GetUtils.isEmail(value.trim())) {
      return TranslationKeys.enterValidEmail.tr;
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.passwordRequired.tr;
    }

    // Checked on the same trimmed value as the emptiness check above, not
    // the raw one — otherwise padding with spaces (e.g. "a     ", one real
    // character plus five spaces) satisfies a length check that never
    // trimmed, while still reading as non-empty to the check above it.
    if (value.trim().length < _minPasswordLength) {
      return TranslationKeys.passwordTooShort.tr;
    }

    return null;
  }
}
