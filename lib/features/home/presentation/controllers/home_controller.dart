import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/global/widgets/dialogue/custom_dialog.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/services/secure_storages_service.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:cricket_scorer/core/utils/current_user.dart';
import 'package:cricket_scorer/features/auth/data/models/request/logout_req.dart';
import 'package:cricket_scorer/features/auth/data/models/user.dart';
import 'package:cricket_scorer/core/services/firebase_service.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/logout.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/update_fcm_token.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/delete_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_match_history.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_scorer_candidates.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/assign_scorer.dart';
import 'package:flutter/foundation.dart';
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
  final GetScorerCandidatesUseCase getScorerCandidatesUseCase;
  final AssignScorerUseCase assignScorerUseCase;
  final UpdateFcmTokenUseCase updateFcmTokenUseCase;

  HomeController({
    required this.logoutUseCase,
    required this.getMatchHistoryUseCase,
    required this.deleteMatchUseCase,
    required this.getScorerCandidatesUseCase,
    required this.assignScorerUseCase,
    required this.updateFcmTokenUseCase,
  });

  static const int _pageSize = 20;

  final matches = <MatchHistoryItem>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final loadError = Rxn<String>();
  int _page = 1;

  /// Guards [loadHistory] against a second overlapping call — a rapid double
  /// pull-to-refresh, or a refresh landing while the initial `onInit` load is
  /// still in flight. Not `isLoading` itself: that starts `true` for the
  /// unrelated reason of showing a spinner before the very first load has
  /// even begun, so gating on it would make that first call a no-op too.
  /// Without this, two in-flight requests race independently, and whichever
  /// resolves last — not whichever was sent last — is what the list ends up
  /// showing.
  bool _isLoadingHistory = false;

  /// Matches per status across everything the user can see, from the server's
  /// own count (independent of any filter) — what the Matches tab's chips
  /// badge. Empty until the first response, and from a server that predates
  /// the field, in which case the chips simply show no number.
  final statusCounts = <String, int>{}.obs;

  /// The Matches tab's status chip: `null` is "All", otherwise `live`
  /// (which also covers `innings_break`), `upcoming`, `completed` or
  /// `abandoned`. Filtering is done by the server *before* paginating, so a
  /// live match on a later page is found instead of hidden.
  final statusFilter = Rxn<String>();

  /// The filtered list and its own paging state, kept apart from [matches] on
  /// purpose: Home's dashboard reads [matches] as "the newest page of
  /// everything" (hero, live carousel, recent results), so narrowing that
  /// list to one status would empty half of Home.
  final filteredMatches = <MatchHistoryItem>[].obs;
  final isLoadingFiltered = false.obs;
  final isLoadingMoreFiltered = false.obs;
  final hasMoreFiltered = false.obs;
  final filteredError = Rxn<String>();
  int _filteredPage = 1;

  /// Bumped on every filter change and refresh. A response for an older
  /// number is dropped: tapping Live then Completed quickly must not let the
  /// slower Live response overwrite the list Completed is showing.
  int _filteredRequest = 0;

  /// The Matches tab's committed team-name search — trimmed, and empty when
  /// there is none. It is what the server was (or is being) asked for, not
  /// the raw text in the field: typing goes through [updateSearch], which
  /// waits for a pause first.
  final searchQuery = ''.obs;

  /// How long typing must pause before a search is sent.
  @visibleForTesting
  Duration searchDebounce = const Duration(milliseconds: 350);
  Timer? _searchTimer;

  /// The per-status counts of the unfiltered list. [statusCounts] follows
  /// the search while one is active (so the chips describe the results), and
  /// this is what it returns to when the search is cleared.
  Map<String, int> _globalCounts = const {};

  /// Whether the Matches tab is reading [filteredMatches] rather than
  /// [matches]: a chip is picked, a search is active, or both.
  bool get isFiltering =>
      statusFilter.value != null || searchQuery.value.isNotEmpty;

  /// The signed-in user's own cached photo/username — nothing filled in on
  /// the Complete/My Profile screen was ever shown back to the user before
  /// this, anywhere in the app. Read synchronously from the same cache
  /// `login_controller.dart` writes (and `update_profile_controller.dart`
  /// now refreshes on save), not fetched here, so opening Home never waits
  /// on a network call just to draw the app bar.
  final currentUserProfile = Rx<User?>(null);

  @override
  void onClose() {
    _searchTimer?.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    refreshCurrentUserProfile();
    unawaited(loadHistory());
    unawaited(_syncFcmToken());
  }

  /// Re-reads the cached profile — called once on init and again after
  /// returning from the profile screen, so an edit is reflected without
  /// needing its own network round trip here.
  void refreshCurrentUserProfile() {
    currentUserProfile.value = currentUser();
  }

  /// Registers this device's FCM token against the signed-in user, once per
  /// cold start that reaches Home — the missing link that made every
  /// server-triggered push a no-op until now (see docs/api.md's
  /// `## Notifications` section). Guarded on `Get.isRegistered`, not a
  /// constructor dependency: `FirebaseService` needs a real Firebase app
  /// (unavailable in a bare unit test), and every other `HomeController`
  /// dependency here is already a plain, fakeable usecase — adding one more
  /// thing this method needs would force every existing test to also fake
  /// Firebase just to construct the controller at all. A no-op skip is
  /// exactly correct there: no real device, nothing to register.
  Future<void> _syncFcmToken() async {
    if (!Get.isRegistered<FirebaseService>()) return;
    final token = await Get.find<FirebaseService>().generateToken();
    if (token == null || token.isEmpty) return;
    await updateFcmTokenUseCase(params: token);
  }

  /// First page, replacing whatever list is already showing — the pull-to-
  /// refresh and initial-load entry point.
  Future<void> loadHistory() async {
    if (_isLoadingHistory) return;
    _isLoadingHistory = true;
    isLoading.value = true;
    loadError.value = null;
    _page = 1;

    final response = await getMatchHistoryUseCase(
      params: const GetMatchHistoryParams(page: 1, limit: _pageSize),
    );

    isLoading.value = false;
    _isLoadingHistory = false;

    if (response.isResult) {
      final data = response.result.data;
      // A refresh's GET can be sent while a delete's own request hasn't yet
      // committed server-side — this response may be a snapshot from
      // before that delete landed. Filtering out anything still in
      // deletingMatchIds is what stops that stale snapshot from
      // resurrecting a card the scorer just asked to delete.
      matches.assignAll(
        (data?.matches ?? []).where(
          (match) => !deletingMatchIds.contains(match.matchId),
        ),
      );
      hasMore.value = data?.hasMore ?? false;
      _adoptCounts(data, global: true);
    } else {
      loadError.value = response.fallback.message;
    }
  }

  /// [global] marks a response to the unfiltered request: those counts are
  /// remembered, but only shown while no search is active — during one the
  /// chips describe the search's results, which a filtered response carries.
  void _adoptCounts(MatchHistoryRes? data, {bool global = false}) {
    final counts = data?.counts;
    if (counts == null || counts.isEmpty) return;
    if (global) _globalCounts = Map<String, int>.of(counts);
    if (global && searchQuery.value.isNotEmpty) return;
    // A copy: RxMap.assignAll keeps the map it is handed, and this one
    // belongs to the response model (and is const when defaulted), while
    // deleteMatch decrements entries in place.
    statusCounts.assignAll(Map<String, int>.of(counts));
  }

  /// The statuses a chip stands for. `live` includes `innings_break`: to a
  /// scorer choosing what to open, an innings break is still a live match.
  static List<String> statusesFor(String filter) =>
      filter == 'live' ? const ['live', 'innings_break'] : [filter];

  /// Picks a chip. `null` returns to "All", which is just [matches] again —
  /// no request — unless a search is active, in which case it is that
  /// search across every status; anything else fetches that status's first
  /// page.
  Future<void> selectStatusFilter(String? status) async {
    if (status == statusFilter.value) return;
    statusFilter.value = status;
    if (!isFiltering) {
      _resetFiltered();
      return;
    }
    await loadFiltered();
  }

  void _resetFiltered() {
    _filteredRequest++;
    filteredMatches.clear();
    filteredError.value = null;
    hasMoreFiltered.value = false;
    isLoadingFiltered.value = false;
    isLoadingMoreFiltered.value = false;
  }

  /// The search field's `onChanged`. Typing is debounced into one request
  /// for the final text; emptying the field applies at once, since going
  /// back to the full list needs no server round trip.
  void updateSearch(String raw) {
    _searchTimer?.cancel();
    final query = raw.trim();
    if (query.isEmpty) {
      unawaited(applySearch(''));
      return;
    }
    _searchTimer = Timer(searchDebounce, () => unawaited(applySearch(query)));
  }

  /// Commits [raw] as the search now (see [updateSearch] for the debounced
  /// path) and fetches its first page — or, when it is empty and no chip is
  /// active, returns to [matches] without a request.
  Future<void> applySearch(String raw) async {
    _searchTimer?.cancel();
    final query = raw.trim();
    if (query == searchQuery.value) return;
    searchQuery.value = query;
    if (query.isEmpty) {
      statusCounts.assignAll(Map<String, int>.of(_globalCounts));
    }
    if (!isFiltering) {
      _resetFiltered();
      return;
    }
    await loadFiltered();
  }

  /// First page of the active filter, replacing the filtered list — the
  /// chip-tap and pull-to-refresh entry point.
  Future<void> loadFiltered() async {
    if (!isFiltering) return;
    final filter = statusFilter.value;
    final query = searchQuery.value;

    final request = ++_filteredRequest;
    filteredMatches.clear();
    filteredError.value = null;
    hasMoreFiltered.value = false;
    isLoadingFiltered.value = true;
    isLoadingMoreFiltered.value = false;
    _filteredPage = 1;

    final response = await getMatchHistoryUseCase(
      params: GetMatchHistoryParams(
        page: 1,
        limit: _pageSize,
        statuses: filter == null ? null : statusesFor(filter),
        query: query.isEmpty ? null : query,
      ),
    );

    if (request != _filteredRequest) return;
    isLoadingFiltered.value = false;

    if (response.isResult) {
      final data = response.result.data;
      filteredMatches.assignAll(
        (data?.matches ?? []).where(
          (match) => !deletingMatchIds.contains(match.matchId),
        ),
      );
      hasMoreFiltered.value = data?.hasMore ?? false;
      _adoptCounts(data);
    } else {
      filteredError.value = response.fallback.message;
    }
  }

  /// Next page of the active filter. A no-op while a load is in flight or
  /// nothing is left, same as [loadMore].
  Future<void> loadMoreFiltered() async {
    final filter = statusFilter.value;
    final query = searchQuery.value;
    if (!isFiltering ||
        isLoadingFiltered.value ||
        isLoadingMoreFiltered.value ||
        !hasMoreFiltered.value) {
      return;
    }

    final request = _filteredRequest;
    isLoadingMoreFiltered.value = true;

    final response = await getMatchHistoryUseCase(
      params: GetMatchHistoryParams(
        page: _filteredPage + 1,
        limit: _pageSize,
        statuses: filter == null ? null : statusesFor(filter),
        query: query.isEmpty ? null : query,
      ),
    );

    if (request != _filteredRequest) return;
    isLoadingMoreFiltered.value = false;

    if (response.isResult) {
      final data = response.result.data;
      if (data != null) {
        filteredMatches.addAll(
          data.matches.where(
            (match) => !deletingMatchIds.contains(match.matchId),
          ),
        );
        hasMoreFiltered.value = data.hasMore;
        _filteredPage += 1;
      }
    } else {
      // Same choice as [loadMore]: leave `hasMoreFiltered` alone so a
      // transient failure doesn't hide the rest of the list.
      CricketSnackbar.showErrorMessage(response.fallback.message);
    }
  }

  /// Pull-to-refresh on the Matches tab: the unfiltered first page (which
  /// also refreshes the counts and Home's own view) and, when a chip is
  /// active, that chip's list.
  Future<void> refreshMatches() {
    return Future.wait([
      loadHistory(),
      if (isFiltering) loadFiltered(),
    ]);
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
            tossWinner: item.tossWinner,
            tossDecision: item.tossDecision,
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
      filteredMatches.removeWhere((match) => match.matchId == item.matchId);
      final counted = statusCounts[item.status];
      if (counted != null && counted > 0) {
        statusCounts[item.status] = counted - 1;
      }
      final globalCounted = _globalCounts[item.status];
      if (globalCounted != null && globalCounted > 0) {
        _globalCounts = {..._globalCounts, item.status: globalCounted - 1};
      }
    } else {
      CricketSnackbar.showErrorMessage(response.fallback.message);
    }
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
    final assigned = response.result.data?.assignedScorer;
    for (final list in [matches, filteredMatches]) {
      final index = list.indexWhere((item) => item.matchId == matchId);
      if (index != -1) {
        list[index] = list[index].copyWith(assignedScorer: assigned);
      }
    }
    return true;
  }

  /// Signing out is a local, on-device action first and a courtesy to the
  /// server second: the local session is always cleared and the console
  /// always returns to login below, regardless of whether the API call
  /// (best-effort revocation of the server-side session) succeeded, returned
  /// a failure, or threw outright. A logout that can leave the console
  /// apparently still signed in after the user explicitly asked to leave —
  /// and, on a route that shares this device's session with every other
  /// in-flight request, can show a "logout failed" toast in the same breath
  /// as [AuthInterceptor]'s own forced "session expired" redirect, if the
  /// access token happened to be expired at the same moment — is worse than
  /// occasionally missing the server-side revocation.
  Future<void> logout() async {
    CricketLoaderDialog.show();

    try {
      final String? refreshToken = await SecureStorageService.secure.get(
        SharedPrefKey.refreshToken,
      );

      await logoutUseCase(params: LogoutReq(refreshToken: refreshToken));
    } catch (_) {
      // Best-effort — the local logout below proceeds regardless of what
      // went wrong reaching the server.
    }

    CricketLoaderDialog.hide();

    await SharedPreferenceService.sharedPrefService.clearForLogout();
    await SecureStorageService.secure.clearForLogout();
    ApiClient.cancelAllRequests();

    unawaited(Get.offAllNamed(AppRoutes.login));
  }
}
