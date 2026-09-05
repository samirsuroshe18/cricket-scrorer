import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/assign_scorer_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

MatchHistoryItem _item({MatchUserRef? assignedScorer}) => MatchHistoryItem(
  matchId: 'match-1',
  teamA: TeamRef(id: 'team-a', name: 'Mumbai Indians'),
  teamB: TeamRef(id: 'team-b', name: 'Chennai Super Kings'),
  totalOvers: 20,
  status: 'upcoming',
  assignedScorer: assignedScorer,
  createdAt: '2026-08-20T10:15:00.000Z',
);

void main() {
  Future<void> pumpOpenButton({
    required WidgetTester tester,
    required MatchHistoryItem item,
    required Future<List<MatchUserRef>?> Function(String matchId)
    loadCandidates,
    required Future<bool> Function(String matchId, String? scorerId)
    onAssign,
  }) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAssignScorerSheet(
                item: item,
                loadCandidates: loadCandidates,
                onAssign: onAssign,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    // Frame-by-frame rather than pumpAndSettle — see tapAndAwaitSnackbar's
    // comment. This same race applies here too: `loadCandidates` resolving
    // to an empty list shows an error snackbar directly from this same tap.
    await tester.tap(find.text('open'));
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  // GetX's SnackbarController races the bottom sheet's own pop animation
  // when the snackbar is shown from the continuation after `Get.back()`
  // (as `showAssignScorerSheet` does) — `pumpAndSettle()` resolves before
  // the snackbar's entrance animation actually starts, so its text is
  // never queryable afterward. Pumping frame-by-frame instead (rather than
  // one large jump) is what actually lets it insert into the overlay.
  Future<void> tapAndAwaitSnackbar(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  // The snackbar's own 3-second auto-dismiss timer is still running an
  // AnimationController when a test would otherwise end — tearing down the
  // widget tree with that ticker still active is a framework-level test
  // failure ("OverlayState... was disposed with an active Ticker"), even
  // though every assertion in the test body already passed. Draining the
  // full duration first lets it dispose itself cleanly.
  Future<void> drainSnackbar(WidgetTester tester) async {
    // Frame-by-frame again, same reasoning as tapAndAwaitSnackbar — one
    // large jump makes the snackbar's own AnimationController finish and
    // start disposing mid-pump, racing the Overlay's removal and throwing
    // the same "disposed with an active Ticker" assertion this is meant to
    // avoid.
    for (var i = 0; i < 220; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  testWidgets(
    'loadCandidates returning null opens no sheet and calls onAssign never',
    (tester) async {
      var assignCalled = false;

      await pumpOpenButton(
        tester: tester,
        item: _item(),
        loadCandidates: (_) async => null,
        onAssign: (_, _) async {
          assignCalled = true;
          return true;
        },
      );

      // No headline text, in either translated or raw-key form, since no
      // sheet should ever have opened — `assign_scorer` is the raw key
      // (.tr falls back to it: no translations are loaded in this bare
      // widget test).
      expect(find.text('assign_scorer'), findsNothing);
      expect(assignCalled, isFalse);
    },
  );

  testWidgets(
    'an empty candidate list shows the no-candidates message and opens no sheet',
    (tester) async {
      await pumpOpenButton(
        tester: tester,
        item: _item(),
        loadCandidates: (_) async => [],
        onAssign: (_, _) async => true,
      );

      expect(find.text('no_scorer_candidates'), findsOneWidget);
      expect(find.text('assign_scorer'), findsNothing);
      await drainSnackbar(tester);
    },
  );

  testWidgets(
    'a real candidate list opens the sheet and tapping a name assigns it',
    (tester) async {
      String? assignedMatchId;
      String? assignedScorerId;

      await pumpOpenButton(
        tester: tester,
        item: _item(),
        loadCandidates: (_) async => [
          MatchUserRef(id: 'user-1', name: 'Raj Patel'),
          MatchUserRef(id: 'user-2', name: 'Asha Rao'),
        ],
        onAssign: (matchId, scorerId) async {
          assignedMatchId = matchId;
          assignedScorerId = scorerId;
          return true;
        },
      );

      expect(find.text('Raj Patel'), findsOneWidget);
      expect(find.text('Asha Rao'), findsOneWidget);

      await tapAndAwaitSnackbar(tester, find.text('Raj Patel'));

      expect(assignedMatchId, 'match-1');
      expect(assignedScorerId, 'user-1');
      // The sheet closes and the success snackbar shows the assign wording,
      // not the unassign one — this is the raw key `scorer_assigned`.
      expect(find.text('scorer_assigned'), findsOneWidget);
      await drainSnackbar(tester);
    },
  );

  testWidgets(
    'the currently-assigned candidate shows the current-scorer pill, and no '
    'remove-assignment control appears when nobody is assigned yet',
    (tester) async {
      await pumpOpenButton(
        tester: tester,
        item: _item(),
        loadCandidates: (_) async => [
          MatchUserRef(id: 'user-1', name: 'Raj Patel'),
        ],
        onAssign: (_, _) async => true,
      );

      expect(find.text('current_scorer'), findsNothing);
      expect(find.text('remove_assignment'), findsNothing);
    },
  );

  testWidgets(
    'tapping "remove assignment" clears the scorer and shows the unassign '
    'wording, not the assign one',
    (tester) async {
      String? clearedMatchId;
      Object? clearedScorerId = 'not-called';

      await pumpOpenButton(
        tester: tester,
        item: _item(assignedScorer: MatchUserRef(id: 'user-1', name: 'Raj Patel')),
        loadCandidates: (_) async => [
          MatchUserRef(id: 'user-1', name: 'Raj Patel'),
        ],
        onAssign: (matchId, scorerId) async {
          clearedMatchId = matchId;
          clearedScorerId = scorerId;
          return true;
        },
      );

      // The already-assigned candidate is marked, and the remove control is
      // offered since a scorer is already set.
      expect(find.text('current_scorer'), findsOneWidget);
      expect(find.text('remove_assignment'), findsOneWidget);

      await tapAndAwaitSnackbar(tester, find.text('remove_assignment'));

      expect(clearedMatchId, 'match-1');
      expect(clearedScorerId, isNull);
      // The regression this test locks in: clearing must not show the
      // "assigned" success message.
      expect(find.text('scorer_unassigned'), findsOneWidget);
      expect(find.text('scorer_assigned'), findsNothing);
      await drainSnackbar(tester);
    },
  );
}
