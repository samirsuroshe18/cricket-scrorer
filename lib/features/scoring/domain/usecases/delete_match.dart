import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/delete_match_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class DeleteMatchUseCase
    implements
        UseCase<
          Either<CricketResponse<DeleteMatchRes>, CricketFailure>,
          String
        > {
  final MatchRepository matchRepository;

  DeleteMatchUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<DeleteMatchRes>, CricketFailure>> call({
    String? params,
  }) {
    return matchRepository.deleteMatch(matchId: params!);
  }
}
