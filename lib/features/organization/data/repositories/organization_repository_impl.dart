import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/data_sources/remote/organization_api_service.dart';
import 'package:cricket_scorer/features/organization/data/models/request/add_organization_member_req.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_req.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_team_req.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final OrganizationApiService organizationApiService;

  OrganizationRepositoryImpl({required this.organizationApiService});

  @override
  Future<Either<CricketResponse<OrganizationDetailRes>, CricketFailure>>
  createOrganization({required CreateOrganizationReq? params}) async {
    final response = await organizationApiService.createOrganization(
      params: params,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: OrganizationDetailRes.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<MyOrganizationsRes>, CricketFailure>>
  getMyOrganizations() async {
    final response = await organizationApiService.getMyOrganizations();
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: MyOrganizationsRes.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<OrganizationDetailRes>, CricketFailure>>
  getOrganization({required String orgId}) async {
    final response = await organizationApiService.getOrganization(
      orgId: orgId,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: OrganizationDetailRes.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<OrganizationMemberRes>, CricketFailure>>
  addMember({
    required String orgId,
    required AddOrganizationMemberReq? params,
  }) async {
    final response = await organizationApiService.addMember(
      orgId: orgId,
      params: params,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: OrganizationMemberRes.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> removeMember({
    required String orgId,
    required String userId,
  }) async {
    final response = await organizationApiService.removeMember(
      orgId: orgId,
      userId: userId,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: null, message: response.result.message),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<OrganizationTeamRef>, CricketFailure>>
  createTeam({
    required String orgId,
    required CreateOrganizationTeamReq? params,
  }) async {
    final response = await organizationApiService.createTeam(
      orgId: orgId,
      params: params,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: OrganizationTeamRef.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> deleteOrganization({
    required String orgId,
  }) async {
    final response = await organizationApiService.deleteOrganization(
      orgId: orgId,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: null, message: response.result.message),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }
}
