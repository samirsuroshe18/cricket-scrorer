import 'package:cricket_scorer/features/scoring/data/models/request/create_match_req.dart';
import 'package:flutter_test/flutter_test.dart';

// teamAId/teamBId let a scorer reuse an existing Team instead of creating a
// new one for that side — see docs/api.md's updated "POST /v1/match/create".
void main() {
  test('toJson carries teamAId/teamBId as null when no team is reused', () {
    final req = CreateMatchReq(
      teamAName: 'Mumbai Indians',
      teamBName: 'Chennai Super Kings',
      totalOvers: 20,
    );

    final json = req.toJson();
    expect(json['teamAId'], isNull);
    expect(json['teamBId'], isNull);
  });

  test('toJson carries teamAId/teamBId when a team is reused', () {
    final req = CreateMatchReq(
      teamAName: 'Mumbai Indians',
      teamBName: 'Chennai Super Kings',
      totalOvers: 20,
      teamAId: '665f1a2b3c4d5e6f7a8b9c01',
    );

    expect(req.toJson()['teamAId'], '665f1a2b3c4d5e6f7a8b9c01');
    expect(req.toJson()['teamBId'], isNull);
  });
}
