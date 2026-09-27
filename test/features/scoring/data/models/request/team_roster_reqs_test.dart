import 'package:cricket_scorer/features/scoring/data/models/request/add_team_player_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/set_team_leadership_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/update_team_player_req.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddTeamPlayerReq.toJson', () {
    test('omits an unset role and jerseyNumber', () {
      expect(AddTeamPlayerReq(name: 'Rohit').toJson(), {'name': 'Rohit'});
    });

    test('sends playerId and omits name when only playerId is set', () {
      expect(AddTeamPlayerReq(playerId: 'p1').toJson(), {'playerId': 'p1'});
    });

    test('sends playerId together with role and jerseyNumber', () {
      expect(
        AddTeamPlayerReq(
          playerId: 'p1',
          role: 'bowler',
          jerseyNumber: 7,
        ).toJson(),
        {'playerId': 'p1', 'role': 'bowler', 'jerseyNumber': 7},
      );
    });

    test('includes role and jerseyNumber when set', () {
      expect(
        AddTeamPlayerReq(
          name: 'Rohit',
          role: 'batsman',
          jerseyNumber: 45,
        ).toJson(),
        {'name': 'Rohit', 'role': 'batsman', 'jerseyNumber': 45},
      );
    });
  });

  group('SetTeamLeadershipReq.toJson', () {
    test('keeps null leader keys so the server clears them', () {
      expect(
        SetTeamLeadershipReq(name: 'MI', shortName: 'MI').toJson(),
        {
          'name': 'MI',
          'shortName': 'MI',
          'captainId': null,
          'viceCaptainId': null,
        },
      );
    });

    test('omits a null shortName and carries both leader ids', () {
      expect(
        SetTeamLeadershipReq(
          name: 'MI',
          captainId: 'p1',
          viceCaptainId: 'p2',
        ).toJson(),
        {'name': 'MI', 'captainId': 'p1', 'viceCaptainId': 'p2'},
      );
    });
  });

  group('UpdateTeamPlayerReq.toJson', () {
    test('omits every unset field', () {
      expect(UpdateTeamPlayerReq().toJson(), <String, dynamic>{});
    });

    test('includes role and jerseyNumber when set', () {
      expect(
        UpdateTeamPlayerReq(role: 'bowler', jerseyNumber: 7).toJson(),
        {'role': 'bowler', 'jerseyNumber': 7},
      );
    });

    test(
      'clearJerseyNumber sends an explicit null so the server removes it',
      () {
        final json = UpdateTeamPlayerReq(clearJerseyNumber: true).toJson();

        expect(json.containsKey('jerseyNumber'), isTrue);
        expect(json['jerseyNumber'], isNull);
      },
    );

    test('clearJerseyNumber wins over a jerseyNumber value', () {
      final json = UpdateTeamPlayerReq(
        jerseyNumber: 7,
        clearJerseyNumber: true,
      ).toJson();

      expect(json['jerseyNumber'], isNull);
    });
  });
}
