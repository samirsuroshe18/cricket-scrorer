import 'package:cricket_scorer/features/scoring/domain/usecases/add_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/cancel_team_invite.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_invites.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_players.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/invite_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/lookup_user_by_email.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/set_team_leadership.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/remove_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_scorer_candidates.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/assign_scorer.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team_logo.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/delete_team.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_profile_controller.dart';
import 'package:get/get.dart';

class TeamProfileBinding extends Bindings {
  @override
  void dependencies() {
    final teamId = Get.parameters['teamId']?.trim() ?? '';
    Get.lazyPut<TeamProfileController>(
      () => TeamProfileController(
        teamId: teamId,
        getTeamProfileUseCase: Get.find<GetTeamProfileUseCase>(),
        getTeamMatchesUseCase: Get.find<GetTeamMatchesUseCase>(),
        getScorerCandidatesUseCase: Get.find<GetScorerCandidatesUseCase>(),
        assignScorerUseCase: Get.find<AssignScorerUseCase>(),
        updateTeamLogoUseCase: Get.find<UpdateTeamLogoUseCase>(),
        updateTeamUseCase: Get.find<UpdateTeamUseCase>(),
        deleteTeamUseCase: Get.find<DeleteTeamUseCase>(),
        addTeamPlayerUseCase: Get.find<AddTeamPlayerUseCase>(),
        updateTeamPlayerUseCase: Get.find<UpdateTeamPlayerUseCase>(),
        removeTeamPlayerUseCase: Get.find<RemoveTeamPlayerUseCase>(),
        setTeamLeadershipUseCase: Get.find<SetTeamLeadershipUseCase>(),
        getMyPlayersUseCase: Get.find<GetMyPlayersUseCase>(),
        lookupUserByEmailUseCase: Get.find<LookupUserByEmailUseCase>(),
        inviteTeamPlayerUseCase: Get.find<InviteTeamPlayerUseCase>(),
        getTeamInvitesUseCase: Get.find<GetTeamInvitesUseCase>(),
        cancelTeamInviteUseCase: Get.find<CancelTeamInviteUseCase>(),
      ),
      tag: teamId,
    );
  }
}
