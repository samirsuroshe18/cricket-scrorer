import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/resolve_fixture_req.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class ResolveFixtureParams {
  final String tournamentId;
  final String fixtureId;
  final String winnerTeamId;

  ResolveFixtureParams({
    required this.tournamentId,
    required this.fixtureId,
    required this.winnerTeamId,
  });
}

class ResolveFixtureUseCase
    implements
        UseCase<Either<CricketResponse<void>, CricketFailure>,
            ResolveFixtureParams> {
  final TournamentRepository tournamentRepository;

  ResolveFixtureUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    ResolveFixtureParams? params,
  }) {
    return tournamentRepository.resolveFixture(
      tournamentId: params!.tournamentId,
      fixtureId: params.fixtureId,
      params: ResolveFixtureReq(winner: params.winnerTeamId),
    );
  }
}
