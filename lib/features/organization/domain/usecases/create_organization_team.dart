import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_team_req.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';

class CreateOrganizationTeamParams {
  final String orgId;
  final CreateOrganizationTeamReq req;

  CreateOrganizationTeamParams({required this.orgId, required this.req});
}

class CreateOrganizationTeamUseCase
    implements
        UseCase<
          Either<CricketResponse<OrganizationTeamRef>, CricketFailure>,
          CreateOrganizationTeamParams
        > {
  final OrganizationRepository organizationRepository;

  CreateOrganizationTeamUseCase({required this.organizationRepository});

  @override
  Future<Either<CricketResponse<OrganizationTeamRef>, CricketFailure>> call({
    CreateOrganizationTeamParams? params,
  }) {
    return organizationRepository.createTeam(
      orgId: params!.orgId,
      params: params.req,
    );
  }
}
