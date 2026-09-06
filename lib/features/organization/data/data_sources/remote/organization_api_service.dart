import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/request/add_organization_member_req.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_req.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_team_req.dart';
import 'package:cricket_scorer/features/organization/data/organization_endpoint.dart';

class OrganizationApiService {
  final ApiClient apiClient;
  final OrganizationEndpoint organizationEndpoint;

  OrganizationApiService({
    required this.apiClient,
    required this.organizationEndpoint,
  });

  Future<Either<ApiResponseModel, CricketFailure>> createOrganization({
    required CreateOrganizationReq? params,
  }) async {
    return await apiClient.post(
      endpoint: organizationEndpoint.create,
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> getMyOrganizations() async {
    return await apiClient.get(endpoint: organizationEndpoint.listMine);
  }

  Future<Either<ApiResponseModel, CricketFailure>> getOrganization({
    required String orgId,
  }) async {
    return await apiClient.get(endpoint: organizationEndpoint.detail(orgId));
  }

  Future<Either<ApiResponseModel, CricketFailure>> addMember({
    required String orgId,
    required AddOrganizationMemberReq? params,
  }) async {
    return await apiClient.post(
      endpoint: organizationEndpoint.addMember(orgId),
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> removeMember({
    required String orgId,
    required String userId,
  }) async {
    return await apiClient.delete(
      endpoint: organizationEndpoint.removeMember(orgId, userId),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> createTeam({
    required String orgId,
    required CreateOrganizationTeamReq? params,
  }) async {
    return await apiClient.post(
      endpoint: organizationEndpoint.createTeam(orgId),
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> deleteOrganization({
    required String orgId,
  }) async {
    return await apiClient.delete(
      endpoint: organizationEndpoint.delete(orgId),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> getLeaderboards({
    required String orgId,
  }) async {
    return await apiClient.get(
      endpoint: organizationEndpoint.leaderboards(orgId),
    );
  }
}
