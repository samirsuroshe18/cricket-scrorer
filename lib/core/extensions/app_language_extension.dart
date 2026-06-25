import 'package:cricket_scorer/core/enums/app_language.dart';
import 'package:flutter/material.dart';

extension AppLanguageExtension on AppLanguage {
  String get countryCode {
    switch (this) {
      case AppLanguage.english:
        return 'IN';
      case AppLanguage.marathi:
        return 'IN';
      case AppLanguage.hindi:
        return 'IN';
    }
  }

  /// Locale('mr', 'IN'), Locale('hi', 'IN') etc.
  Locale get locale => Locale(code, countryCode);

  /// Get AppLanguage from language code string
  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.fallback,
    );
  }
}
