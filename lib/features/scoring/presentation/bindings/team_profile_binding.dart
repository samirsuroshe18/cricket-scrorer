import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_profile_controller.dart';
import 'package:get/get.dart';

class TeamProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeamProfileController>(
      () => TeamProfileController(
        getTeamProfileUseCase: Get.find<GetTeamProfileUseCase>(),
        getTeamMatchesUseCase: Get.find<GetTeamMatchesUseCase>(),
      ),
    );
  }
}
