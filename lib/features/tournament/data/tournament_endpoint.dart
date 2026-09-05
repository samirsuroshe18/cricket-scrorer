class TournamentEndpoint {
  const TournamentEndpoint();

  String createUnderOrg(String orgId) => '/v1/organization/$orgId/tournaments';

  String detail(String tournamentId) => '/v1/tournament/$tournamentId';

  String update(String tournamentId) => '/v1/tournament/$tournamentId';

  String delete(String tournamentId) => '/v1/tournament/$tournamentId';

  String addTeam(String tournamentId) => '/v1/tournament/$tournamentId/teams';

  String removeTeam(String tournamentId, String teamId) =>
      '/v1/tournament/$tournamentId/teams/$teamId';
}
