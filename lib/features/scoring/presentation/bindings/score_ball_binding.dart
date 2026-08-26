import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/score_ball.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/select_bowler.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/start_innings.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/undo_ball.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/score_ball_controller.dart';
import 'package:get/get.dart';

class ScoreBallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScoreBallController>(
      () => ScoreBallController(
        scoreBallUseCase: Get.find<ScoreBallUseCase>(),
        startInningsUseCase: Get.find<StartInningsUseCase>(),
        selectBowlerUseCase: Get.find<SelectBowlerUseCase>(),
        undoBallUseCase: Get.find<UndoBallUseCase>(),
        matchRepository: Get.find<MatchRepository>(),
      ),
    );
  }
}
