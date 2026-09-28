import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/save_playing_xi_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_squad_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/squad_repository.dart';

class SavePlayingXiParams {
  final String matchId;
  final SavePlayingXiReq req;

  SavePlayingXiParams({required this.matchId, required this.req});
}

class SavePlayingXiUseCase
    implements
        UseCase<
          Either<CricketResponse<SquadSideRes>, CricketFailure>,
          SavePlayingXiParams
        > {
  final SquadRepository squadRepository;

  SavePlayingXiUseCase({required this.squadRepository});

  @override
  Future<Either<CricketResponse<SquadSideRes>, CricketFailure>> call({
    SavePlayingXiParams? params,
  }) {
    return squadRepository.savePlayingXi(
      matchId: params!.matchId,
      params: params.req,
    );
  }
}
