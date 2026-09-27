import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_player_view_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_player_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_player_view.dart';

TeamPlayerViewRes samplePlayerView({String teamId = 't1'}) => TeamPlayerViewRes(
  teamId: teamId,
  name: 'Mumbai Indians',
  shortName: 'MI',
  roster: [
    TeamPlayerRosterPlayer(
      playerId: 'p1',
      playerName: 'Mohit Zatu',
      role: 'batsman',
      jerseyNumber: 7,
    ),
    TeamPlayerRosterPlayer(
      playerId: 'p2',
      playerName: 'Captain Cool',
      role: 'allrounder',
      isCaptain: true,
    ),
  ],
  captainId: 'p2',
);

MatchHistoryItem sampleMatch(
  String id, {
  String status = 'live',
  String? joinCode = 'ABC123',
}) => MatchHistoryItem(
  matchId: id,
  teamA: TeamRef(id: 't1', name: 'Mumbai Indians'),
  teamB: TeamRef(id: 't2', name: 'Chennai Kings'),
  joinCode: joinCode,
  totalOvers: 5,
  status: status,
  createdAt: '2026-09-27T10:00:00.000Z',
  syncStatus: 'synced',
);

class FakeGetTeamPlayerView implements GetTeamPlayerViewUseCase {
  Either<CricketResponse<TeamPlayerViewRes>, CricketFailure> response =
      Either.result(
        CricketResponse(message: 'ok', data: samplePlayerView()),
      );
  int calls = 0;

  @override
  Future<Either<CricketResponse<TeamPlayerViewRes>, CricketFailure>> call({
    GetTeamPlayerViewParams? params,
  }) async {
    calls++;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class FakeGetTeamPlayerMatches implements GetTeamPlayerMatchesUseCase {
  /// Matches to return per requested status; anything else is empty.
  final Map<String, List<MatchHistoryItem>> byStatus = {};
  Either<CricketResponse<MatchHistoryRes>, CricketFailure>? failure;
  final statuses = <String>[];
  final pages = <int>[];
  int total = 0;

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>> call({
    GetTeamPlayerMatchesParams? params,
  }) async {
    statuses.add(params!.status);
    pages.add(params.page);
    if (failure != null) return failure!;
    final items = byStatus[params.status] ?? const <MatchHistoryItem>[];
    return Either.result(
      CricketResponse(
        message: 'ok',
        data: MatchHistoryRes(
          matches: items,
          page: params.page,
          limit: params.limit,
          total: total == 0 ? items.length : total,
        ),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}
