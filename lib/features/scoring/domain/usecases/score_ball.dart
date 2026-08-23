import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class ScoreBallParams {
  final String matchId;
  final ScoreBallReq scoreBallReq;

  ScoreBallParams({required this.matchId, required this.scoreBallReq});
}

class ScoreBallUseCase
    implements
        UseCase<
          Either<CricketResponse<ScoreBallRes>, CricketFailure>,
          ScoreBallParams
        > {
  final MatchRepository matchRepository;

  ScoreBallUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<ScoreBallRes>, CricketFailure>> call({
    ScoreBallParams? params,
  }) {
    return matchRepository.scoreBall(
      matchId: params!.matchId,
      scoreBallReq: params.scoreBallReq,
    );
  }
}
