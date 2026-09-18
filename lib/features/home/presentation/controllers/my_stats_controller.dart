import 'dart:async';

import 'package:cricket_scorer/features/scoring/data/models/response/my_career_stats_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_career_stats.dart';
import 'package:get/get.dart';

/// The signed-in user's own totals for Home's stat chips. Deliberately its own
/// controller rather than part of `HomeController`: a failure here (offline,
/// nobody claimed, an older backend) must never touch the match list's
/// loading/error/empty states, and a failed load is silent — the chips just
/// stay hidden, or keep showing the last good numbers on a failed refresh.
class MyStatsController extends GetxController {
  final GetMyCareerStatsUseCase getMyCareerStatsUseCase;

  MyStatsController({required this.getMyCareerStatsUseCase});

  final stats = Rxn<MyCareerStatsRes>();
  bool _isLoading = false;

  @override
  void onInit() {
    super.onInit();
    unawaited(load());
  }

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      final response = await getMyCareerStatsUseCase();
      if (response.isResult) stats.value = response.result.data;
    } catch (_) {
      // Silent by design — see the class doc.
    } finally {
      _isLoading = false;
    }
  }
}
