import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _json({Object? acknowledged = _absent}) => {
  'matchId': 'm1',
  'teamA': {'id': 'ta', 'name': 'A'},
  'teamB': {'id': 'tb', 'name': 'B'},
  'totalOvers': 5,
  'status': 'upcoming',
  'createdAt': '2026-09-28T10:00:00.000Z',
  'syncStatus': 'synced',
  if (!identical(acknowledged, _absent)) 'squadAcknowledged': acknowledged,
};

const Object _absent = Object();

void main() {
  test('reads squadAcknowledged true and false', () {
    expect(
      MatchHistoryItem.fromJson(_json(acknowledged: true)).squadAcknowledged,
      isTrue,
    );
    expect(
      MatchHistoryItem.fromJson(_json(acknowledged: false)).squadAcknowledged,
      isFalse,
    );
  });

  test(
    'an older server that omits it counts as acknowledged, so nobody is sent to a screen it cannot clear',
    () {
      expect(MatchHistoryItem.fromJson(_json()).squadAcknowledged, isTrue);
    },
  );

  test('copyWith keeps it', () {
    final item = MatchHistoryItem.fromJson(_json(acknowledged: false));

    expect(item.copyWith().squadAcknowledged, isFalse);
  });
}
