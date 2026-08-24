import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/start_innings_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/start_innings_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class StartInningsParams {
  final String matchId;
  final StartInningsReq startInningsReq;

  StartInningsParams({required this.matchId, required this.startInningsReq});
}

class StartInningsUseCase
    implements
        UseCase<
          Either<CricketResponse<StartInningsRes>, CricketFailure>,
          StartInningsParams
        > {
  final MatchRepository matchRepository;

  StartInningsUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<StartInningsRes>, CricketFailure>> call({
    StartInningsParams? params,
  }) {
    return matchRepository.startInnings(
      matchId: params!.matchId,
      startInningsReq: params.startInningsReq,
    );
  }
}
