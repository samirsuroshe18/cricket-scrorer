import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';

class DeleteOrganizationParams {
  final String orgId;

  DeleteOrganizationParams({required this.orgId});
}

class DeleteOrganizationUseCase
    implements
        UseCase<Either<CricketResponse<void>, CricketFailure>,
            DeleteOrganizationParams> {
  final OrganizationRepository organizationRepository;

  DeleteOrganizationUseCase({required this.organizationRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    DeleteOrganizationParams? params,
  }) {
    return organizationRepository.deleteOrganization(orgId: params!.orgId);
  }
}
