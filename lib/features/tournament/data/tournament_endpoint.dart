class TournamentEndpoint {
  const TournamentEndpoint();

  String createUnderOrg(String orgId) => '/v1/organization/$orgId/tournaments';

  String detail(String tournamentId) => '/v1/tournament/$tournamentId';

  String update(String tournamentId) => '/v1/tournament/$tournamentId';

  String delete(String tournamentId) => '/v1/tournament/$tournamentId';

  String addTeam(String tournamentId) => '/v1/tournament/$tournamentId/teams';

  String removeTeam(String tournamentId, String teamId) =>
      '/v1/tournament/$tournamentId/teams/$teamId';

  String fixtures(String tournamentId) =>
      '/v1/tournament/$tournamentId/fixtures';

  String resolveFixture(String tournamentId, String fixtureId) =>
      '/v1/tournament/$tournamentId/fixtures/$fixtureId';

  String startFixtureMatch(String tournamentId, String fixtureId) =>
      '/v1/tournament/$tournamentId/fixtures/$fixtureId/start-match';

  String standings(String tournamentId) =>
      '/v1/tournament/$tournamentId/standings';

  String leaderboards(String tournamentId) =>
      '/v1/tournament/$tournamentId/leaderboards';

  String pool(String tournamentId) => '/v1/tournament/$tournamentId/pool';

  String poolEntry(String tournamentId, String playerId) =>
      '/v1/tournament/$tournamentId/pool/$playerId';

  String auctionSetup(String tournamentId) =>
      '/v1/tournament/$tournamentId/auction-setup';

  String auctionStart(String tournamentId) =>
      '/v1/tournament/$tournamentId/auction/start';

  String auctionPause(String tournamentId) =>
      '/v1/tournament/$tournamentId/auction/pause';

  String auctionResume(String tournamentId) =>
      '/v1/tournament/$tournamentId/auction/resume';

  String auctionNext(String tournamentId) =>
      '/v1/tournament/$tournamentId/auction/next';
}
