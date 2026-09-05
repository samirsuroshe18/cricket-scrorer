import 'package:cricket_scorer/features/organization/data/models/request/add_organization_member_req.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_team_req.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/add_organization_member.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization_team.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/delete_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/remove_organization_member.dart';
import 'package:get/get.dart';

class OrganizationDetailController extends GetxController {
  final String orgId;

  /// The signed-in scorer's own id — compared against `detail.owner.id` for
  /// [isOwner] and against each member row to decide "leave" vs "remove".
  /// Client-side only, to decide which buttons to show; the server remains
  /// the real authority on every action (see docs/api.md).
  final String currentUserId;

  final GetOrganizationUseCase getOrganizationUseCase;
  final AddOrganizationMemberUseCase addOrganizationMemberUseCase;
  final RemoveOrganizationMemberUseCase removeOrganizationMemberUseCase;
  final CreateOrganizationTeamUseCase createOrganizationTeamUseCase;
  final DeleteOrganizationUseCase deleteOrganizationUseCase;

  OrganizationDetailController({
    required this.orgId,
    required this.currentUserId,
    required this.getOrganizationUseCase,
    required this.addOrganizationMemberUseCase,
    required this.removeOrganizationMemberUseCase,
    required this.createOrganizationTeamUseCase,
    required this.deleteOrganizationUseCase,
  });

  final detail = Rxn<OrganizationDetailRes>();
  final isLoading = true.obs;
  final loadError = Rxn<String>();

  bool get isOwner => detail.value?.owner.id == currentUserId;

  @override
  void onInit() {
    super.onInit();
    loadDetail();
  }

  Future<void> loadDetail() async {
    isLoading.value = true;
    loadError.value = null;

    final response = await getOrganizationUseCase(
      params: GetOrganizationParams(orgId: orgId),
    );

    isLoading.value = false;

    if (response.isResult) {
      detail.value = response.result.data;
    } else {
      loadError.value = response.fallback.message;
    }
  }

  Future<bool> addMember(String email) async {
    final response = await addOrganizationMemberUseCase(
      params: AddOrganizationMemberParams(
        orgId: orgId,
        req: AddOrganizationMemberReq(email: email),
      ),
    );

    if (!response.isResult) return false;
    await loadDetail();
    return true;
  }

  Future<bool> removeMember(String userId) async {
    final response = await removeOrganizationMemberUseCase(
      params: RemoveOrganizationMemberParams(orgId: orgId, userId: userId),
    );

    if (!response.isResult) return false;
    await loadDetail();
    return true;
  }

  Future<bool> createTeam(String name, String? shortName) async {
    final response = await createOrganizationTeamUseCase(
      params: CreateOrganizationTeamParams(
        orgId: orgId,
        req: CreateOrganizationTeamReq(name: name, shortName: shortName),
      ),
    );

    if (!response.isResult) return false;
    await loadDetail();
    return true;
  }

  Future<bool> deleteOrganization() async {
    final response = await deleteOrganizationUseCase(
      params: DeleteOrganizationParams(orgId: orgId),
    );
    return response.isResult;
  }
}
