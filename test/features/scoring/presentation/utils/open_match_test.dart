import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/utils/open_match.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

MatchHistoryItem _item({
  String id = 'm1',
  String status = 'upcoming',
  bool squadAcknowledged = false,
}) => MatchHistoryItem(
  matchId: id,
  teamA: TeamRef(id: 'ta', name: 'Mumbai Indians'),
  teamB: TeamRef(id: 'tb', name: 'Chennai Kings'),
  joinCode: 'ABC123',
  totalOvers: 5,
  status: status,
  tossWinner: 'teamA',
  tossDecision: 'bat',
  createdAt: '2026-09-28T10:00:00.000Z',
  syncStatus: 'synced',
  squadAcknowledged: squadAcknowledged,
);

void main() {
  setUp(SquadAcknowledgements.reset);

  group('destinationFor', () {
    test('an upcoming match nobody has dealt with opens the Squad screen', () {
      expect(destinationFor(_item()), MatchDestination.squad);
    });

    test('an acknowledged upcoming match opens the scoring console', () {
      expect(
        destinationFor(_item(squadAcknowledged: true)),
        MatchDestination.scoring,
      );
    });

    test('live and innings-break matches always open the scoring console', () {
      for (final status in ['live', 'innings_break']) {
        expect(
          destinationFor(_item(status: status)),
          MatchDestination.scoring,
          reason: status,
        );
      }
    });

    test('finished matches open the result', () {
      for (final status in ['completed', 'abandoned']) {
        expect(
          destinationFor(_item(status: status)),
          MatchDestination.result,
          reason: status,
        );
      }
    });

    test(
      'a match acknowledged this session stays acknowledged before the list refreshes',
      () {
        final stale = _item(id: 'm7');

        SquadAcknowledgements.remember('m7');

        expect(destinationFor(stale), MatchDestination.scoring);
        expect(destinationFor(_item(id: 'm8')), MatchDestination.squad);
      },
    );
  });

  test(
    'toCreateMatchRes carries everything the console and Squad screen need',
    () {
      final res = toCreateMatchRes(_item());

      expect(res.matchId, 'm1');
      expect(res.teamA.id, 'ta');
      expect(res.teamB.name, 'Chennai Kings');
      expect(res.joinCode, 'ABC123');
      expect(res.totalOvers, 5);
      expect(res.tossWinner, 'teamA');
      expect(res.tossDecision, 'bat');
      expect(res.status, 'upcoming');
    },
  );

  group('openMatchFromHistory', () {
    setUp(() => Get.testMode = true);
    tearDown(Get.reset);

    Future<List<String>> pump(
      WidgetTester tester,
      MatchHistoryItem item,
    ) async {
      final seen = <String>[];
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/start',
          getPages: [
            GetPage<dynamic>(name: '/start', page: () => const SizedBox()),
            GetPage<dynamic>(
              name: AppRoutes.squad,
              page: () {
                seen.add('squad:${(Get.arguments as CreateMatchRes).matchId}');
                return const Text('squad');
              },
            ),
            GetPage<dynamic>(
              name: AppRoutes.scoreBall,
              page: () {
                seen.add('score:${(Get.arguments as CreateMatchRes).matchId}');
                return const Text('score');
              },
            ),
            GetPage<dynamic>(
              name: AppRoutes.matchResult,
              page: () => const Text('result'),
            ),
          ],
        ),
      );
      openMatchFromHistory(item);
      await tester.pumpAndSettle();
      return seen;
    }

    testWidgets('an unacknowledged upcoming match pushes the Squad screen', (
      tester,
    ) async {
      final seen = await pump(tester, _item());

      expect(seen, ['squad:m1']);
      expect(find.text('squad'), findsOneWidget);
    });

    testWidgets('an acknowledged upcoming match pushes the scoring console', (
      tester,
    ) async {
      final seen = await pump(tester, _item(squadAcknowledged: true));

      expect(seen, ['score:m1']);
    });

    testWidgets('a completed match pushes the result', (tester) async {
      await pump(tester, _item(status: 'completed'));

      expect(find.text('result'), findsOneWidget);
    });
  });
}
