import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/request/add_organization_member_req.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';

class AddOrganizationMemberParams {
  final String orgId;
  final AddOrganizationMemberReq req;

  AddOrganizationMemberParams({required this.orgId, required this.req});
}

class AddOrganizationMemberUseCase
    implements
        UseCase<
          Either<CricketResponse<OrganizationMemberRes>, CricketFailure>,
          AddOrganizationMemberParams
        > {
  final OrganizationRepository organizationRepository;

  AddOrganizationMemberUseCase({required this.organizationRepository});

  @override
  Future<Either<CricketResponse<OrganizationMemberRes>, CricketFailure>> call({
    AddOrganizationMemberParams? params,
  }) {
    return organizationRepository.addMember(
      orgId: params!.orgId,
      params: params.req,
    );
  }
}
