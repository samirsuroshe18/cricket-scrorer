import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/features/scoring/domain/bowler_ref.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/next_bowler_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  Future<void> pumpSheet(
    WidgetTester tester,
    Future<bool> Function(String bowlerName, {String? bowlerId}) onSubmit,
  ) async {
    // A real reactive read, not a hardcoded `false` — the sheet's undo-link
    // Obx wraps `canUndo()` and, when it short-circuits false, never reaches
    // `isUndoing.value` either. With no Rx access at all, GetX flags the Obx
    // as unused. Production code always has a real subscription here; this
    // is purely to keep the bare test tree well-formed.
    final canUndo = false.obs;

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => NextBowlerBottomSheet.show(
                excludedBowlerName: null,
                knownBowlers: [
                  const BowlerRef(id: 'bowler-rahul', name: 'Rahul'),
                ],
                isSubmitting: false.obs,
                onSubmit: onSubmit,
                canUndo: () => canUndo.value,
                isUndoing: false.obs,
                onUndo: () async => true,
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
    'tapping a known bowler chip sends its id, not just the name',
    (WidgetTester tester) async {
      String? submittedName;
      String? submittedId;

      await pumpSheet(tester, (name, {bowlerId}) async {
        submittedName = name;
        submittedId = bowlerId;
        return true;
      });

      await tester.tap(find.text('Rahul'));
      await tester.pump();

      // Both the sheet's headline and the submit button render
      // "select_bowler" — no translations are loaded in this bare test, so
      // `.tr` falls back to the raw key for each — hence targeting the
      // button by type rather than by text.
      await tester.tap(find.byType(CricketButton));
      await tester.pumpAndSettle();

      expect(submittedName, 'Rahul');
      expect(submittedId, 'bowler-rahul');
    },
  );

  testWidgets(
    'editing the name after picking a chip sends a bare name — a scorer '
    'correcting or replacing the picked name is naming someone else',
    (WidgetTester tester) async {
      String? submittedName;
      String? submittedId;

      await pumpSheet(tester, (name, {bowlerId}) async {
        submittedName = name;
        submittedId = bowlerId;
        return true;
      });

      await tester.tap(find.text('Rahul'));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField), 'Rahul K');
      await tester.tap(find.byType(CricketButton));
      await tester.pumpAndSettle();

      expect(submittedName, 'Rahul K');
      expect(
        submittedId,
        isNull,
        reason:
            'the field no longer reads exactly as the chip left it, so this '
            'must reach the server as a new name, not the picked bowler\'s id',
      );
    },
  );
}
