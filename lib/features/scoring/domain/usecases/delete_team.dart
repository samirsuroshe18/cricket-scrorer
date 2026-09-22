import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/team_repository.dart';

class DeleteTeamParams {
  final String teamId;

  DeleteTeamParams({required this.teamId});
}

class DeleteTeamUseCase
    implements
        UseCase<
          Either<CricketResponse<void>, CricketFailure>,
          DeleteTeamParams
        > {
  final TeamRepository teamRepository;

  DeleteTeamUseCase({required this.teamRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    DeleteTeamParams? params,
  }) {
    return teamRepository.deleteTeam(teamId: params!.teamId);
  }
}
