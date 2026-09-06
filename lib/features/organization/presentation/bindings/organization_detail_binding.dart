import 'package:cricket_scorer/core/utils/current_user.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/add_organization_member.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization_team.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/delete_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization_leaderboards.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/remove_organization_member.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organization_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/create_tournament.dart';
import 'package:get/get.dart';

class OrganizationDetailBinding extends Bindings {
  @override
  void dependencies() {
    final orgId = Get.parameters['orgId']?.trim() ?? '';
    Get.lazyPut<OrganizationDetailController>(
      () => OrganizationDetailController(
        orgId: orgId,
        currentUserId: currentUserId(),
        getOrganizationUseCase: Get.find<GetOrganizationUseCase>(),
        addOrganizationMemberUseCase: Get.find<AddOrganizationMemberUseCase>(),
        removeOrganizationMemberUseCase:
            Get.find<RemoveOrganizationMemberUseCase>(),
        createOrganizationTeamUseCase:
            Get.find<CreateOrganizationTeamUseCase>(),
        deleteOrganizationUseCase: Get.find<DeleteOrganizationUseCase>(),
        createTournamentUseCase: Get.find<CreateTournamentUseCase>(),
        getOrganizationLeaderboardsUseCase:
            Get.find<GetOrganizationLeaderboardsUseCase>(),
      ),
      tag: orgId,
    );
  }
}
