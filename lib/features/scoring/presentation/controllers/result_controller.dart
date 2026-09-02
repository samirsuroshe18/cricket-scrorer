import 'dart:async';

import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/offline_sync_service.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/scorecard_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_scorecard.dart';
import 'package:get/get.dart';

/// Loads from `GET .../scorecard`, regardless of how the screen was reached
/// — automatically from `ScoreBallController._navigateToResult`, or by direct
/// navigation later. One code path for both, matching the backend's own
/// stated design: the `match:complete` socket event that triggers the
/// automatic path is deliberately thin, a pointer rather than a data source;
/// this GET is the only place the full scorecard ever comes from.
///
/// The one branch: a match completed entirely offline has no scorecard to
/// fetch yet (`SCORECARD_NOT_READY`, or simply no connection at all) — see
/// [provisionalResult].
class ResultController extends GetxController {
  final GetScorecardUseCase getScorecardUseCase;
  final OfflineSyncService offlineSyncService;

  ResultController({
    required this.getScorecardUseCase,
    required this.offlineSyncService,
  });

  late final String _matchId;

  /// Only ever used offline, to resolve `teamA`/`teamB` into real names and
  /// to re-point [offlineSyncService] at the innings whose flush this screen
  /// is waiting on — `_navigateToResult` passes it as `Get.arguments`, the
  /// same object the score screen has held since match creation. Null on a
  /// direct navigation to this route (e.g. a bookmark), in which case
  /// [nameFor] falls back to the raw side label rather than guessing.
  CreateMatchRes? _match;

  final isLoading = true.obs;

  /// Set on a failed fetch with no [provisionalResult] to fall back to — the
  /// match isn't actually completed yet (`SCORECARD_NOT_READY`, unreachable
  /// via the normal navigation paths but possible if this route is opened by
  /// hand), a network failure, or a malformed matchId. Null once the
  /// scorecard has loaded.
  final loadError = Rxn<String>();

  final scorecard = Rxn<ScorecardRes>();

  /// A locally-computed win/margin, shown only while the real scorecard
  /// can't be fetched yet — a match completed offline. Cleared the instant
  /// the real scorecard loads; never shown alongside it.
  final provisionalResult = Rxn<MatchResultInfo>();

  Worker? _phaseWorker;

  /// Guards [_load] against a second overlapping call — `onInit`'s own
  /// first load, [_phaseWorker]'s auto-retry once the offline queue drains,
  /// and the manual [retry] button can all fire it independently. Not
  /// `isLoading` itself: gating on that would make the very first call, for
  /// which it also starts `true`, a no-op too. Without this, two in-flight
  /// requests race independently, and whichever resolves last — not
  /// whichever was triggered last — is what this screen ends up showing.
  /// Same shape and same fix as `HomeController.loadHistory`'s own guard.
  bool _isLoadingResult = false;

  @override
  void onInit() {
    super.onInit();

    final matchId = Get.parameters['matchId']?.trim();
    if (matchId == null || matchId.isEmpty) {
      loadError.value = TranslationKeys.somethingWentWrong.tr;
      isLoading.value = false;
      return;
    }

    _matchId = matchId;
    _match = Get.arguments is CreateMatchRes
        ? Get.arguments as CreateMatchRes
        : null;

    // A match only ever completes at the end of innings 2 — re-pointing here
    // (idempotent if the score screen already left it watching this) is what
    // keeps the sync banner and the auto-retry below correct even after an
    // app relaunch that lands directly on this screen.
    offlineSyncService.watch(matchId: _matchId, inningsNumber: 2);

    unawaited(_load());

    // Once the queue actually flushes — the real scorecard becomes fetchable
    // the moment innings 2's terminal ball(s) land for real — try again
    // automatically rather than leaving the scorer stuck on a provisional
    // view once the truth is one tap away regardless.
    _phaseWorker = ever<SyncPhase>(offlineSyncService.phase, (phase) {
      if (phase == SyncPhase.idle &&
          offlineSyncService.pendingCount.value == 0 &&
          provisionalResult.value != null) {
        unawaited(_load());
      }
    });
  }

  @override
  void onClose() {
    _phaseWorker?.dispose();
    super.onClose();
  }

  /// Only for [ResultScreen]'s sync banner — resolving names/watching the
  /// queue offline is this controller's own job, not the screen's.
  String get matchId => _matchId;

  Future<void> retry() => _load();

  Future<void> retrySync() =>
      offlineSyncService.retryNow(matchId: _matchId, inningsNumber: 2);

  /// `teamA`/`teamB` resolved off the match this screen was handed —
  /// available offline, unlike [ScorecardRes.nameFor], which needs the GET
  /// that hasn't succeeded yet. Falls back to the raw label only when even
  /// that isn't available (a direct navigation with no arguments).
  String nameFor(String sideLabel) {
    final match = _match;
    if (match == null) return sideLabel;
    return sideLabel == 'teamA' ? match.teamA.name : match.teamB.name;
  }

  Future<void> _load() async {
    if (_isLoadingResult) return;
    _isLoadingResult = true;

    isLoading.value = true;
    loadError.value = null;

    try {
      final response = await getScorecardUseCase(
        params: GetScorecardParams(matchId: _matchId),
      );

      final data = response.isResult ? response.result.data : null;

      if (!response.isResult || data == null) {
        final provisional = await offlineSyncService.provisionalResultFor(
          _matchId,
        );
        if (provisional != null) {
          provisionalResult.value = MatchResultInfo(
            winner: provisional.winner,
            marginType: provisional.marginType,
            margin: provisional.margin,
          );
          isLoading.value = false;
          return;
        }

        loadError.value = response.isResult
            ? TranslationKeys.somethingWentWrong.tr
            : response.fallback.message;
        isLoading.value = false;
        return;
      }

      provisionalResult.value = null;
      unawaited(offlineSyncService.deleteProvisionalResult(_matchId));
      scorecard.value = data;
      isLoading.value = false;
    } finally {
      _isLoadingResult = false;
    }
  }
}
