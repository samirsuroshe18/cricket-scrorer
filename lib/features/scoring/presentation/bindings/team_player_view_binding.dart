import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_player_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_player_view.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_player_view_controller.dart';
import 'package:get/get.dart';

class TeamPlayerViewBinding extends Bindings {
  @override
  void dependencies() {
    final teamId = Get.parameters['teamId']?.trim() ?? '';
    Get.lazyPut<TeamPlayerViewController>(
      () => TeamPlayerViewController(
        teamId: teamId,
        getTeamPlayerViewUseCase: Get.find<GetTeamPlayerViewUseCase>(),
        getTeamPlayerMatchesUseCase: Get.find<GetTeamPlayerMatchesUseCase>(),
      ),
      tag: teamId,
    );
  }
}
