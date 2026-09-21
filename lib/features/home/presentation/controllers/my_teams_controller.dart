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

  final teams = <TeamSummary>[].obs;
  final isLoading = true.obs;
  final loadError = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadMyTeams();
  }

  Future<void> loadMyTeams() async {
    isLoading.value = true;
    loadError.value = null;

    final response = await getMyTeamsUseCase();

    isLoading.value = false;

    if (response.isResult) {
      teams.assignAll(response.result.data?.teams ?? []);
    } else {
      loadError.value = response.fallback.message;
    }
  }

  /// Creates a team, then reloads [teams] so it shows up. With no
  /// [organizationId] the team is standalone (`POST /v1/team`); with one it is
  /// created under that organization, which the caller must own
  /// (`POST /v1/organization/:orgId/teams`).
  ///
  /// Returns null on success, otherwise the server's already-localized
  /// message for the caller to show; nothing is reloaded on failure.
  Future<String?> createTeam({
    required String name,
    String? shortName,
    String? organizationId,
  }) async {
    if (organizationId == null) {
      final response = await createTeamUseCase(
        params: CreateTeamReq(name: name, shortName: shortName),
      );
      if (!response.isResult) return response.fallback.message;
    } else {
      final response = await createOrganizationTeamUseCase(
        params: CreateOrganizationTeamParams(
          orgId: organizationId,
          req: CreateOrganizationTeamReq(name: name, shortName: shortName),
        ),
      );
      if (!response.isResult) return response.fallback.message;
    }

    await loadMyTeams();
    return null;
  }
}
