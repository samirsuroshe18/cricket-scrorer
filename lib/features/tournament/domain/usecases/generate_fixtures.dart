import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class GenerateFixturesParams {
  final String tournamentId;

  GenerateFixturesParams({required this.tournamentId});
}

class GenerateFixturesUseCase
    implements
        UseCase<Either<CricketResponse<void>, CricketFailure>,
            GenerateFixturesParams> {
  final TournamentRepository tournamentRepository;

  GenerateFixturesUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    GenerateFixturesParams? params,
  }) {
    return tournamentRepository.generateFixtures(
      tournamentId: params!.tournamentId,
    );
  }
}
