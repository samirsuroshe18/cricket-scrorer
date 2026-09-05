import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';

class GetOrganizationParams {
  final String orgId;

  GetOrganizationParams({required this.orgId});
}

class GetOrganizationUseCase
    implements
        UseCase<
          Either<CricketResponse<OrganizationDetailRes>, CricketFailure>,
          GetOrganizationParams
        > {
  final OrganizationRepository organizationRepository;

  GetOrganizationUseCase({required this.organizationRepository});

  @override
  Future<Either<CricketResponse<OrganizationDetailRes>, CricketFailure>> call({
    GetOrganizationParams? params,
  }) {
    return organizationRepository.getOrganization(orgId: params!.orgId);
  }
}
