class GlobalEndpoint {
  const GlobalEndpoint();

  final String getLangVersion = '/v1/translations/version';
  final String getLanguage = '/v1/translations/all';
  final String getUserLanguage = '/v1/user/language';
  final String updateLanguage = '/v1/user/language';
  static const String refreshToken = '/v1/user/refresh-token';
}
