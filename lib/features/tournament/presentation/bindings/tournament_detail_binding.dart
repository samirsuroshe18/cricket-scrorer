import 'package:cricket_scorer/core/utils/current_user.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/update_tournament.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:get/get.dart';

class TournamentDetailBinding extends Bindings {
  @override
  void dependencies() {
    final tournamentId = Get.parameters['tournamentId']?.trim() ?? '';
    Get.lazyPut<TournamentDetailController>(
      () => TournamentDetailController(
        tournamentId: tournamentId,
        currentUserId: currentUserId(),
        getTournamentUseCase: Get.find<GetTournamentUseCase>(),
        getOrganizationUseCase: Get.find<GetOrganizationUseCase>(),
        updateTournamentUseCase: Get.find<UpdateTournamentUseCase>(),
        deleteTournamentUseCase: Get.find<DeleteTournamentUseCase>(),
        enrollTournamentTeamUseCase: Get.find<EnrollTournamentTeamUseCase>(),
        removeTournamentTeamUseCase: Get.find<RemoveTournamentTeamUseCase>(),
      ),
      tag: tournamentId,
    );
  }
}
