import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/select_bowler_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/select_bowler_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class SelectBowlerParams {
  final String matchId;
  final SelectBowlerReq selectBowlerReq;

  SelectBowlerParams({required this.matchId, required this.selectBowlerReq});
}

class SelectBowlerUseCase
    implements
        UseCase<
          Either<CricketResponse<SelectBowlerRes>, CricketFailure>,
          SelectBowlerParams
        > {
  final MatchRepository matchRepository;

  SelectBowlerUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<SelectBowlerRes>, CricketFailure>> call({
    SelectBowlerParams? params,
  }) {
    return matchRepository.selectBowler(
      matchId: params!.matchId,
      selectBowlerReq: params.selectBowlerReq,
    );
  }
}
