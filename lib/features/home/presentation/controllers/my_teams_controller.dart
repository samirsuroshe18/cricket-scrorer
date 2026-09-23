import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_team_req.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization_team.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_team_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/create_team.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:get/get.dart';

/// Every team the caller has ever created or played under — ad-hoc and
/// organization-owned alike, per `GET /v1/team`. Wires the existing
/// [GetMyTeamsUseCase] (already used by `CreateMatchController`'s
/// reuse-a-team picker) into a destination of its own for the first time —
/// the Teams tab — and creates new teams for it.
class MyTeamsController extends GetxController {
  final GetMyTeamsUseCase getMyTeamsUseCase;
  final CreateTeamUseCase createTeamUseCase;
  final CreateOrganizationTeamUseCase createOrganizationTeamUseCase;

  MyTeamsController({
    required this.getMyTeamsUseCase,
    required this.createTeamUseCase,
    required this.createOrganizationTeamUseCase,
  });

  static const int _pageSize = 20;

  final teams = <TeamSummary>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final loadError = Rxn<String>();
  int _page = 1;

  @override
  void onInit() {
    super.onInit();
    loadMyTeams();
  }

  /// First page — also what a pull-to-refresh and a post-create reload fall
  /// back to, so either one collapses whatever was paged in via
  /// [loadMoreTeams] back to page 1. Same reset-on-refresh behavior as
  /// `HomeController.loadHistory`.
  Future<void> loadMyTeams() async {
    isLoading.value = true;
    loadError.value = null;
    _page = 1;

    final response = await getMyTeamsUseCase(
      params: const GetMyTeamsParams(page: 1, limit: _pageSize),
    );

    isLoading.value = false;

    if (response.isResult) {
      final data = response.result.data;
      teams.assignAll(data?.teams ?? []);
      hasMore.value = data?.hasMore ?? false;
    } else {
      loadError.value = response.fallback.message;
    }
  }

  /// Appends the next page — the "See all" list's own load-more affordance.
  /// A no-op while a load is already in flight or nothing is left, rather
  /// than a disabled affordance the caller has to notice. Same shape as
  /// `HomeController.loadMore`/`TeamProfileController.loadMoreMatches`.
  Future<void> loadMoreTeams() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;

    final response = await getMyTeamsUseCase(
      params: GetMyTeamsParams(page: _page + 1, limit: _pageSize),
    );

    isLoadingMore.value = false;

    if (response.isResult) {
      final data = response.result.data;
      if (data != null) {
        teams.addAll(data.teams);
        hasMore.value = data.hasMore;
        _page += 1;
      }
    } else {
      // Left `hasMore` untouched on purpose: a transient failure shouldn't
      // permanently hide the rest of the list. Tapping load-more again
      // retries rather than needing a dedicated retry affordance.
      CricketSnackbar.showErrorMessage(response.fallback.message);
    }
  }

  /// Creates a team and puts it at the top of [teams] straight away, then
  /// reloads [teams] from the server. With no [organizationId] the team is
  /// standalone (`POST /v1/team`); with one it is created under that
  /// organization, which the caller must own
  /// (`POST /v1/organization/:orgId/teams`); [organizationName] is only used
  /// to show that organization on the row until the reload replaces it.
  ///
  /// Adding the team before the reload means a failed reload cannot leave a
  /// team that exists missing from the screen (the refresh-failed strip still
  /// shows). Returns null on success, otherwise the server's already-localized
  /// message for the caller to show.
  ///
  /// A failure that carries no HTTP status (timeout, no connection) or a 5xx
  /// may hide a create that did reach the server, so it reloads [teams] too:
  /// the sheet's duplicate check then sees that team instead of letting a
  /// retry create a second one. A 4xx is the server saying no, so nothing
  /// changed and nothing is reloaded.
  Future<String?> createTeam({
    required String name,
    String? shortName,
    String? organizationId,
    String? organizationName,
  }) async {
    final TeamSummary? created;
    if (organizationId == null) {
      final response = await createTeamUseCase(
        params: CreateTeamReq(name: name, shortName: shortName),
      );
      if (!response.isResult) return _afterFailure(response.fallback);
      final data = response.result.data;
      created = data == null
          ? null
          : TeamSummary(
              id: data.id,
              name: data.name,
              shortName: data.shortName,
            );
    } else {
      final response = await createOrganizationTeamUseCase(
        params: CreateOrganizationTeamParams(
          orgId: organizationId,
          req: CreateOrganizationTeamReq(name: name, shortName: shortName),
        ),
      );
      if (!response.isResult) return _afterFailure(response.fallback);
      final data = response.result.data;
      created = data == null
          ? null
          : TeamSummary(
              id: data.id,
              name: data.name,
              shortName: data.shortName,
              organization: organizationName == null
                  ? null
                  : OrganizationRef(id: organizationId, name: organizationName),
            );
    }

    if (created != null) teams.insert(0, created);
    await loadMyTeams();
    return null;
  }

  Future<String> _afterFailure(CricketFailure failure) async {
    final status = failure.statusCode;
    if (status == null || status >= 500) await loadMyTeams();
    return failure.message;
  }
}
