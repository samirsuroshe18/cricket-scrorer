class MatchEndpoint {
  const MatchEndpoint();

  final String createMatch = '/v1/match/create';

  final String history = '/v1/match/history';

  /// `GET /v1/team` — the caller's own teams, source for the "reuse this
  /// team" picker on `CreateMatchScreen`.
  final String myTeams = '/v1/team';

  /// `GET /v1/team/:teamId` — always a server-generated ObjectId hex string,
  /// same as `startInnings`/`scoreBall`/etc.'s `matchId` above; no encoding
  /// needed, unlike `publicMatch`'s user-suppliable `code`.
  String teamProfile(String teamId) => '/v1/team/$teamId';

  /// `GET /v1/team/:teamId/matches` — byte-for-byte the same response shape
  /// as [history], scoped to one team.
  String teamMatches(String teamId) => '/v1/team/$teamId/matches';

  String startInnings(String matchId) => '/v1/match/$matchId/start-innings';

  String selectBowler(String matchId) => '/v1/match/$matchId/select-bowler';

  String scoreBall(String matchId) => '/v1/match/$matchId/score-ball';

  String undoBall(String matchId) => '/v1/match/$matchId/undo-ball';

  String sync(String matchId) => '/v1/match/$matchId/sync';

  String scorecard(String matchId) => '/v1/match/$matchId/scorecard';

  // Not match-scoped — Player is scorer-scoped, persistent across matches
  // (see docs/api.md's player-identity rework) — but reuses this same
  // client/service/repository rather than a whole parallel vertical slice
  // for one endpoint, matching how every other scoring-domain read already
  // shares this one chain.
  String careerStats(String playerId) => '/v1/player/$playerId/career-stats';

  String playerProfile(String playerId) => '/v1/player/$playerId';

  String abandon(String matchId) => '/v1/match/$matchId/abandon';

  String delete(String matchId) => '/v1/match/$matchId';

  // Encoded here, not by callers: unlike `matchId` above (always a
  // server-generated ObjectId hex string), `code` can be raw user input —
  // typed into the spectate-by-code sheet or read off a deep link. Both of
  // those happen to hand this a value that's already path-safe today (the
  // sheet only trims, but a 6-char share code is alphanumeric in practice;
  // the deep-link regex excludes '/' and '?', and a URI's own `.path` never
  // contains '#'), so nothing currently breaks without this — but that's a
  // property of today's two callers, not of this method, and a future one
  // (e.g. a code pulled straight off an OS share-sheet payload) gets no
  // protection unless the encoding lives here.
  String publicMatch(String code) =>
      '/v1/match/public/${Uri.encodeComponent(code)}';

  /// `PATCH /v1/team/:teamId/organization` — attach/detach. Lives here, not
  /// on `OrganizationEndpoint`, because the route itself is under `/v1/team`
  /// — see docs/api.md's `## Organization` section.
  String updateTeamOrganization(String teamId) =>
      '/v1/team/$teamId/organization';

  /// `GET /v1/match/:matchId/scorer-candidates` — who a caller with assign-
  /// authority can pick from.
  String scorerCandidates(String matchId) =>
      '/v1/match/$matchId/scorer-candidates';

  /// `PATCH /v1/match/:matchId/scorer` — assign/reassign (`scorerId`) or
  /// clear (`scorerId: null`) the delegated scorer on this match.
  String assignScorer(String matchId) => '/v1/match/$matchId/scorer';
}
