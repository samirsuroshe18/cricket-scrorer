import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart';
import 'package:cricket_scorer/features/scoring/data/repositories/player_invite_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMatchApiService implements MatchApiService {
  Either<ApiResponseModel, CricketFailure>? response;
  final calls = <String, Map<String, Object?>>{};

  Future<Either<ApiResponseModel, CricketFailure>> _record(
    String name,
    Map<String, Object?> args,
  ) async {
    calls[name] = args;
    return response!;
  }

  @override
  Future<Either<ApiResponseModel, CricketFailure>> getMyPlayers({
    required String teamId,
    String? q,
    required int page,
    required int limit,
  }) => _record('getMyPlayers', {
    'teamId': teamId,
    'q': q,
    'page': page,
    'limit': limit,
  });

  @override
  Future<Either<ApiResponseModel, CricketFailure>> lookupUserByEmail({
    required String email,
  }) => _record('lookupUserByEmail', {'email': email});

  @override
  Future<Either<ApiResponseModel, CricketFailure>> inviteTeamPlayer({
    required String teamId,
    required String userId,
  }) => _record('inviteTeamPlayer', {'teamId': teamId, 'userId': userId});

  @override
  Future<Either<ApiResponseModel, CricketFailure>> getPlayerInvite({
    required String inviteId,
  }) => _record('getPlayerInvite', {'inviteId': inviteId});

  @override
  Future<Either<ApiResponseModel, CricketFailure>> respondToPlayerInvite({
    required String inviteId,
    required bool accept,
  }) => _record('respondToPlayerInvite', {
    'inviteId': inviteId,
    'accept': accept,
  });

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

Either<ApiResponseModel, CricketFailure> _ok(Object? data) => Either.result(
  ApiResponseModel(statusCode: 200, data: data, message: 'ok', success: true),
);

void main() {
  late _FakeMatchApiService api;
  late PlayerInviteRepositoryImpl repository;

  setUp(() {
    api = _FakeMatchApiService();
    repository = PlayerInviteRepositoryImpl(matchApiService: api);
  });

  test('getMyPlayers parses MyPlayersRes and forwards the query', () async {
    api.response = _ok({
      'players': [
        {'playerId': 'p1', 'playerName': 'Rohit', 'role': 'batsman'},
      ],
      'page': 2,
      'limit': 20,
      'total': 21,
    });

    final result = await repository.getMyPlayers(
      teamId: 't1',
      q: 'roh',
      page: 2,
      limit: 20,
    );

    expect(result.result.data?.players.single.playerName, 'Rohit');
    expect(result.result.message, 'ok');
    expect(api.calls['getMyPlayers'], {
      'teamId': 't1',
      'q': 'roh',
      'page': 2,
      'limit': 20,
    });
  });

  test('lookupUserByEmail parses LookedUpUserRes', () async {
    api.response = _ok({
      'userId': 'u1',
      'fullName': 'Rahul Sharma',
      'userName': null,
      'photoUrl': null,
    });

    final result = await repository.lookupUserByEmail(email: 'r@x.com');

    expect(result.result.data?.fullName, 'Rahul Sharma');
    expect(api.calls['lookupUserByEmail'], {'email': 'r@x.com'});
  });

  test('inviteTeamPlayer parses TeamInviteRes', () async {
    api.response = _ok({
      'inviteId': 'i1',
      'status': 'pending',
      'player': {'playerId': 'p1', 'playerName': 'Rahul', 'role': 'unknown'},
    });

    final result = await repository.inviteTeamPlayer(
      teamId: 't1',
      userId: 'u1',
    );

    expect(result.result.data?.inviteId, 'i1');
    expect(api.calls['inviteTeamPlayer'], {'teamId': 't1', 'userId': 'u1'});
  });

  test('getPlayerInvite parses PlayerInviteRes', () async {
    api.response = _ok({
      'inviteId': 'i1',
      'status': 'pending',
      'teamId': 't1',
      'teamName': 'Riverside',
    });

    final result = await repository.getPlayerInvite(inviteId: 'i1');

    expect(result.result.data?.teamName, 'Riverside');
    expect(api.calls['getPlayerInvite'], {'inviteId': 'i1'});
  });

  test('respondToPlayerInvite parses the answer and forwards accept', () async {
    api.response = _ok({
      'inviteId': 'i1',
      'status': 'accepted',
      'playerId': 'p1',
    });

    final result = await repository.respondToPlayerInvite(
      inviteId: 'i1',
      accept: true,
    );

    expect(result.result.data?.playerId, 'p1');
    expect(api.calls['respondToPlayerInvite'], {
      'inviteId': 'i1',
      'accept': true,
    });
  });

  test('every method passes a failure through unchanged', () async {
    final failure = CricketServerErrorFailure(message: 'boom');
    api.response = Either.fallback(failure);

    final results = [
      await repository.getMyPlayers(teamId: 't', page: 1, limit: 20),
      await repository.lookupUserByEmail(email: 'a@b.co'),
      await repository.inviteTeamPlayer(teamId: 't', userId: 'u'),
      await repository.getPlayerInvite(inviteId: 'i'),
      await repository.respondToPlayerInvite(inviteId: 'i', accept: false),
    ];

    for (final result in results) {
      expect(result.isResult, isFalse);
      expect(result.fallback, same(failure));
    }
  });
}
