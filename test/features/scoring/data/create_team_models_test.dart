import 'package:cricket_scorer/features/scoring/data/match_endpoint.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_team_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/created_team_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('createTeam posts to /v1/team, never /api/v1/team', () {
    const endpoint = MatchEndpoint();

    expect(endpoint.createTeam, '/v1/team');
    expect(endpoint.createTeam.startsWith('/api'), isFalse);
  });

  test('CreateTeamReq serializes the name and short name', () {
    expect(
      CreateTeamReq(name: 'Riverside U19', shortName: 'RU19').toJson(),
      {'name': 'Riverside U19', 'shortName': 'RU19'},
    );
  });

  test('CreateTeamReq keeps an absent short name as null', () {
    expect(CreateTeamReq(name: 'Office XI').toJson()['shortName'], isNull);
  });

  test(
    'CreatedTeamRes reads the server payload, ignoring the extra fields',
    () {
      final res = CreatedTeamRes.fromJson({
        'id': 't1',
        'name': 'Riverside U19',
        'shortName': 'RU19',
        'logoUrl': null,
        'organization': null,
      });

      expect(res.id, 't1');
      expect(res.name, 'Riverside U19');
      expect(res.shortName, 'RU19');
    },
  );

  test('CreatedTeamRes tolerates a null short name', () {
    final res = CreatedTeamRes.fromJson({
      'id': 't2',
      'name': 'Office XI',
      'shortName': null,
    });

    expect(res.shortName, isNull);
  });
}
