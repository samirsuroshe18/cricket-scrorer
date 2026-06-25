enum AppLanguage {
  english('en', 'English'),
  marathi('mr', 'Marathi'),
  hindi('hi', 'Hindi')
  ;

  final String code;
  final String label;

  const AppLanguage(this.code, this.label);

  /// Check if language code is supported
  static bool isSupported(String code) {
    return AppLanguage.values.any((lang) => lang.code == code);
  }

  static AppLanguage get fallback => AppLanguage.english;
}
