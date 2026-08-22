import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:get/get.dart';

class Validators {
  Validators._();

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

    if (value.length < 6) {
      return TranslationKeys.passwordTooShort.tr;
    }

    return null;
  }
}
