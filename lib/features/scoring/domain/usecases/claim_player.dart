import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class ClaimPlayerUseCase
    implements
        UseCase<
          Either<CricketResponse<Map<String, dynamic>>, CricketFailure>,
          String
        > {
  final MatchRepository matchRepository;

  ClaimPlayerUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>> call({
    String? params,
  }) {
    return matchRepository.claimPlayer(playerId: params ?? '');
  }
}
