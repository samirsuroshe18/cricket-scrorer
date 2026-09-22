import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_team_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/created_team_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/team_repository.dart';

class UpdateTeamParams {
  final String teamId;
  final CreateTeamReq req;

  UpdateTeamParams({required this.teamId, required this.req});
}

class UpdateTeamUseCase
    implements
        UseCase<
          Either<CricketResponse<CreatedTeamRes>, CricketFailure>,
          UpdateTeamParams
        > {
  final TeamRepository teamRepository;

  UpdateTeamUseCase({required this.teamRepository});

  @override
  Future<Either<CricketResponse<CreatedTeamRes>, CricketFailure>> call({
    UpdateTeamParams? params,
  }) {
    return teamRepository.updateTeam(
      teamId: params!.teamId,
      params: params.req,
    );
  }
}
