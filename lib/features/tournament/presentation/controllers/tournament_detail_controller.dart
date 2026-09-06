import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/generate_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resolve_fixture.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_fixture_match.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/update_tournament.dart';
import 'package:get/get.dart';

/// Returned by [TournamentDetailController.startFixtureMatch] — carries
/// either the created match (for the sheet to navigate on) or the specific
/// backend error message (for the sheet to show), never both.
class StartFixtureMatchOutcome {
  final CreateMatchRes? match;
  final String? errorMessage;

  const StartFixtureMatchOutcome.success(this.match) : errorMessage = null;

  const StartFixtureMatchOutcome.failure(this.errorMessage) : match = null;
}

/// One tournament's detail plus the owning organization's own detail — the
/// latter fetched purely to answer "is the viewer the owner" and "which of
/// this org's teams aren't enrolled yet," since
/// `GET /v1/tournament/:tournamentId` itself returns neither (see
/// docs/api.md — it only returns `organization: {id, name}`, no owner).
///
/// None of this controller's methods call `CricketSnackbar` directly —
/// a GetX snackbar needs a mounted navigator, which a plain `test()` block
/// (as opposed to `testWidgets()`) doesn't have. Every action instead
/// returns the specific backend message (or a small result type carrying
/// one) and leaves showing it to the screen/sheet that called it.
class TournamentDetailController extends GetxController {
  final String tournamentId;
  final String currentUserId;

  final GetTournamentUseCase getTournamentUseCase;
  final GetOrganizationUseCase getOrganizationUseCase;
  final UpdateTournamentUseCase updateTournamentUseCase;
  final DeleteTournamentUseCase deleteTournamentUseCase;
  final EnrollTournamentTeamUseCase enrollTournamentTeamUseCase;
  final RemoveTournamentTeamUseCase removeTournamentTeamUseCase;
  final GetFixturesUseCase getFixturesUseCase;
  final GenerateFixturesUseCase generateFixturesUseCase;
  final StartFixtureMatchUseCase startFixtureMatchUseCase;
  final ResolveFixtureUseCase resolveFixtureUseCase;

  TournamentDetailController({
    required this.tournamentId,
    required this.currentUserId,
    required this.getTournamentUseCase,
    required this.getOrganizationUseCase,
    required this.updateTournamentUseCase,
    required this.deleteTournamentUseCase,
    required this.enrollTournamentTeamUseCase,
    required this.removeTournamentTeamUseCase,
    required this.getFixturesUseCase,
    required this.generateFixturesUseCase,
    required this.startFixtureMatchUseCase,
    required this.resolveFixtureUseCase,
  });

  final detail = Rxn<TournamentDetailRes>();
  final organizationDetail = Rxn<OrganizationDetailRes>();
  final isLoading = true.obs;
  final loadError = Rxn<String>();
  final fixtures = <FixtureRes>[].obs;

  bool get isOwner => organizationDetail.value?.owner.id == currentUserId;

  /// The org's teams not already enrolled in this tournament — the source
  /// list for the "Enroll team" sheet.
  List<OrganizationTeamRef> get eligibleTeams {
    final orgTeams = organizationDetail.value?.teams ?? const [];
    final enrolledIds = detail.value?.teams.map((t) => t.id).toSet() ?? const {};
    return orgTeams.where((t) => !enrolledIds.contains(t.id)).toList();
  }

  /// Once any fixture exists, the backend locks the roster
  /// (`TOURNAMENT_FIXTURES_LOCKED`) — the screen hides enroll/remove
  /// actions to match, rather than surfacing that as an error.
  bool get fixturesGenerated => fixtures.isNotEmpty;

  int get _maxFixtureRound =>
      fixtures.isEmpty ? 0 : fixtures.map((f) => f.round).reduce((a, b) => a > b ? a : b);

  List<FixtureRes> get latestRoundFixtures =>
      fixtures.where((f) => f.round == _maxFixtureRound).toList();

  /// True only for a knockout whose current round is fully resolved and
  /// isn't already the final (a 1-fixture round) — the one case
  /// `POST .../fixtures` can be called again. round_robin/league generate
  /// their whole schedule in one call and are never re-callable.
  bool get canGenerateNextRound {
    if (detail.value?.format != 'knockout') return false;
    if (fixtures.isEmpty) return false;
    final latest = latestRoundFixtures;
    if (latest.length <= 1) return false;
    return latest.every((f) => f.status == 'bye' || f.status == 'completed');
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

    await _loadFixtures();

    isLoading.value = false;
  }

  Future<void> _loadFixtures() async {
    final response = await getFixturesUseCase(
      params: GetFixturesParams(tournamentId: tournamentId),
    );
    if (response.isResult) {
      fixtures.assignAll(response.result.data!);
    }
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

  /// Returns null on success, the backend's specific error message
  /// otherwise (e.g. "Not enough teams enrolled...", "Every fixture in the
  /// current round must be resolved...") — these are meaningful business
  /// rules the scorer needs to see verbatim, not a generic failure.
  Future<String?> generateFixtures() async {
    final response = await generateFixturesUseCase(
      params: GenerateFixturesParams(tournamentId: tournamentId),
    );
    if (!response.isResult) return response.fallback.message;
    await _loadFixtures();
    return null;
  }

  Future<StartFixtureMatchOutcome> startFixtureMatch(
    String fixtureId, {
    required int totalOvers,
    String? tossWinner,
    String? tossDecision,
  }) async {
    final response = await startFixtureMatchUseCase(
      params: StartFixtureMatchParams(
        tournamentId: tournamentId,
        fixtureId: fixtureId,
        totalOvers: totalOvers,
        tossWinner: tossWinner,
        tossDecision: tossDecision,
      ),
    );
    if (!response.isResult) {
      return StartFixtureMatchOutcome.failure(response.fallback.message);
    }
    final match = response.result.data;
    // A 2xx with no match body shouldn't happen per the API contract, but
    // treating it as success would hand the sheet a null match to navigate
    // on — surface it as a failure instead (the sheet falls back to a
    // generic message for a null errorMessage).
    if (match == null) {
      return const StartFixtureMatchOutcome.failure(null);
    }
    await _loadFixtures();
    return StartFixtureMatchOutcome.success(match);
  }

  Future<String?> resolveFixture(String fixtureId, String winnerTeamId) async {
    final response = await resolveFixtureUseCase(
      params: ResolveFixtureParams(
        tournamentId: tournamentId,
        fixtureId: fixtureId,
        winnerTeamId: winnerTeamId,
      ),
    );
    if (!response.isResult) return response.fallback.message;
    await _loadFixtures();
    return null;
  }
}
