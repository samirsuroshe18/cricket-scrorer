import 'package:cricket_scorer/features/scoring/data/data_sources/local/offline_sync_service.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_scorecard.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/result_controller.dart';
import 'package:get/get.dart';

/// [ResultController] otherwise only ever reads — [OfflineSyncService] is the
/// one exception, needed only to check for/watch a match completed offline,
/// never to write a scoring action.
class ResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResultController>(
      () => ResultController(
        getScorecardUseCase: Get.find<GetScorecardUseCase>(),
        offlineSyncService: Get.find<OfflineSyncService>(),
      ),
    );
  }
}
