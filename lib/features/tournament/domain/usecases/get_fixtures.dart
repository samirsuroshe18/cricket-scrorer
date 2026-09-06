import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class GetFixturesParams {
  final String tournamentId;

  GetFixturesParams({required this.tournamentId});
}

class GetFixturesUseCase
    implements
        UseCase<Either<CricketResponse<List<FixtureRes>>, CricketFailure>,
            GetFixturesParams> {
  final TournamentRepository tournamentRepository;

  GetFixturesUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<List<FixtureRes>>, CricketFailure>> call({
    GetFixturesParams? params,
  }) {
    return tournamentRepository.getFixtures(tournamentId: params!.tournamentId);
  }
}
