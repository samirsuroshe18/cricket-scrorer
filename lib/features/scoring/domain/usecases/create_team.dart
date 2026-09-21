import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_team_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/created_team_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/team_repository.dart';

class CreateTeamUseCase
    implements
        UseCase<
          Either<CricketResponse<CreatedTeamRes>, CricketFailure>,
          CreateTeamReq
        > {
  final TeamRepository teamRepository;

  CreateTeamUseCase({required this.teamRepository});

  @override
  Future<Either<CricketResponse<CreatedTeamRes>, CricketFailure>> call({
    CreateTeamReq? params,
  }) {
    return teamRepository.createTeam(params: params!);
  }
}
