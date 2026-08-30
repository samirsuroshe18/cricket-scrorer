import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/dialogue/custom_dialog.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/services/secure_storages_service.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/request/logout_req.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/logout.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/delete_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_match_history.dart';
import 'package:get/get.dart';

/// The statuses `_promptIfNeeded` can still resume a console from — an
/// innings that's started but not finished, or a match that's been created
/// but never opened. Anything else (`completed`/`abandoned`) is terminal and
/// routes to the result screen instead.
const _liveStatuses = {'upcoming', 'live', 'innings_break'};

class HomeController extends GetxController {
  final LogoutUseCase logoutUseCase;
  final GetMatchHistoryUseCase getMatchHistoryUseCase;
  final DeleteMatchUseCase deleteMatchUseCase;

  HomeController({
    required this.logoutUseCase,
    required this.getMatchHistoryUseCase,
    required this.deleteMatchUseCase,
  });

  static const int _pageSize = 20;

  final matches = <MatchHistoryItem>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final loadError = Rxn<String>();
  int _page = 1;

  @override
  void onInit() {
    super.onInit();
    unawaited(loadHistory());
  }

  /// First page, replacing whatever list is already showing — the pull-to-
  /// refresh and initial-load entry point.
  Future<void> loadHistory() async {
    isLoading.value = true;
    loadError.value = null;
    _page = 1;

    final response = await getMatchHistoryUseCase(
      params: const GetMatchHistoryParams(page: 1, limit: _pageSize),
    );

    isLoading.value = false;

    if (response.isResult) {
      final data = response.result.data;
      matches.assignAll(data?.matches ?? []);
      hasMore.value = data?.hasMore ?? false;
    } else {
      loadError.value = response.fallback.message;
    }
  }

  /// Appends the next page — the list's own scroll-to-bottom trigger. A
  /// no-op while a load is already in flight or nothing is left, rather than
  /// a disabled affordance the scorer has to notice.
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;

    final response = await getMatchHistoryUseCase(
      params: GetMatchHistoryParams(page: _page + 1, limit: _pageSize),
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
      // Left `hasMore` untouched on purpose: a transient failure shouldn't
      // permanently hide the rest of the list. Scrolling back to the bottom
      // retries rather than needing a dedicated retry affordance.
      CricketSnackbar.showErrorMessage(response.fallback.message);
    }
  }

  /// Routes a tapped card to wherever that match can actually be acted on:
  /// still-live states reopen the scoring console (which resumes correctly
  /// from server state via `_promptIfNeeded`, the same as an app restart
  /// mid-match), terminal ones open the result screen.
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
            tossWinner: null,
            tossDecision: null,
            status: item.status,
            syncStatus: 'synced',
            createdAt: item.createdAt,
          ),
        ),
      );
    } else {
      unawaited(
        Get.toNamed<dynamic>(AppRoutes.matchResultPath(item.matchId)),
      );
    }
  }

  /// Matches with an in-flight delete — a card reads its own matchId out of
  /// this to show a spinner instead of the delete icon, rather than one
  /// global flag disabling every card's icon for a single card's request.
  final deletingMatchIds = <String>{}.obs;

  /// No success snackbar on purpose: the card disappearing from the list is
  /// already the confirmation. A failure still needs one, since there is no
  /// card left to visibly not-disappear from.
  Future<void> deleteMatch(MatchHistoryItem item) async {
    deletingMatchIds.add(item.matchId);

    final response = await deleteMatchUseCase(params: item.matchId);

    deletingMatchIds.remove(item.matchId);

    if (response.isResult) {
      matches.removeWhere((match) => match.matchId == item.matchId);
    } else {
      CricketSnackbar.showErrorMessage(response.fallback.message);
    }
  }

  Future<void> logout() async {
    try {
      CricketLoaderDialog.show();

      String? refreshToken = await SecureStorageService.secure.get(
        SharedPrefKey.refreshToken,
      );

      Either<CricketResponse<Map<String, dynamic>>, CricketFailure> response =
          await logoutUseCase(
            params: LogoutReq(refreshToken: refreshToken),
          );

      CricketLoaderDialog.hide();

      if (response.isResult) {
        await SharedPreferenceService.sharedPrefService.clearForLogout();
        await SecureStorageService.secure.clearForLogout();
        ApiClient.cancelAllRequests();

        unawaited(
          Get.offAllNamed(
            AppRoutes.login,
          ),
        );
        CricketSnackbar.showSuccessMessage(response.result.message);
      } else {
        CricketSnackbar.showErrorMessage(response.fallback.message);
      }
    } catch (_) {
      CricketSnackbar.showErrorMessage(
        TranslationKeys.failedToLogout.tr,
      );
    }
  }
}
