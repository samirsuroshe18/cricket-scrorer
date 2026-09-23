import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/select_team_controller.dart';
import 'package:get/get.dart';

class SelectTeamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelectTeamController>(
      () => SelectTeamController(
        getMyTeamsUseCase: Get.find<GetMyTeamsUseCase>(),
      ),
    );
  }
}
