import 'package:cricket_scorer/features/organization/data/models/request/create_organization_req.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_my_organizations.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/remove_organization_member.dart';
import 'package:get/get.dart';

/// Every org the caller owns or belongs to, plus the ability to create a
/// new one. No pagination — an organization list is expected to stay small
/// (a scorer's own clubs), unlike match history or a team's past results.
class OrganizationsListController extends GetxController {
  final GetMyOrganizationsUseCase getMyOrganizationsUseCase;
  final CreateOrganizationUseCase createOrganizationUseCase;
  final RemoveOrganizationMemberUseCase removeOrganizationMemberUseCase;

  /// The signed-in scorer's own id — same synchronous cache read
  /// `OrganizationDetailBinding` already relies on. Needed to call
  /// [removeOrganizationMemberUseCase] on [leaveOrganization] with the
  /// caller's own id, since a member row here carries no membership id of
  /// its own (see `OrganizationSummaryRes`).
  final String currentUserId;

  OrganizationsListController({
    required this.getMyOrganizationsUseCase,
    required this.createOrganizationUseCase,
    required this.removeOrganizationMemberUseCase,
    required this.currentUserId,
  });

  final organizations = <OrganizationSummaryRes>[].obs;
  final isLoading = true.obs;
  final loadError = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadOrganizations();
  }

  Future<void> loadOrganizations() async {
    isLoading.value = true;
    loadError.value = null;

    final response = await getMyOrganizationsUseCase();

    isLoading.value = false;

    if (response.isResult) {
      organizations.assignAll(response.result.data?.organizations ?? []);
    } else {
      loadError.value = response.fallback.message;
    }
  }

  /// Returns whether creation succeeded — the screen uses this to decide
  /// whether to close the create-organization sheet or show its own error.
  Future<bool> createOrganization(String name) async {
    final response = await createOrganizationUseCase(
      params: CreateOrganizationReq(name: name),
    );

    if (!response.isResult) return false;

    final created = response.result.data;
    if (created != null) {
      organizations.insert(
        0,
        OrganizationSummaryRes(
          id: created.id,
          name: created.name,
          myRole: 'owner',
          memberCount: created.members.length,
          teamCount: created.teams.length,
        ),
      );
    }
    return true;
  }

  /// Removes the caller's own membership from [orgId] — the list-screen
  /// equivalent of `OrganizationDetailController.removeMember` called with
  /// the caller's own id, for a member (non-owner) row's "leave
  /// organization" action. Never called for a row the caller owns; owners
  /// leave by deleting the organization instead, same rule
  /// `OrganizationDetailScreen` already enforces.
  Future<bool> leaveOrganization(String orgId) async {
    final response = await removeOrganizationMemberUseCase(
      params: RemoveOrganizationMemberParams(
        orgId: orgId,
        userId: currentUserId,
      ),
    );

    if (!response.isResult) return false;
    organizations.removeWhere((org) => org.id == orgId);
    return true;
  }
}
