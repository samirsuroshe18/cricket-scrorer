import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/start_fixture_match_req.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class StartFixtureMatchParams {
  final String tournamentId;
  final String fixtureId;
  final int totalOvers;
  final String? tossWinner;
  final String? tossDecision;

  StartFixtureMatchParams({
    required this.tournamentId,
    required this.fixtureId,
    required this.totalOvers,
    this.tossWinner,
    this.tossDecision,
  });
}

class StartFixtureMatchUseCase
    implements
        UseCase<Either<CricketResponse<CreateMatchRes>, CricketFailure>,
            StartFixtureMatchParams> {
  final TournamentRepository tournamentRepository;

  StartFixtureMatchUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<CreateMatchRes>, CricketFailure>> call({
    StartFixtureMatchParams? params,
  }) {
    return tournamentRepository.startFixtureMatch(
      tournamentId: params!.tournamentId,
      fixtureId: params.fixtureId,
      params: StartFixtureMatchReq(
        totalOvers: params.totalOvers,
        tossWinner: params.tossWinner,
        tossDecision: params.tossDecision,
      ),
    );
  }
}
