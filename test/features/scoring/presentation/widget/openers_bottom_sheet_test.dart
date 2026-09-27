import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/openers_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

typedef _OnSubmit =
    Future<bool> Function(
      String strikerName,
      String nonStrikerName,
      String bowlerName, {
      String? strikerId,
      String? nonStrikerId,
      String? bowlerId,
    });

void main() {
  final battingRoster = [
    TeamRosterPlayer(
      playerId: 'p-rohit',
      playerName: 'Rohit Sharma',
      role: 'batsman',
    ),
    TeamRosterPlayer(
      playerId: 'p-ishan',
      playerName: 'Ishan Kishan',
      role: 'batsman',
    ),
  ];
  final bowlingRoster = [
    TeamRosterPlayer(
      playerId: 'p-bumrah',
      playerName: 'Jasprit Bumrah',
      role: 'bowler',
    ),
  ];

  Future<void> pumpSheet(
    WidgetTester tester,
    _OnSubmit onSubmit, {
    List<TeamRosterPlayer> battingRoster = const [],
    List<TeamRosterPlayer> bowlingRoster = const [],
    bool Function() canUndo = _neverCanUndo,
    Future<bool> Function() onUndo = _neverUndo,
    int? previousInningsRuns,
    int? previousInningsWickets,
    String? previousInningsOvers,
  }) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => OpenersBottomSheet.show(
                onSubmit: onSubmit,
                isSubmitting: false.obs,
                battingRoster: battingRoster,
                bowlingRoster: bowlingRoster,
                canUndo: canUndo,
                isUndoing: false.obs,
                onUndo: onUndo,
                previousInningsRuns: previousInningsRuns,
                previousInningsWickets: previousInningsWickets,
                previousInningsOvers: previousInningsOvers,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'shows the batting side\'s roster as chips for striker and non-striker, '
    'and the bowling side\'s roster for the opening bowler',
    (WidgetTester tester) async {
      await pumpSheet(
        tester,
        (_, _, _, {strikerId, nonStrikerId, bowlerId}) async => true,
        battingRoster: battingRoster,
        bowlingRoster: bowlingRoster,
      );

      // Each batting-side player is offered for both opener roles, so their
      // chips appear once per role's picker; the bowling side is offered
      // only for the opening bowler.
      expect(find.text('Rohit Sharma'), findsNWidgets(2));
      expect(find.text('Ishan Kishan'), findsNWidgets(2));
      expect(find.text('Jasprit Bumrah'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping a striker chip fills the field and sends its id, not just the name',
    (WidgetTester tester) async {
      String? submittedStrikerId;

      await pumpSheet(
        tester,
        (
          striker,
          nonStriker,
          bowler, {
          strikerId,
          nonStrikerId,
          bowlerId,
        }) async {
          submittedStrikerId = strikerId;
          return true;
        },
        battingRoster: battingRoster,
        bowlingRoster: bowlingRoster,
      );

      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('opener-picker-striker')),
          matching: find.text('Rohit Sharma'),
        ),
      );
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(1), 'Non-Striker');
      await tester.enterText(find.byType(TextFormField).at(2), 'Bumrah');

      await tester.ensureVisible(find.byType(CricketButton));
      await tester.tap(find.byType(CricketButton));
      await tester.pumpAndSettle();

      expect(submittedStrikerId, 'p-rohit');
    },
  );

  testWidgets(
    'editing the striker name after picking a chip sends a bare name — '
    'a scorer correcting or replacing the picked name is naming someone else',
    (WidgetTester tester) async {
      String? submittedStrikerName;
      String? submittedStrikerId;

      await pumpSheet(
        tester,
        (
          striker,
          nonStriker,
          bowler, {
          strikerId,
          nonStrikerId,
          bowlerId,
        }) async {
          submittedStrikerName = striker;
          submittedStrikerId = strikerId;
          return true;
        },
        battingRoster: battingRoster,
        bowlingRoster: bowlingRoster,
      );

      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('opener-picker-striker')),
          matching: find.text('Rohit Sharma'),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Rohit G Sharma',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'Non-Striker');
      await tester.enterText(find.byType(TextFormField).at(2), 'Bumrah');

      await tester.ensureVisible(find.byType(CricketButton));
      await tester.tap(find.byType(CricketButton));
      await tester.pumpAndSettle();

      expect(submittedStrikerName, 'Rohit G Sharma');
      expect(submittedStrikerId, isNull);
    },
  );

  testWidgets(
    'a player already picked as striker is disabled in the non-striker chip '
    'list — the two openers must be different people',
    (WidgetTester tester) async {
      await pumpSheet(
        tester,
        (_, _, _, {strikerId, nonStrikerId, bowlerId}) async => true,
        battingRoster: battingRoster,
        bowlingRoster: bowlingRoster,
      );

      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('opener-picker-striker')),
          matching: find.text('Rohit Sharma'),
        ),
      );
      await tester.pump();

      final nonStrikerChip = tester.widget<ChoiceChip>(
        find.descendant(
          of: find.byKey(const ValueKey('opener-picker-non-striker')),
          matching: find.widgetWithText(ChoiceChip, 'Rohit Sharma'),
        ),
      );

      expect(
        nonStrikerChip.onSelected,
        isNull,
        reason: 'Rohit Sharma is already picked as striker',
      );
    },
  );

  testWidgets(
    'the opening bowler picker draws from the bowling side, not the batting '
    'side, and has no must-differ exclusion against the openers',
    (WidgetTester tester) async {
      String? submittedBowlerId;

      await pumpSheet(
        tester,
        (
          striker,
          nonStriker,
          bowler, {
          strikerId,
          nonStrikerId,
          bowlerId,
        }) async {
          submittedBowlerId = bowlerId;
          return true;
        },
        battingRoster: battingRoster,
        bowlingRoster: bowlingRoster,
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'Striker');
      await tester.enterText(find.byType(TextFormField).at(1), 'Non-Striker');
      await tester.ensureVisible(find.text('Jasprit Bumrah'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jasprit Bumrah'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(CricketButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CricketButton));
      await tester.pumpAndSettle();

      expect(submittedBowlerId, 'p-bumrah');
    },
  );

  testWidgets(
    'closes once onSubmit succeeds even while a snackbar is showing — '
    'Get.back() would close the snackbar instead and leave this sheet stuck',
    (WidgetTester tester) async {
      await pumpSheet(
        tester,
        (_, _, _, {strikerId, nonStrikerId, bowlerId}) async => true,
      );

      expect(
        find.byType(OpenersBottomSheet),
        findsOneWidget,
        reason: 'the sheet should be open before the repro even starts',
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'Striker');
      await tester.enterText(find.byType(TextFormField).at(1), 'Non-Striker');
      await tester.enterText(find.byType(TextFormField).at(2), 'Bumrah');

      // The exact condition the bug depends on: a snackbar showing at the
      // instant onSubmit succeeds — this is what "Live connection lost"
      // does on every failed reconnect attempt while offline, which is
      // routinely happening right as an offline innings transition submits.
      CricketSnackbar.showErrorMessage('Live connection lost, reconnecting...');
      await tester.pump();
      expect(
        find.text('Live connection lost, reconnecting...'),
        findsOneWidget,
        reason:
            'the snackbar needs to actually be showing for this to prove anything',
      );

      // No translations are loaded in this bare test, so `.tr` falls back
      // to the raw key rather than "Start Innings".
      await tester.tap(find.text('start_innings'));
      await tester.pumpAndSettle();

      expect(
        find.byType(OpenersBottomSheet),
        findsNothing,
        reason:
            'onSubmit returned true, so this sheet must close regardless of '
            'the snackbar still being on screen — Get.back() would close '
            'only the snackbar here and leave the sheet stuck open',
      );
    },
  );

  testWidgets(
    'shows the previous innings\' final score when supplied — the '
    'innings-1-to-2 transition, where a mis-tapped last ball should be '
    'visible before the scorer commits to opening innings 2',
    (WidgetTester tester) async {
      final canUndo = false.obs;
      await pumpSheet(
        tester,
        (_, _, _, {strikerId, nonStrikerId, bowlerId}) async => true,
        previousInningsRuns: 118,
        previousInningsWickets: 6,
        previousInningsOvers: '19.4',
        canUndo: () => canUndo.value,
        onUndo: () async => false,
      );

      // No translations loaded in this bare test, so `.tr` falls back to the
      // raw keys rather than "Innings 1 complete" / "overs".
      expect(
        find.text('innings_one_complete: 118/6 (19.4 overs)'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'shows no summary at all for the very first innings, where there is '
    'nothing to report yet',
    (WidgetTester tester) async {
      final canUndo = false.obs;
      await pumpSheet(
        tester,
        (_, _, _, {strikerId, nonStrikerId, bowlerId}) async => true,
        canUndo: () => canUndo.value,
        onUndo: () async => false,
      );

      expect(find.textContaining('innings_one_complete'), findsNothing);
    },
  );

  testWidgets(
    'the undo link is hidden when canUndo is false and shown when it is true',
    (WidgetTester tester) async {
      final canUndo = false.obs;
      await pumpSheet(
        tester,
        (_, _, _, {strikerId, nonStrikerId, bowlerId}) async => true,
        previousInningsRuns: 118,
        previousInningsWickets: 6,
        previousInningsOvers: '19.4',
        canUndo: () => canUndo.value,
        onUndo: () async => false,
      );

      // Raw key fallback, same as every other button label in this file.
      expect(find.text('undo_last_ball'), findsNothing);

      canUndo.value = true;
      await tester.pump();

      expect(find.text('undo_last_ball'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping the undo link calls onUndo and closes the sheet once it '
    'succeeds — the only way out of a mis-tapped final ball of innings 1, '
    'since this sheet is undismissable',
    (WidgetTester tester) async {
      final canUndo = true.obs;
      var undoCalled = false;

      await pumpSheet(
        tester,
        (_, _, _, {strikerId, nonStrikerId, bowlerId}) async => true,
        previousInningsRuns: 118,
        previousInningsWickets: 6,
        previousInningsOvers: '19.4',
        canUndo: () => canUndo.value,
        onUndo: () async {
          undoCalled = true;
          return true;
        },
      );

      // The summary banner pushes the link below the test surface's fixed
      // viewport; scroll it into view first, same as any content the sheet's
      // own SingleChildScrollView would otherwise need a real scroll for.
      await tester.ensureVisible(find.text('undo_last_ball'));
      await tester.tap(find.text('undo_last_ball'));
      await tester.pumpAndSettle();

      expect(undoCalled, isTrue);
      expect(
        find.byType(OpenersBottomSheet),
        findsNothing,
        reason: 'onUndo returned true, so this sheet has nothing left to ask',
      );
    },
  );
}

// A real reactive read, not a hardcoded `false` — the sheet's undo-link Obx
// wraps `canUndo()` and, when it short-circuits false with no Rx access at
// all, GetX flags the Obx as unused ("improper use of a GetX/Obx"). Shared
// across tests that don't care about undo behaviour is safe: nothing ever
// mutates it, and each test builds its own fresh widget tree regardless.
final _sharedFalseObs = false.obs;
bool _neverCanUndo() => _sharedFalseObs.value;
Future<bool> _neverUndo() async => false;
