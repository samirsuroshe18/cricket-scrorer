import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/squad_repository.dart';

class AcknowledgeSquadParams {
  final String matchId;

  AcknowledgeSquadParams({required this.matchId});
}

/// Records on the server that the scorer has dealt with the Squad screen for
/// this match (Skip, or Save & continue), so it stops being offered.
class AcknowledgeSquadUseCase
    implements
        UseCase<
          Either<CricketResponse<void>, CricketFailure>,
          AcknowledgeSquadParams
        > {
  final SquadRepository squadRepository;

  AcknowledgeSquadUseCase({required this.squadRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    AcknowledgeSquadParams? params,
  }) {
    return squadRepository.acknowledgeSquad(matchId: params!.matchId);
  }
}
