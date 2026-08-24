class MatchEndpoint {
  const MatchEndpoint();

  final String createMatch = '/v1/match/create';

  String startInnings(String matchId) => '/v1/match/$matchId/start-innings';

  String selectBowler(String matchId) => '/v1/match/$matchId/select-bowler';

  String scoreBall(String matchId) => '/v1/match/$matchId/score-ball';
}
