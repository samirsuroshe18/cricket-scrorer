import 'package:cricket_scorer/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/acknowledge_squad.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/cancel_team_invite.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_match_squad.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_invites.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/invite_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/lookup_user_by_email.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/save_playing_xi.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/save_squad.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/squad_controller.dart';
import 'package:get/get.dart';

class SquadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SquadController>(() {
      // Create Match passes the bare match; the scoring console passes
      // SquadArgs so that leaving returns to it.
      final arguments = Get.arguments;
      final args = arguments is SquadArgs
          ? arguments
          : SquadArgs(match: arguments as CreateMatchRes);
      return SquadController(
        match: args.match,
        returnToScoring: args.returnToScoring,
        getTeamProfileUseCase: Get.find<GetTeamProfileUseCase>(),
        saveSquadUseCase: Get.find<SaveSquadUseCase>(),
        getMatchSquadUseCase: Get.find<GetMatchSquadUseCase>(),
        savePlayingXiUseCase: Get.find<SavePlayingXiUseCase>(),
        getTeamInvitesUseCase: Get.find<GetTeamInvitesUseCase>(),
        cancelTeamInviteUseCase: Get.find<CancelTeamInviteUseCase>(),
        lookupUserByEmailUseCase: Get.find<LookupUserByEmailUseCase>(),
        inviteTeamPlayerUseCase: Get.find<InviteTeamPlayerUseCase>(),
        acknowledgeSquadUseCase: Get.find<AcknowledgeSquadUseCase>(),
        // Only there once the home shell is up; the screen refreshes on resume
        // and pull-to-refresh regardless.
        inviteResponseTick: Get.isRegistered<NotificationsController>()
            ? Get.find<NotificationsController>().inviteResponseTick
            : null,
      );
    });
  }
}
