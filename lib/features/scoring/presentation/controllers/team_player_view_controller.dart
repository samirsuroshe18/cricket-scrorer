import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_player_view_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_player_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_player_view.dart';
import 'package:get/get.dart';

/// The read-only team screen for a linked roster player: the roster, the
/// team's stats and its matches. Deliberately has no write use case, so nothing
/// on this screen can change the team.
class TeamPlayerViewController extends GetxController {
  final String teamId;
  final GetTeamPlayerViewUseCase getTeamPlayerViewUseCase;
  final GetTeamPlayerMatchesUseCase getTeamPlayerMatchesUseCase;

  TeamPlayerViewController({
    required this.teamId,
    required this.getTeamPlayerViewUseCase,
    required this.getTeamPlayerMatchesUseCase,
  });

  static const int _pageSize = 20;

  final isLoadingProfile = true.obs;
  final profileError = Rxn<String>();
  final profile = Rxn<TeamPlayerViewRes>();
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

  /// Bumped on every filter change, so a slow response for a previous chip can
  /// never overwrite the list a newer chip loaded.
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

    final Either<CricketResponse<TeamPlayerViewRes>, CricketFailure> response;
    try {
      response = await getTeamPlayerViewUseCase(
        params: GetTeamPlayerViewParams(teamId: teamId),
      );
    } on Object {
      // A response that fails to parse throws out of the use case rather than
      // coming back as a failure; without this the screen would spin forever.
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

  Future<void> loadMatches() async {
    if (_isLoadingMatches) return;
    final generation = _matchesGeneration;
    _isLoadingMatches = true;
    isLoadingMatches.value = true;
    matchesError.value = null;
    _page = 1;

    final Either<CricketResponse<MatchHistoryRes>, CricketFailure> response;
    try {
      response = await getTeamPlayerMatchesUseCase(
        params: GetTeamPlayerMatchesParams(
          teamId: teamId,
          page: 1,
          limit: _pageSize,
          status: statusFilter.value,
        ),
      );
    } on Object {
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

  Future<void> loadMoreMatches() async {
    if (isLoadingMore.value || _isLoadingMatches || !hasMore.value) return;
    final generation = _matchesGeneration;
    isLoadingMore.value = true;

    final Either<CricketResponse<MatchHistoryRes>, CricketFailure> response;
    try {
      response = await getTeamPlayerMatchesUseCase(
        params: GetTeamPlayerMatchesParams(
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

  /// Only a match in play that carries a share code can be opened — in the
  /// spectator view, which needs no scorer rights. Everything else is shown but
  /// not tappable: the scoring console and the result screen are the scorer's.
  bool canOpen(MatchHistoryItem item) {
    final code = item.joinCode;
    return (item.status == 'live' || item.status == 'innings_break') &&
        code != null &&
        code.isNotEmpty;
  }

  void openMatch(MatchHistoryItem item) {
    if (!canOpen(item)) return;
    unawaited(Get.toNamed<dynamic>(AppRoutes.spectatorPath(item.joinCode!)));
  }
}
