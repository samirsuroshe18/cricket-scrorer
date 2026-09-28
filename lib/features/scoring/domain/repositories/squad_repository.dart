import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/save_playing_xi_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/save_squad_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_squad_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/squad_res.dart';

/// Reads and writes `/v1/match/:matchId/squad…`. Kept apart from
/// `MatchRepository`, like `TeamRepository`, so adding to it never touches
/// the many test doubles that stand in for `MatchRepository`.
abstract class SquadRepository {
  /// `PUT /v1/match/:matchId/squad/:side` — replaces one side's squad.
  Future<Either<CricketResponse<SquadRes>, CricketFailure>> saveSquad({
    required String matchId,
    required SaveSquadReq params,
  });

  /// `GET /v1/match/:matchId/squad` — both sides as saved.
  Future<Either<CricketResponse<MatchSquadRes>, CricketFailure>> getMatchSquad({
    required String matchId,
  });

  /// `PATCH /v1/match/:matchId/squad/:side/playing-xi` — moves by player id;
  /// works after scoring has started.
  Future<Either<CricketResponse<SquadSideRes>, CricketFailure>> savePlayingXi({
    required String matchId,
    required SavePlayingXiReq params,
  });
}
