import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TeamSummary parses logoUrl when present', () {
    final team = TeamSummary.fromJson({
      'id': 't1',
      'name': 'Mumbai Indians',
      'logoUrl': 'https://res.cloudinary.com/demo/mumbai.png',
    });

    expect(team.logoUrl, 'https://res.cloudinary.com/demo/mumbai.png');
  });

  test('TeamSummary.logoUrl is null when the key is absent or null', () {
    expect(TeamSummary.fromJson({'id': 't1', 'name': 'A'}).logoUrl, isNull);
    expect(
      TeamSummary.fromJson({'id': 't1', 'name': 'A', 'logoUrl': null}).logoUrl,
      isNull,
    );
  });
}
