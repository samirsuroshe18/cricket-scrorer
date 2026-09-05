import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_req.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';

class CreateOrganizationUseCase
    implements
        UseCase<
          Either<CricketResponse<OrganizationDetailRes>, CricketFailure>,
          CreateOrganizationReq
        > {
  final OrganizationRepository organizationRepository;

  CreateOrganizationUseCase({required this.organizationRepository});

  @override
  Future<Either<CricketResponse<OrganizationDetailRes>, CricketFailure>> call({
    CreateOrganizationReq? params,
  }) {
    return organizationRepository.createOrganization(params: params);
  }
}
