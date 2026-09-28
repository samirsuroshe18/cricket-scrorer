import 'package:cricket_scorer/features/scoring/data/models/response/looked_up_user_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_players_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/player_invite_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invite_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyPlayersRes', () {
    test('parses rows, paging and the optional per-row fields', () {
      final res = MyPlayersRes.fromJson({
        'players': [
          {
            'playerId': 'p1',
            'playerName': 'Rohit',
            'role': 'batsman',
            'jerseyNumber': 45,
            'isClaimed': true,
            'onTeam': true,
          },
          {'playerId': 'p2', 'playerName': 'Amit', 'role': 'bowler'},
        ],
        'page': 1,
        'limit': 20,
        'total': 2,
      });

      expect(res.players.first.playerName, 'Rohit');
      expect(res.players.first.jerseyNumber, 45);
      expect(res.players.first.isClaimed, isTrue);
      expect(res.players.first.onTeam, isTrue);
      expect(res.players.last.jerseyNumber, isNull);
      expect(res.players.last.isClaimed, isFalse);
      expect(res.players.last.onTeam, isFalse);
      expect(res.total, 2);
    });

    test('hasMore is true only while more pages remain', () {
      MyPlayersRes page(int p, int total) => MyPlayersRes.fromJson({
        'players': <Map<String, dynamic>>[],
        'page': p,
        'limit': 20,
        'total': total,
      });

      expect(page(1, 21).hasMore, isTrue);
      expect(page(2, 21).hasMore, isFalse);
      expect(page(1, 20).hasMore, isFalse);
      expect(page(1, 0).hasMore, isFalse);
    });
  });

  group('LookedUpUserRes', () {
    test('parses all four fields', () {
      final res = LookedUpUserRes.fromJson({
        'userId': 'u1',
        'fullName': 'Rahul Sharma',
        'userName': 'rahul_s',
        'photoUrl': 'https://x/p.png',
      });

      expect(res.userId, 'u1');
      expect(res.fullName, 'Rahul Sharma');
      expect(res.userName, 'rahul_s');
      expect(res.photoUrl, 'https://x/p.png');
    });

    test('reads null userName and photoUrl', () {
      final res = LookedUpUserRes.fromJson({
        'userId': 'u1',
        'fullName': 'Rahul Sharma',
        'userName': null,
        'photoUrl': null,
      });

      expect(res.userName, isNull);
      expect(res.photoUrl, isNull);
    });
  });

  group('TeamInviteRes', () {
    Map<String, dynamic> player() => {
      'playerId': 'p1',
      'playerName': 'Rahul Sharma',
      'role': 'unknown',
    };

    test('parses a new pending invite with its roster row', () {
      final res = TeamInviteRes.fromJson({
        'inviteId': 'i1',
        'status': 'pending',
        'player': player(),
      });

      expect(res.inviteId, 'i1');
      expect(res.status, 'pending');
      expect(res.player.playerName, 'Rahul Sharma');
    });

    test('parses the already-linked case: null inviteId, accepted', () {
      final res = TeamInviteRes.fromJson({
        'inviteId': null,
        'status': 'accepted',
        'player': player(),
      });

      expect(res.inviteId, isNull);
      expect(res.status, 'accepted');
    });
  });

  group('PlayerInviteRes and PlayerInviteAnswerRes', () {
    test('PlayerInviteRes parses the invitee-facing details', () {
      final res = PlayerInviteRes.fromJson({
        'inviteId': 'i1',
        'status': 'pending',
        'teamId': 't1',
        'teamName': 'Riverside U19',
        'invitedByName': 'Scorer Sam',
        'playerName': 'Rahul Sharma',
      });

      expect(res.isPending, isTrue);
      expect(res.teamName, 'Riverside U19');
      expect(res.invitedByName, 'Scorer Sam');
    });

    test('isPending is false once accepted or declined', () {
      PlayerInviteRes withStatus(String status) => PlayerInviteRes.fromJson({
        'inviteId': 'i1',
        'status': status,
        'teamId': 't1',
        'teamName': 'T',
      });

      expect(withStatus('accepted').isPending, isFalse);
      expect(withStatus('declined').isPending, isFalse);
      expect(withStatus('declined').invitedByName, isNull);
    });

    test('PlayerInviteAnswerRes parses accept and decline bodies', () {
      final accepted = PlayerInviteAnswerRes.fromJson({
        'inviteId': 'i1',
        'status': 'accepted',
        'playerId': 'p1',
      });
      final declined = PlayerInviteAnswerRes.fromJson({
        'inviteId': 'i1',
        'status': 'declined',
      });

      expect(accepted.playerId, 'p1');
      expect(declined.status, 'declined');
      expect(declined.playerId, isNull);
    });
  });
}
