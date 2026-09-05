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

  /// Encoded here, not by callers — the single point every caller (the
  /// code-entry sheet's manually-typed input, a resolved deep link) funnels
  /// through. The deep-link path is already structurally constrained (its
  /// own parsing regex excludes '/' and '?'), but a pasted code has no such
  /// guarantee, and encoding unconditionally is a no-op for an already-safe
  /// plain alphanumeric code either way.
  static String spectatorPath(String code) =>
      '/spectate/${Uri.encodeComponent(code)}';

  /// Registered with a GetX path parameter. Reachable two ways: automatically
  /// from `ScoreBallController._navigateToResult` on `match:complete`, or by
  /// direct navigation to a completed match's id later — both load the same
  /// way, from `GET .../scorecard`, so neither path is more authoritative
  /// than the other. Never navigate with this constant directly — use
  /// [matchResultPath].
  static const String matchResult = '/match/:matchId/result';

  static String matchResultPath(String matchId) => '/match/$matchId/result';

  /// Registered with a GetX path parameter, same shape as [matchResult].
  /// Never navigate with this constant directly — use [playerStatsPath].
  static const String playerStats = '/player/:playerId/stats';

  static String playerStatsPath(String playerId) => '/player/$playerId/stats';

  /// Registered with a GetX path parameter, same shape as [playerStats].
  /// Never navigate with this constant directly — use [teamProfilePath].
  static const String teamProfile = '/team/:teamId/profile';

  static String teamProfilePath(String teamId) => '/team/$teamId/profile';

  static const String organizations = '/organizations';

  /// Registered with a GetX path parameter, same shape as [teamProfile].
  /// Never navigate with this constant directly — use
  /// [organizationDetailPath].
  static const String organizationDetail = '/organization/:orgId';

  static String organizationDetailPath(String orgId) =>
      '/organization/$orgId';

  /// Registered with a GetX path parameter, same shape as
  /// [organizationDetail]. Never navigate with this constant directly —
  /// use [tournamentDetailPath].
  static const String tournamentDetail = '/tournament/:tournamentId';

  static String tournamentDetailPath(String tournamentId) =>
      '/tournament/$tournamentId';
}
