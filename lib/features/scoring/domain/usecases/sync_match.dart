import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/sync_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/sync_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class SyncMatchParams {
  final String matchId;
  final SyncReq syncReq;

  SyncMatchParams({required this.matchId, required this.syncReq});
}

class SyncMatchUseCase
    implements
        UseCase<Either<CricketResponse<SyncRes>, CricketFailure>, SyncMatchParams> {
  final MatchRepository matchRepository;

  SyncMatchUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<SyncRes>, CricketFailure>> call({
    SyncMatchParams? params,
  }) {
    return matchRepository.syncMatch(
      matchId: params!.matchId,
      syncReq: params.syncReq,
    );
  }
}
