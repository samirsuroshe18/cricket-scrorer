import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TeamRef.logoUrl', () {
    test('parses a logoUrl when present', () {
      final ref = TeamRef.fromJson({
        'id': 't1',
        'name': 'Mumbai Indians',
        'logoUrl': 'https://res.cloudinary.com/demo/mumbai.png',
      });

      expect(ref.logoUrl, 'https://res.cloudinary.com/demo/mumbai.png');
    });

    test('is null when the key is absent or null', () {
      expect(TeamRef.fromJson({'id': 't1', 'name': 'A'}).logoUrl, isNull);
      expect(
        TeamRef.fromJson({'id': 't1', 'name': 'A', 'logoUrl': null}).logoUrl,
        isNull,
      );
    });

    test('round-trips through toJson', () {
      final ref = TeamRef(id: 't1', name: 'A', logoUrl: 'https://x/y.png');

      expect(TeamRef.fromJson(ref.toJson()).logoUrl, 'https://x/y.png');
    });
  });

  group('TeamProfileRes.logoUrl', () {
    test('parses logoUrl and defaults to null', () {
      final withLogo = TeamProfileRes.fromJson({
        'teamId': 't1',
        'name': 'A',
        'logoUrl': 'https://x/y.png',
        'canManage': true,
        'roster': <dynamic>[],
      });
      final without = TeamProfileRes.fromJson({
        'teamId': 't1',
        'name': 'A',
        'canManage': true,
        'roster': <dynamic>[],
      });

      expect(withLogo.logoUrl, 'https://x/y.png');
      expect(without.logoUrl, isNull);
    });
  });
}
