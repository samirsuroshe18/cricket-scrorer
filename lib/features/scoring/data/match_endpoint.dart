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

  String publicMatch(String code) => '/v1/match/public/$code';
}
