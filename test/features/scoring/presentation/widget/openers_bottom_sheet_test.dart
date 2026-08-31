import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/openers_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets(
    'closes once onSubmit succeeds even while a snackbar is showing — '
    'Get.back() would close the snackbar instead and leave this sheet stuck',
    (WidgetTester tester) async {
      // A real reactive read, not a hardcoded `false` — the sheet's undo-link
      // Obx wraps `canUndo()` and, when it short-circuits false, never reaches
      // `isUndoing.value` either. With no Rx access at all, GetX flags the Obx
      // as unused. Production code always has a real subscription here; this
      // is purely to keep the bare test tree well-formed. See
      // next_bowler_bottom_sheet_test.dart's identical comment.
      final canUndo = false.obs;

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => OpenersBottomSheet.show(
                    onSubmit: (_, _, _) async => true,
                    isSubmitting: false.obs,
                    canUndo: () => canUndo.value,
                    isUndoing: false.obs,
                    onUndo: () async => false,
                  ),
                  child: const Text('open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

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

  Future<void> pumpSheet(
    WidgetTester tester, {
    int? previousInningsRuns,
    int? previousInningsWickets,
    String? previousInningsOvers,
    required bool Function() canUndo,
    required Future<bool> Function() onUndo,
  }) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => OpenersBottomSheet.show(
                onSubmit: (_, _, _) async => true,
                isSubmitting: false.obs,
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
    'shows the previous innings\' final score when supplied — the '
    'innings-1-to-2 transition, where a mis-tapped last ball should be '
    'visible before the scorer commits to opening innings 2',
    (WidgetTester tester) async {
      final canUndo = false.obs;
      await pumpSheet(
        tester,
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
