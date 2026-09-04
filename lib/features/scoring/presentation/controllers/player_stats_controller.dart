import 'dart:async';

import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/career_stats_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_career_stats.dart';
import 'package:get/get.dart';

/// A plain online read — unlike [ResultController], there is no offline
/// queue or provisional state to reconcile here: career stats only ever
/// exist server-side, computed after a match already completed.
class PlayerStatsController extends GetxController {
  final GetCareerStatsUseCase getCareerStatsUseCase;

  PlayerStatsController({required this.getCareerStatsUseCase});

  late final String _playerId;

  final isLoading = true.obs;
  final loadError = Rxn<String>();
  final careerStats = Rxn<CareerStatsRes>();

  /// Same shape and same reason as `HomeController.loadHistory`'s own guard:
  /// `onInit`'s first load and the manual [retry] button can both fire
  /// [_load] independently, and without this a second overlapping call could
  /// resolve first and leave the screen showing the wrong response.
  bool _isLoadingStats = false;

  @override
  void onInit() {
    super.onInit();

    final playerId = Get.parameters['playerId']?.trim();
    if (playerId == null || playerId.isEmpty) {
      loadError.value = TranslationKeys.somethingWentWrong.tr;
      isLoading.value = false;
      return;
    }

    _playerId = playerId;
    unawaited(_load());
  }

  Future<void> retry() => _load();

  Future<void> _load() async {
    if (_isLoadingStats) return;
    _isLoadingStats = true;

    isLoading.value = true;
    loadError.value = null;

    try {
      final response = await getCareerStatsUseCase(
        params: GetCareerStatsParams(playerId: _playerId),
      );

      if (response.isResult) {
        careerStats.value = response.result.data;
      } else {
        loadError.value = response.fallback.message;
      }
      isLoading.value = false;
    } finally {
      _isLoadingStats = false;
    }
  }
}
