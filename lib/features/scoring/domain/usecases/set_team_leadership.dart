import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/set_team_leadership_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/created_team_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/team_repository.dart';

class SetTeamLeadershipParams {
  final String teamId;
  final SetTeamLeadershipReq req;

  SetTeamLeadershipParams({required this.teamId, required this.req});
}

class SetTeamLeadershipUseCase
    implements
        UseCase<
          Either<CricketResponse<CreatedTeamRes>, CricketFailure>,
          SetTeamLeadershipParams
        > {
  final TeamRepository teamRepository;

  SetTeamLeadershipUseCase({required this.teamRepository});

  @override
  Future<Either<CricketResponse<CreatedTeamRes>, CricketFailure>> call({
    SetTeamLeadershipParams? params,
  }) {
    return teamRepository.setLeadership(
      teamId: params!.teamId,
      params: params.req,
    );
  }
}
