class MatchEndpoint {
  const MatchEndpoint();

  final String createMatch = '/v1/match/create';

  final String history = '/v1/match/history';

  String startInnings(String matchId) => '/v1/match/$matchId/start-innings';

  String selectBowler(String matchId) => '/v1/match/$matchId/select-bowler';

  String scoreBall(String matchId) => '/v1/match/$matchId/score-ball';

  String undoBall(String matchId) => '/v1/match/$matchId/undo-ball';

  String sync(String matchId) => '/v1/match/$matchId/sync';

  String scorecard(String matchId) => '/v1/match/$matchId/scorecard';

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
  String publicMatch(String code) => '/v1/match/public/${Uri.encodeComponent(code)}';
}
