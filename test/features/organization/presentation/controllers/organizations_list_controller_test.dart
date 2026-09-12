import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_req.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_my_organizations.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/remove_organization_member.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organizations_list_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _FakeGetMyOrganizationsUseCase implements GetMyOrganizationsUseCase {
  Either<CricketResponse<MyOrganizationsRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<MyOrganizationsRes>, CricketFailure>> call({
    void params,
  }) async {
    final result = response;
    if (result == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeCreateOrganizationUseCase implements CreateOrganizationUseCase {
  Either<CricketResponse<OrganizationDetailRes>, CricketFailure>? response;
  CreateOrganizationReq? lastRequest;

  @override
  Future<Either<CricketResponse<OrganizationDetailRes>, CricketFailure>> call({
    CreateOrganizationReq? params,
  }) async {
    lastRequest = params;
    final result = response;
    if (result == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeRemoveOrganizationMemberUseCase
    implements RemoveOrganizationMemberUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;
  RemoveOrganizationMemberParams? lastParams;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    RemoveOrganizationMemberParams? params,
  }) async {
    lastParams = params;
    final result = response;
    if (result == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  late _FakeGetMyOrganizationsUseCase getMyOrganizationsUseCase;
  late _FakeCreateOrganizationUseCase createOrganizationUseCase;
  late _FakeRemoveOrganizationMemberUseCase removeOrganizationMemberUseCase;
  late OrganizationsListController controller;

  setUp(() {
    Get.testMode = true;
    getMyOrganizationsUseCase = _FakeGetMyOrganizationsUseCase();
    createOrganizationUseCase = _FakeCreateOrganizationUseCase();
    removeOrganizationMemberUseCase = _FakeRemoveOrganizationMemberUseCase();
    controller = OrganizationsListController(
      getMyOrganizationsUseCase: getMyOrganizationsUseCase,
      createOrganizationUseCase: createOrganizationUseCase,
      removeOrganizationMemberUseCase: removeOrganizationMemberUseCase,
      currentUserId: 'user-1',
    );
  });

  tearDown(Get.reset);

  test('loadOrganizations populates the list on success', () async {
    getMyOrganizationsUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: MyOrganizationsRes(
          organizations: [
            OrganizationSummaryRes(
              id: 'org-1',
              name: 'Riverside CC',
              myRole: 'owner',
              memberCount: 1,
              teamCount: 0,
            ),
          ],
        ),
      ),
    );

    await controller.loadOrganizations();

    expect(controller.organizations.length, 1);
    expect(controller.organizations.first.name, 'Riverside CC');
    expect(controller.isLoading.value, isFalse);
    expect(controller.loadError.value, isNull);
  });

  test('loadOrganizations sets loadError on failure', () async {
    getMyOrganizationsUseCase.response = Either.fallback(
      CricketServerErrorFailure(statusCode: 500, message: 'Server error'),
    );

    await controller.loadOrganizations();

    expect(controller.organizations, isEmpty);
    expect(controller.loadError.value, 'Server error');
  });

  test(
    'createOrganization sends the typed name and prepends the result on success',
    () async {
      createOrganizationUseCase.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: OrganizationDetailRes(
            id: 'org-2',
            name: 'New Club',
            owner: OrganizationUserRef(id: 'user-1', name: 'Asha'),
            members: [
              OrganizationMemberRes(id: 'user-1', name: 'Asha', role: 'owner'),
            ],
            teams: const [],
            tournaments: const [],
          ),
        ),
      );

      final result = await controller.createOrganization('New Club');

      expect(result, isTrue);
      expect(createOrganizationUseCase.lastRequest?.name, 'New Club');
      expect(controller.organizations.first.name, 'New Club');
      expect(controller.organizations.first.myRole, 'owner');
    },
  );

  test(
    'createOrganization returns false and does not touch the list on failure',
    () async {
      createOrganizationUseCase.response = Either.fallback(
        CricketConflictFailure(statusCode: 409, message: 'Name taken'),
      );

      final result = await controller.createOrganization('Duplicate');

      expect(result, isFalse);
      expect(controller.organizations, isEmpty);
    },
  );

  test(
    'leaveOrganization removes the org from the list on success',
    () async {
      controller.organizations.assignAll([
        OrganizationSummaryRes(
          id: 'org-1',
          name: 'Riverside CC',
          myRole: 'member',
          memberCount: 4,
          teamCount: 1,
        ),
      ]);
      removeOrganizationMemberUseCase.response = Either.result(
        const CricketResponse(message: 'ok', data: null),
      );

      final result = await controller.leaveOrganization('org-1');

      expect(result, isTrue);
      expect(controller.organizations, isEmpty);
      expect(removeOrganizationMemberUseCase.lastParams?.orgId, 'org-1');
      expect(removeOrganizationMemberUseCase.lastParams?.userId, 'user-1');
    },
  );

  test(
    'leaveOrganization leaves the list untouched on failure',
    () async {
      controller.organizations.assignAll([
        OrganizationSummaryRes(
          id: 'org-1',
          name: 'Riverside CC',
          myRole: 'member',
          memberCount: 4,
          teamCount: 1,
        ),
      ]);
      removeOrganizationMemberUseCase.response = Either.fallback(
        CricketServerErrorFailure(statusCode: 500, message: 'Server error'),
      );

      final result = await controller.leaveOrganization('org-1');

      expect(result, isFalse);
      expect(controller.organizations, hasLength(1));
    },
  );
}
