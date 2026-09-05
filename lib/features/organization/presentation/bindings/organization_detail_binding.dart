import 'dart:convert';

import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:cricket_scorer/features/auth/data/models/user.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/add_organization_member.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization_team.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/delete_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/remove_organization_member.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organization_detail_controller.dart';
import 'package:get/get.dart';

// Same cache read language_service.dart's own sync already relies on: the
// stored value is a LoggedInUser's JSON (written by login_controller.dart),
// decoded here via User.fromJson — both map their id from the same `_id`
// JSON key, so the cross-decode is exactly what that existing call site
// already depends on working. get() is synchronous, which is what a
// Bindings.dependencies() override needs — it cannot await a network call
// before returning.
String _currentUserId() {
  final userJson =
      SharedPreferenceService.sharedPrefService.get(SharedPrefKey.userDetails)
          as String?;
  if (userJson == null) return '';
  final user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  return user.id ?? '';
}

class OrganizationDetailBinding extends Bindings {
  @override
  void dependencies() {
    final orgId = Get.parameters['orgId']?.trim() ?? '';
    Get.lazyPut<OrganizationDetailController>(
      () => OrganizationDetailController(
        orgId: orgId,
        currentUserId: _currentUserId(),
        getOrganizationUseCase: Get.find<GetOrganizationUseCase>(),
        addOrganizationMemberUseCase: Get.find<AddOrganizationMemberUseCase>(),
        removeOrganizationMemberUseCase:
            Get.find<RemoveOrganizationMemberUseCase>(),
        createOrganizationTeamUseCase:
            Get.find<CreateOrganizationTeamUseCase>(),
        deleteOrganizationUseCase: Get.find<DeleteOrganizationUseCase>(),
      ),
      tag: orgId,
    );
  }
}
