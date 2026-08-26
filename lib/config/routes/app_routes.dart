class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String forgotPassword = '/forgot-password';
  static const String setPassword = '/set-password';
  static const String onBoarding = '/on-boarding';
  static const String updateProfile = '/update-profile';
  static const String imagePreview = '/image_preview';
  static const String createMatch = '/create-match';
  static const String scoreBall = '/score-ball';

  /// Registered with a GetX path parameter, matching the deep link
  /// `PendingDeepLink` parses and the path `WatchMatchBottomSheet` builds.
  /// Never navigate with this constant directly — use [spectatorPath].
  static const String spectator = '/spectate/:code';

  static String spectatorPath(String code) => '/spectate/$code';

  /// Registered with a GetX path parameter. Reachable two ways: automatically
  /// from `ScoreBallController._navigateToResult` on `match:complete`, or by
  /// direct navigation to a completed match's id later — both load the same
  /// way, from `GET .../scorecard`, so neither path is more authoritative
  /// than the other. Never navigate with this constant directly — use
  /// [matchResultPath].
  static const String matchResult = '/match/:matchId/result';

  static String matchResultPath(String matchId) => '/match/$matchId/result';
}
