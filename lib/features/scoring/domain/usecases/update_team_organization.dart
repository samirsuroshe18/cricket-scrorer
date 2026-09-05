import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_organization_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class UpdateTeamOrganizationParams {
  final String teamId;
  final String? organizationId;

  UpdateTeamOrganizationParams({required this.teamId, this.organizationId});
}

class UpdateTeamOrganizationUseCase
    implements
        UseCase<
          Either<CricketResponse<TeamOrganizationRes>, CricketFailure>,
          UpdateTeamOrganizationParams
        > {
  final MatchRepository matchRepository;

  UpdateTeamOrganizationUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<TeamOrganizationRes>, CricketFailure>> call({
    UpdateTeamOrganizationParams? params,
  }) {
    return matchRepository.updateTeamOrganization(
      teamId: params!.teamId,
      organizationId: params.organizationId,
    );
  }
}
