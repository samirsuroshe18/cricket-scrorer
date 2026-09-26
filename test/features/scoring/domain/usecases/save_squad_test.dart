import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/save_squad_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/squad_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/squad_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/save_squad.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSquadRepository implements SquadRepository {
  String? lastMatchId;
  SaveSquadReq? lastParams;

  @override
  Future<Either<CricketResponse<SquadRes>, CricketFailure>> saveSquad({
    required String matchId,
    required SaveSquadReq params,
  }) async {
    lastMatchId = matchId;
    lastParams = params;
    return Either.result(
      CricketResponse(
        message: 'ok',
        data: SquadRes(side: params.side, players: const []),
      ),
    );
  }
}

void main() {
  test(
    'calls SquadRepository.saveSquad with the given matchId and body',
    () async {
      final repository = _FakeSquadRepository();
      final useCase = SaveSquadUseCase(squadRepository: repository);
      final req = SaveSquadReq(side: 'teamB', players: const []);

      final result = await useCase(
        params: SaveSquadParams(matchId: 'm1', req: req),
      );

      expect(result.isResult, isTrue);
      expect(repository.lastMatchId, 'm1');
      expect(repository.lastParams, same(req));
    },
  );
}
