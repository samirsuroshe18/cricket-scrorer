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
}
