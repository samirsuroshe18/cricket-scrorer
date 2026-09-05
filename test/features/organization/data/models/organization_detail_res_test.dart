import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OrganizationDetailRes.fromJson parses owner, members, and teams', () {
    final json = {
      'id': 'org-1',
      'name': 'Riverside Cricket Club',
      'owner': {'id': 'user-1', 'name': 'Asha'},
      'members': [
        {'id': 'user-1', 'name': 'Asha', 'role': 'owner'},
        {'id': 'user-2', 'name': 'Vikram', 'role': 'member'},
      ],
      'teams': [
        {'id': 'team-1', 'name': 'Riverside U19', 'shortName': 'RU19'},
      ],
      'tournaments': <Map<String, dynamic>>[],
    };

    final res = OrganizationDetailRes.fromJson(json);

    expect(res.id, 'org-1');
    expect(res.name, 'Riverside Cricket Club');
    expect(res.owner.name, 'Asha');
    expect(res.members.length, 2);
    expect(res.members[1].role, 'member');
    expect(res.teams.single.shortName, 'RU19');
  });

  test('OrganizationDetailRes.fromJson handles a team with no shortName', () {
    final json = {
      'id': 'org-1',
      'name': 'Riverside Cricket Club',
      'owner': {'id': 'user-1', 'name': 'Asha'},
      'members': <Map<String, dynamic>>[],
      'teams': [
        {'id': 'team-1', 'name': 'Riverside U19', 'shortName': null},
      ],
      'tournaments': <Map<String, dynamic>>[],
    };

    final res = OrganizationDetailRes.fromJson(json);

    expect(res.teams.single.shortName, isNull);
  });

  test('OrganizationDetailRes.fromJson parses tournaments', () {
    final json = {
      'id': 'org-1',
      'name': 'Riverside Cricket Club',
      'owner': {'id': 'user-1', 'name': 'Asha'},
      'members': <Map<String, dynamic>>[],
      'teams': <Map<String, dynamic>>[],
      'tournaments': [
        {
          'id': 'tournament-1',
          'name': 'Summer T20',
          'format': 'knockout',
          'status': 'upcoming',
          'teamCount': 2,
        },
      ],
    };

    final res = OrganizationDetailRes.fromJson(json);

    expect(res.tournaments.single.name, 'Summer T20');
    expect(res.tournaments.single.teamCount, 2);
  });
}
