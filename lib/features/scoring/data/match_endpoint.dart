class MatchEndpoint {
  const MatchEndpoint();

  final String createMatch = '/v1/match/create';

  String scoreBall(String matchId) => '/v1/match/$matchId/score-ball';
}
