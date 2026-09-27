import 'dart:async';
import 'dart:io';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/dialogue/custom_dialog.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/add_team_player_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_team_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/set_team_leadership_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/update_team_player_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/looked_up_user_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_players_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/add_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_players.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/invite_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/lookup_user_by_email.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/remove_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/set_team_leadership.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_scorer_candidates.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/assign_scorer.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team_logo.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/delete_team.dart';
import 'package:get/get.dart';

/// The same still-live/terminal split `HomeController.openMatch` routes on —
/// duplicated here rather than shared, matching this file's own pagination
/// duplication (see class doc below).
const _liveStatuses = {'upcoming', 'live', 'innings_break'};

/// One team's profile: its identity/roster (a one-shot fetch) plus its
/// past results (a paginated list). The paginated half deliberately
/// duplicates `HomeController`'s own page/hasMore/isLoadingMore
/// hand-rolled-scroll-listener shape field-for-field, rather than sharing a
/// mixin — see the plan's design notes: extracting that logic risks
/// regressing `HomeController`'s already-shipped behavior for a shape this
/// is the only second user of.
class TeamProfileController extends GetxController {
  final GetTeamProfileUseCase getTeamProfileUseCase;
  final GetTeamMatchesUseCase getTeamMatchesUseCase;
  final GetScorerCandidatesUseCase getScorerCandidatesUseCase;
  final AssignScorerUseCase assignScorerUseCase;
  final UpdateTeamLogoUseCase updateTeamLogoUseCase;
  final UpdateTeamUseCase updateTeamUseCase;
  final DeleteTeamUseCase deleteTeamUseCase;
  final AddTeamPlayerUseCase addTeamPlayerUseCase;
  final UpdateTeamPlayerUseCase updateTeamPlayerUseCase;
  final RemoveTeamPlayerUseCase removeTeamPlayerUseCase;
  final SetTeamLeadershipUseCase setTeamLeadershipUseCase;
  final GetMyPlayersUseCase getMyPlayersUseCase;
  final LookupUserByEmailUseCase lookupUserByEmailUseCase;
  final InviteTeamPlayerUseCase inviteTeamPlayerUseCase;

  TeamProfileController({
    required this.teamId,
    required this.getTeamProfileUseCase,
    required this.getTeamMatchesUseCase,
    required this.getScorerCandidatesUseCase,
    required this.assignScorerUseCase,
    required this.updateTeamLogoUseCase,
    required this.updateTeamUseCase,
    required this.deleteTeamUseCase,
    required this.addTeamPlayerUseCase,
    required this.updateTeamPlayerUseCase,
    required this.removeTeamPlayerUseCase,
    required this.setTeamLeadershipUseCase,
    required this.getMyPlayersUseCase,
    required this.lookupUserByEmailUseCase,
    required this.inviteTeamPlayerUseCase,
  });

  static const int _pageSize = 20;

  /// The id this screen is showing — exposed so `MatchHistoryCard` can be
  /// told which side to omit from its title (`highlightTeamId`).
  final String teamId;

  final isLoadingProfile = true.obs;
  final profileError = Rxn<String>();
  final profile = Rxn<TeamProfileRes>();
  bool _isLoadingProfile = false;

  final matches = <MatchHistoryItem>[].obs;
  final isLoadingMatches = true.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final matchesError = Rxn<String>();
  int _page = 1;
  bool _isLoadingMatches = false;

  /// `all` / `live` / `upcoming` / `completed` — the server's `?status=`.
  final statusFilter = 'all'.obs;

  /// Bumped on every filter change. A matches response only applies if the
  /// generation it was requested under is still current, so a slow response
  /// for a previous chip can never overwrite the list a newer chip loaded.
  int _matchesGeneration = 0;

  @override
  void onInit() {
    super.onInit();

    if (teamId.isEmpty) {
      profileError.value = TranslationKeys.somethingWentWrong.tr;
      matchesError.value = TranslationKeys.somethingWentWrong.tr;
      isLoadingProfile.value = false;
      isLoadingMatches.value = false;
      return;
    }

    unawaited(loadProfile());
    unawaited(loadMatches());
  }

  Future<void> loadProfile() async {
    if (_isLoadingProfile) return;
    _isLoadingProfile = true;
    isLoadingProfile.value = true;
    profileError.value = null;

    final Either<CricketResponse<TeamProfileRes>, CricketFailure> response;
    try {
      response = await getTeamProfileUseCase(
        params: GetTeamProfileParams(teamId: teamId),
      );
    } on Object {
      profileError.value = TranslationKeys.somethingWentWrong.tr;
      return;
    } finally {
      isLoadingProfile.value = false;
      _isLoadingProfile = false;
    }

    if (response.isResult) {
      profile.value = response.result.data;
    } else {
      profileError.value = response.fallback.message;
    }
  }

  /// Uploads (or replaces) the team's logo, then re-fetches the profile so the
  /// new `logoUrl` shows immediately. A failure surfaces the server's own
  /// localized message (e.g. a 403 for a team the caller can't access) and
  /// leaves the profile untouched.
  Future<bool> updateLogo(File file) async {
    final response = await updateTeamLogoUseCase(
      params: UpdateTeamLogoParams(teamId: teamId, file: file),
    );
    if (!response.isResult) {
      CricketSnackbar.showErrorMessage(response.fallback.message);
      return false;
    }
    await loadProfile();
    return true;
  }

  /// Renames (and/or re-sets the short name of) the team, then re-fetches
  /// the profile so the new values show immediately — same
  /// refresh-after-write shape as [updateLogo]. Returns the server's own
  /// already-localized message on failure (e.g. a 403 for a team the
  /// caller can no longer manage), null on success.
  Future<String?> updateTeam({required String name, String? shortName}) async {
    final response = await updateTeamUseCase(
      params: UpdateTeamParams(
        teamId: teamId,
        req: CreateTeamReq(name: name, shortName: shortName),
      ),
    );
    if (!response.isResult) return response.fallback.message;
    await loadProfile();
    return null;
  }

  /// Soft-deletes the team. Returns the server's own already-localized
  /// message on failure — in particular the 409 refusal reasons
  /// (TEAM_IN_ACTIVE_MATCH/TEAM_IN_TOURNAMENT), which the caller shows
  /// verbatim rather than a generic error — null on success. Does not touch
  /// [profile]: the screen navigates away on success instead of re-rendering
  /// a deleted team's profile.
  Future<String?> deleteTeam() async {
    final response = await deleteTeamUseCase(
      params: DeleteTeamParams(teamId: teamId),
    );
    if (!response.isResult) return response.fallback.message;
    return null;
  }

  /// Switches the matches filter and reloads from page 1. Cancels the effect
  /// of any load still in flight for the previous filter (see
  /// [_matchesGeneration]) rather than waiting for it, so the new chip is never
  /// blocked behind a slow request.
  Future<void> setStatusFilter(String status) async {
    if (statusFilter.value == status) return;
    statusFilter.value = status;
    _matchesGeneration += 1;
    _isLoadingMatches = false;
    isLoadingMore.value = false;
    matches.clear();
    hasMore.value = true;
    await loadMatches();
  }

  /// First page, replacing whatever list is already showing — same shape as
  /// `HomeController.loadHistory`.
  Future<void> loadMatches() async {
    if (_isLoadingMatches) return;
    final generation = _matchesGeneration;
    _isLoadingMatches = true;
    isLoadingMatches.value = true;
    matchesError.value = null;
    _page = 1;

    final Either<CricketResponse<MatchHistoryRes>, CricketFailure> response;
    try {
      response = await getTeamMatchesUseCase(
        params: GetTeamMatchesParams(
          teamId: teamId,
          page: 1,
          limit: _pageSize,
          status: statusFilter.value,
        ),
      );
    } on Object {
      // A response that fails to parse throws out of the use case rather than
      // coming back as a failure; without this the list would spin forever.
      if (generation == _matchesGeneration) {
        matchesError.value = TranslationKeys.somethingWentWrong.tr;
      }
      return;
    } finally {
      if (generation == _matchesGeneration) {
        isLoadingMatches.value = false;
        _isLoadingMatches = false;
      }
    }

    if (generation != _matchesGeneration) return;
    if (response.isResult) {
      final data = response.result.data;
      matches.assignAll(data?.matches ?? []);
      hasMore.value = data?.hasMore ?? false;
    } else {
      matchesError.value = response.fallback.message;
    }
  }

  /// Appends the next page — same shape as `HomeController.loadMore`.
  Future<void> loadMoreMatches() async {
    // Also while the first page is still loading (e.g. right after a filter
    // change): page 2 could otherwise land before page 1, be dropped by
    // `assignAll`, and leave `_page` advanced past matches never shown.
    if (isLoadingMore.value || _isLoadingMatches || !hasMore.value) return;
    final generation = _matchesGeneration;
    isLoadingMore.value = true;

    final Either<CricketResponse<MatchHistoryRes>, CricketFailure> response;
    try {
      response = await getTeamMatchesUseCase(
        params: GetTeamMatchesParams(
          teamId: teamId,
          page: _page + 1,
          limit: _pageSize,
          status: statusFilter.value,
        ),
      );
    } on Object {
      if (generation == _matchesGeneration) {
        CricketSnackbar.showErrorMessage(TranslationKeys.somethingWentWrong.tr);
      }
      return;
    } finally {
      if (generation == _matchesGeneration) isLoadingMore.value = false;
    }

    if (generation != _matchesGeneration) return;
    if (response.isResult) {
      final data = response.result.data;
      if (data != null) {
        matches.addAll(data.matches);
        hasMore.value = data.hasMore;
        _page += 1;
      }
    } else {
      CricketSnackbar.showErrorMessage(response.fallback.message);
    }
  }

  /// Adds a player to the roster by name. Returns null on success (the profile
  /// is re-fetched so the new row shows) or the server's own localized
  /// message on failure — shown inline by the sheet, not as a snackbar: a
  /// GetX snackbar is a route, so one still on screen would swallow the
  /// `Get.back()` that closes the sheet on a successful retry.
  Future<String?> addPlayer({
    required String name,
    String? role,
    int? jerseyNumber,
  }) async {
    final response = await addTeamPlayerUseCase(
      params: AddTeamPlayerParams(
        teamId: teamId,
        req: AddTeamPlayerReq(
          name: name,
          role: role,
          jerseyNumber: jerseyNumber,
        ),
      ),
    );
    return _afterRosterWrite(response);
  }

  /// Adds one of the scorer's own existing players (from [loadMyPlayers]) to
  /// the roster by id. Same contract as [addPlayer].
  Future<String?> addExistingPlayer(String playerId) async {
    final response = await addTeamPlayerUseCase(
      params: AddTeamPlayerParams(
        teamId: teamId,
        req: AddTeamPlayerReq(playerId: playerId),
      ),
    );
    return _afterRosterWrite(response);
  }

  /// Invites an app user (found with [lookupUserByEmail]) onto the roster: the
  /// player is added immediately and the person links it by accepting. The
  /// profile is re-fetched so the new row shows, with its "Invited" chip. Same
  /// error contract as [addPlayer].
  Future<String?> inviteUser(String userId) async {
    final response = await inviteTeamPlayerUseCase(
      params: InviteTeamPlayerParams(teamId: teamId, userId: userId),
    );
    return _afterRosterWrite(response);
  }

  /// One page of the scorer's own players for the picker, each flagged
  /// `onTeam` for this team. Returns the server's own message on failure
  /// rather than showing a snackbar, for the same reason as [addPlayer].
  Future<(MyPlayersRes?, String?)> loadMyPlayers({
    String q = '',
    int page = 1,
  }) async {
    final response = await getMyPlayersUseCase(
      params: GetMyPlayersParams(teamId: teamId, q: q, page: page),
    );
    if (!response.isResult) return (null, response.fallback.message);
    return (response.result.data, null);
  }

  /// Finds one app user by exact email (trimmed). `(null, message)` when there
  /// is no such account or the request failed.
  Future<(LookedUpUserRes?, String?)> lookupUserByEmail(String email) async {
    final response = await lookupUserByEmailUseCase(
      params: LookupUserParams(email: email.trim()),
    );
    if (!response.isResult) return (null, response.fallback.message);
    return (response.result.data, null);
  }

  /// Edits a rostered player's role and/or jersey number ([clearJerseyNumber]
  /// removes it); same contract as [addPlayer].
  Future<String?> updatePlayer({
    required String playerId,
    String? role,
    int? jerseyNumber,
    bool clearJerseyNumber = false,
  }) async {
    final response = await updateTeamPlayerUseCase(
      params: UpdateTeamPlayerParams(
        teamId: teamId,
        playerId: playerId,
        req: UpdateTeamPlayerReq(
          role: role,
          jerseyNumber: jerseyNumber,
          clearJerseyNumber: clearJerseyNumber,
        ),
      ),
    );
    return _afterRosterWrite(response);
  }

  /// Removes a player from the roster (never the `Player` document itself,
  /// which may sit on other teams); same contract as [addPlayer]. Cancels any
  /// invite that player still had pending, server-side.
  Future<String?> removePlayer({required String playerId}) async {
    final response = await removeTeamPlayerUseCase(
      params: RemoveTeamPlayerParams(teamId: teamId, playerId: playerId),
    );
    return _afterRosterWrite(response);
  }

  /// Makes [playerId] the captain (or vice-captain when [viceCaptain]). If that
  /// player currently holds the other slot they are moved rather than
  /// duplicated — the server rejects the same player in both. Same contract
  /// as [addPlayer].
  Future<String?> setLeader({
    required String playerId,
    required bool viceCaptain,
  }) {
    final current = profile.value;
    if (current == null) {
      return Future.value(TranslationKeys.somethingWentWrong.tr);
    }
    final otherSlot = viceCaptain ? current.captainId : current.viceCaptainId;
    final keptOther = otherSlot == playerId ? null : otherSlot;
    return _writeLeaders(
      current,
      captainId: viceCaptain ? keptOther : playerId,
      viceCaptainId: viceCaptain ? playerId : keptOther,
    );
  }

  /// Clears the captain (or vice-captain when [viceCaptain]), keeping the
  /// other. Same contract as [addPlayer].
  Future<String?> clearLeader({required bool viceCaptain}) {
    final current = profile.value;
    if (current == null) {
      return Future.value(TranslationKeys.somethingWentWrong.tr);
    }
    return _writeLeaders(
      current,
      captainId: viceCaptain ? current.captainId : null,
      viceCaptainId: viceCaptain ? null : current.viceCaptainId,
    );
  }

  Future<String?> _writeLeaders(
    TeamProfileRes current, {
    required String? captainId,
    required String? viceCaptainId,
  }) async {
    // PATCH /v1/team/:teamId still requires `name`, so the current name and
    // short name are sent back unchanged.
    final response = await setTeamLeadershipUseCase(
      params: SetTeamLeadershipParams(
        teamId: teamId,
        req: SetTeamLeadershipReq(
          name: current.name,
          shortName: current.shortName,
          captainId: captainId,
          viceCaptainId: viceCaptainId,
        ),
      ),
    );
    return _afterRosterWrite(response);
  }

  Future<String?> _afterRosterWrite<T>(
    Either<CricketResponse<T>, CricketFailure> response,
  ) async {
    if (!response.isResult) return response.fallback.message;
    await loadProfile();
    return null;
  }

  /// The picker source for the assign-scorer sheet. Returns `null` (with
  /// the server's own error already shown) on failure — a 403 here means
  /// the viewer has no assign-authority on this match at all, which the
  /// sheet caller treats the same as any other failure: don't open it.
  Future<List<MatchUserRef>?> loadScorerCandidates(String matchId) async {
    // The assign sheet only opens once this returns, and the actions sheet
    // that launched it has already closed — without a loader the screen just
    // sits there for the length of the request. Hidden before the failure
    // snackbar below, not after: hide() closes every snackbar.
    CricketLoaderDialog.show();
    final response = await getScorerCandidatesUseCase(
      params: GetScorerCandidatesParams(matchId: matchId),
    );
    CricketLoaderDialog.hide();
    if (response.isResult) {
      return response.result.data?.candidates ?? [];
    }
    CricketSnackbar.showErrorMessage(response.fallback.message);
    return null;
  }

  /// Assigns/reassigns (`scorerId`) or clears (`null`) the delegated
  /// scorer, and patches the cached list entry in place so the card's
  /// label updates without a full reload.
  Future<bool> assignScorer(String matchId, String? scorerId) async {
    // The assign sheet is still open behind this, so a tap on a name would
    // otherwise look like nothing happened until the request returned. The
    // loader is hidden before the failure snackbar below, not after: hide()
    // closes every snackbar, and the sheet is closed by the caller only once
    // this returns, so the loader route is already gone by then.
    CricketLoaderDialog.show();
    final response = await assignScorerUseCase(
      params: AssignScorerParams(matchId: matchId, scorerId: scorerId),
    );
    CricketLoaderDialog.hide();
    if (!response.isResult) {
      CricketSnackbar.showErrorMessage(response.fallback.message);
      return false;
    }
    final index = matches.indexWhere((item) => item.matchId == matchId);
    if (index != -1) {
      matches[index] = matches[index].copyWith(
        assignedScorer: response.result.data?.assignedScorer,
      );
    }
    return true;
  }

  /// Same routing rule as `HomeController.openMatch`: still-live states
  /// reopen the scoring console, terminal ones open the result screen.
  void openMatch(MatchHistoryItem item) {
    if (_liveStatuses.contains(item.status)) {
      unawaited(
        Get.toNamed<dynamic>(
          AppRoutes.scoreBall,
          arguments: CreateMatchRes(
            matchId: item.matchId,
            joinCode: item.joinCode,
            teamA: item.teamA,
            teamB: item.teamB,
            totalOvers: item.totalOvers,
            tossWinner: item.tossWinner,
            tossDecision: item.tossDecision,
            status: item.status,
            syncStatus: 'synced',
            createdAt: item.createdAt,
          ),
        ),
      );
    } else {
      unawaited(Get.toNamed<dynamic>(AppRoutes.matchResultPath(item.matchId)));
    }
  }
}
