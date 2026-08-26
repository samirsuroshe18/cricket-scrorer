import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/undo_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/undo_ball_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class UndoBallParams {
  final String matchId;
  final UndoBallReq undoBallReq;

  UndoBallParams({required this.matchId, required this.undoBallReq});
}

class UndoBallUseCase
    implements
        UseCase<
          Either<CricketResponse<UndoBallRes>, CricketFailure>,
          UndoBallParams
        > {
  final MatchRepository matchRepository;

  UndoBallUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<UndoBallRes>, CricketFailure>> call({
    UndoBallParams? params,
  }) {
    return matchRepository.undoBall(
      matchId: params!.matchId,
      undoBallReq: params.undoBallReq,
    );
  }
}
