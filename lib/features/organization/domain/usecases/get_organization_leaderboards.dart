import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_leaderboards_res.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';

class GetOrganizationLeaderboardsParams {
  final String orgId;

  GetOrganizationLeaderboardsParams({required this.orgId});
}

class GetOrganizationLeaderboardsUseCase
    implements
        UseCase<
          Either<CricketResponse<OrganizationLeaderboardsRes>, CricketFailure>,
          GetOrganizationLeaderboardsParams
        > {
  final OrganizationRepository organizationRepository;

  GetOrganizationLeaderboardsUseCase({required this.organizationRepository});

  @override
  Future<Either<CricketResponse<OrganizationLeaderboardsRes>, CricketFailure>>
  call({GetOrganizationLeaderboardsParams? params}) {
    return organizationRepository.getLeaderboards(orgId: params!.orgId);
  }
}
