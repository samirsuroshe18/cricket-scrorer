import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/save_squad_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/squad_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/squad_repository.dart';

class SaveSquadParams {
  final String matchId;
  final SaveSquadReq req;

  SaveSquadParams({required this.matchId, required this.req});
}

class SaveSquadUseCase
    implements
        UseCase<
          Either<CricketResponse<SquadRes>, CricketFailure>,
          SaveSquadParams
        > {
  final SquadRepository squadRepository;

  SaveSquadUseCase({required this.squadRepository});

  @override
  Future<Either<CricketResponse<SquadRes>, CricketFailure>> call({
    SaveSquadParams? params,
  }) {
    return squadRepository.saveSquad(
      matchId: params!.matchId,
      params: params.req,
    );
  }
}
