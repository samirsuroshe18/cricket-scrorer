import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/score_ball.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/score_ball_controller.dart';
import 'package:get/get.dart';

class ScoreBallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScoreBallController>(
      () => ScoreBallController(
        scoreBallUseCase: Get.find<ScoreBallUseCase>(),
        matchRepository: Get.find<MatchRepository>(),
      ),
    );
  }
}
