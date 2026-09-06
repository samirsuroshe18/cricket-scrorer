class OrganizationEndpoint {
  const OrganizationEndpoint();

  final String create = '/v1/organization';
  final String listMine = '/v1/organization';

  String detail(String orgId) => '/v1/organization/$orgId';

  String addMember(String orgId) => '/v1/organization/$orgId/members';

  String removeMember(String orgId, String userId) =>
      '/v1/organization/$orgId/members/$userId';

  String createTeam(String orgId) => '/v1/organization/$orgId/teams';

  String delete(String orgId) => '/v1/organization/$orgId';

  String leaderboards(String orgId) => '/v1/organization/$orgId/leaderboards';
}
