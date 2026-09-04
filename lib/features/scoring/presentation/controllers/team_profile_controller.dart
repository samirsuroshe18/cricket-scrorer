import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
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

  TeamProfileController({
    required this.teamId,
    required this.getTeamProfileUseCase,
    required this.getTeamMatchesUseCase,
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

    final response = await getTeamProfileUseCase(
      params: GetTeamProfileParams(teamId: teamId),
    );

    isLoadingProfile.value = false;
    _isLoadingProfile = false;

    if (response.isResult) {
      profile.value = response.result.data;
    } else {
      profileError.value = response.fallback.message;
    }
  }

  /// First page, replacing whatever list is already showing — same shape as
  /// `HomeController.loadHistory`.
  Future<void> loadMatches() async {
    if (_isLoadingMatches) return;
    _isLoadingMatches = true;
    isLoadingMatches.value = true;
    matchesError.value = null;
    _page = 1;

    final response = await getTeamMatchesUseCase(
      params: GetTeamMatchesParams(teamId: teamId, page: 1, limit: _pageSize),
    );

    isLoadingMatches.value = false;
    _isLoadingMatches = false;

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
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;

    final response = await getTeamMatchesUseCase(
      params: GetTeamMatchesParams(
        teamId: teamId,
        page: _page + 1,
        limit: _pageSize,
      ),
    );

    isLoadingMore.value = false;

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
