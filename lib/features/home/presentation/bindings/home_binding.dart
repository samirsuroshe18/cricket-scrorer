import 'package:cricket_scorer/core/utils/current_user.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/logout.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/main_shell_controller.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/my_teams_controller.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_my_organizations.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/remove_organization_member.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organizations_list_controller.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/delete_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_match_history.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_scorer_candidates.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/assign_scorer.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/update_fcm_token.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/get_notifications.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/get_unread_count.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/mark_all_notifications_read.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:cricket_scorer/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:get/get.dart';

/// Registered at [AppRoutes.home], which now renders [MainShellScreen] — a
/// bottom-nav shell whose four tabs (Home/Matches/Teams/Profile) all mount
/// at once inside an `IndexedStack`. Every controller a tab needs is put
/// here up front, since there's no per-tab route push to bind against later.
/// `HomeController` and `OrganizationsListController` are the same classes
/// (and same fetch calls) the old single-screen Home and the standalone
/// Organizations screen already used — reused, not duplicated.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainShellController());

    Get.lazyPut(
      () => HomeController(
        logoutUseCase: Get.find<LogoutUseCase>(),
        getMatchHistoryUseCase: Get.find<GetMatchHistoryUseCase>(),
        deleteMatchUseCase: Get.find<DeleteMatchUseCase>(),
        getScorerCandidatesUseCase: Get.find<GetScorerCandidatesUseCase>(),
        assignScorerUseCase: Get.find<AssignScorerUseCase>(),
        updateFcmTokenUseCase: Get.find<UpdateFcmTokenUseCase>(),
      ),
    );

    Get.lazyPut(
      () => MyTeamsController(getMyTeamsUseCase: Get.find<GetMyTeamsUseCase>()),
    );

    Get.lazyPut(
      () => OrganizationsListController(
        getMyOrganizationsUseCase: Get.find<GetMyOrganizationsUseCase>(),
        createOrganizationUseCase: Get.find<CreateOrganizationUseCase>(),
        removeOrganizationMemberUseCase:
            Get.find<RemoveOrganizationMemberUseCase>(),
        currentUserId: currentUserId(),
      ),
    );

    Get.lazyPut(
      () => NotificationsController(
        getNotificationsUseCase: Get.find<GetNotificationsUseCase>(),
        getUnreadCountUseCase: Get.find<GetUnreadCountUseCase>(),
        markNotificationReadUseCase: Get.find<MarkNotificationReadUseCase>(),
        markAllNotificationsReadUseCase:
            Get.find<MarkAllNotificationsReadUseCase>(),
      ),
    );
  }
}
