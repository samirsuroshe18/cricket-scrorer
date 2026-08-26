import 'package:cricket_scorer/features/scoring/domain/usecases/get_scorecard.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/result_controller.dart';
import 'package:get/get.dart';

/// Same shape as [SpectatorBinding], and the same reason: [ResultController]
/// only ever reads, so it is only ever given [GetScorecardUseCase] — nothing
/// here could accidentally acquire a scoring capability during a refactor,
/// because none is wired up to acquire.
class ResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResultController>(
      () => ResultController(getScorecardUseCase: Get.find<GetScorecardUseCase>()),
    );
  }
}
