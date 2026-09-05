import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/update_tournament.dart';
import 'package:get/get.dart';

/// One tournament's detail plus the owning organization's own detail — the
/// latter fetched purely to answer "is the viewer the owner" and "which of
/// this org's teams aren't enrolled yet," since
/// `GET /v1/tournament/:tournamentId` itself returns neither (see
/// docs/api.md — it only returns `organization: {id, name}`, no owner).
class TournamentDetailController extends GetxController {
  final String tournamentId;
  final String currentUserId;

  final GetTournamentUseCase getTournamentUseCase;
  final GetOrganizationUseCase getOrganizationUseCase;
  final UpdateTournamentUseCase updateTournamentUseCase;
  final DeleteTournamentUseCase deleteTournamentUseCase;
  final EnrollTournamentTeamUseCase enrollTournamentTeamUseCase;
  final RemoveTournamentTeamUseCase removeTournamentTeamUseCase;

  TournamentDetailController({
    required this.tournamentId,
    required this.currentUserId,
    required this.getTournamentUseCase,
    required this.getOrganizationUseCase,
    required this.updateTournamentUseCase,
    required this.deleteTournamentUseCase,
    required this.enrollTournamentTeamUseCase,
    required this.removeTournamentTeamUseCase,
  });

  final detail = Rxn<TournamentDetailRes>();
  final organizationDetail = Rxn<OrganizationDetailRes>();
  final isLoading = true.obs;
  final loadError = Rxn<String>();

  bool get isOwner => organizationDetail.value?.owner.id == currentUserId;

  /// The org's teams not already enrolled in this tournament — the source
  /// list for the "Enroll team" sheet.
  List<OrganizationTeamRef> get eligibleTeams {
    final orgTeams = organizationDetail.value?.teams ?? const [];
    final enrolledIds = detail.value?.teams.map((t) => t.id).toSet() ?? const {};
    return orgTeams.where((t) => !enrolledIds.contains(t.id)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadDetail();
  }

  Future<void> loadDetail() async {
    isLoading.value = true;
    loadError.value = null;

    final response = await getTournamentUseCase(
      params: GetTournamentParams(tournamentId: tournamentId),
    );

    if (!response.isResult) {
      isLoading.value = false;
      loadError.value = response.fallback.message;
      return;
    }

    detail.value = response.result.data;

    final orgResponse = await getOrganizationUseCase(
      params: GetOrganizationParams(orgId: detail.value!.organization.id),
    );
    if (orgResponse.isResult) {
      organizationDetail.value = orgResponse.result.data;
    }

    isLoading.value = false;
  }

  Future<bool> updateTournament({String? name, String? format, String? status}) async {
    final response = await updateTournamentUseCase(
      params: UpdateTournamentParams(
        tournamentId: tournamentId,
        req: UpdateTournamentReq(name: name, format: format, status: status),
      ),
    );

    if (!response.isResult) return false;
    await loadDetail();
    return true;
  }

  Future<bool> deleteTournament() async {
    final response = await deleteTournamentUseCase(
      params: DeleteTournamentParams(tournamentId: tournamentId),
    );
    return response.isResult;
  }

  Future<bool> enrollTeam(String teamId) async {
    final response = await enrollTournamentTeamUseCase(
      params: EnrollTournamentTeamParams(
        tournamentId: tournamentId,
        teamId: teamId,
      ),
    );

    if (!response.isResult) return false;
    await loadDetail();
    return true;
  }

  Future<bool> removeTeam(String teamId) async {
    final response = await removeTournamentTeamUseCase(
      params: RemoveTournamentTeamParams(
        tournamentId: tournamentId,
        teamId: teamId,
      ),
    );

    if (!response.isResult) return false;
    await loadDetail();
    return true;
  }
}
