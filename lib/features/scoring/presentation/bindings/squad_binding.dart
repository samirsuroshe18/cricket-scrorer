import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/save_squad.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/squad_controller.dart';
import 'package:get/get.dart';

class SquadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SquadController>(
      () => SquadController(
        match: Get.arguments as CreateMatchRes,
        getTeamProfileUseCase: Get.find<GetTeamProfileUseCase>(),
        saveSquadUseCase: Get.find<SaveSquadUseCase>(),
      ),
    );
  }
}
