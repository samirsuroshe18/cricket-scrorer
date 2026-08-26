import 'dart:async';

import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/scorecard_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_scorecard.dart';
import 'package:get/get.dart';

/// Always loads from `GET .../scorecard`, regardless of how the screen was
/// reached — automatically from `ScoreBallController._navigateToResult`, or
/// by direct navigation later. One code path for both, matching the
/// backend's own stated design: the `match:complete` socket event that
/// triggers the automatic path is deliberately thin, a pointer rather than a
/// data source; this GET is the only place the full scorecard ever comes
/// from.
class ResultController extends GetxController {
  final GetScorecardUseCase getScorecardUseCase;

  ResultController({required this.getScorecardUseCase});

  late final String _matchId;

  final isLoading = true.obs;

  /// Set on a failed fetch — the match isn't actually completed yet
  /// (`SCORECARD_NOT_READY`, unreachable via the normal navigation paths but
  /// possible if this route is opened by hand), a network failure, or a
  /// malformed matchId. Null once the scorecard has loaded.
  final loadError = Rxn<String>();

  final scorecard = Rxn<ScorecardRes>();

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
    unawaited(_load());
  }

  Future<void> retry() => _load();

  Future<void> _load() async {
    isLoading.value = true;
    loadError.value = null;

    final response = await getScorecardUseCase(
      params: GetScorecardParams(matchId: _matchId),
    );

    final data = response.isResult ? response.result.data : null;

    if (!response.isResult || data == null) {
      loadError.value = response.isResult
          ? TranslationKeys.somethingWentWrong.tr
          : response.fallback.message;
      isLoading.value = false;
      return;
    }

    scorecard.value = data;
    isLoading.value = false;
  }
}
