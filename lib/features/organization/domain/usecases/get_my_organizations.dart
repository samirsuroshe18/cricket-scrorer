import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';

class GetMyOrganizationsUseCase
    implements
        UseCase<
          Either<CricketResponse<MyOrganizationsRes>, CricketFailure>,
          void
        > {
  final OrganizationRepository organizationRepository;

  GetMyOrganizationsUseCase({required this.organizationRepository});

  @override
  Future<Either<CricketResponse<MyOrganizationsRes>, CricketFailure>> call({
    void params,
  }) {
    return organizationRepository.getMyOrganizations();
  }
}
