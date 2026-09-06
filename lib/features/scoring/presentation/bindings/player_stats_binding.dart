import 'package:cricket_scorer/features/scoring/domain/usecases/get_career_stats.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_player.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/player_stats_controller.dart';
import 'package:get/get.dart';

class PlayerStatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlayerStatsController>(
      () => PlayerStatsController(
        getCareerStatsUseCase: Get.find<GetCareerStatsUseCase>(),
        updatePlayerUseCase: Get.find<UpdatePlayerUseCase>(),
      ),
    );
  }
}
