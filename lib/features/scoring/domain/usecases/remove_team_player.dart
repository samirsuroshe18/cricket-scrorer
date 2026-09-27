import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/team_repository.dart';

class RemoveTeamPlayerParams {
  final String teamId;
  final String playerId;

  RemoveTeamPlayerParams({required this.teamId, required this.playerId});
}

class RemoveTeamPlayerUseCase
    implements
        UseCase<
          Either<CricketResponse<void>, CricketFailure>,
          RemoveTeamPlayerParams
        > {
  final TeamRepository teamRepository;

  RemoveTeamPlayerUseCase({required this.teamRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    RemoveTeamPlayerParams? params,
  }) {
    return teamRepository.removePlayer(
      teamId: params!.teamId,
      playerId: params.playerId,
    );
  }
}
