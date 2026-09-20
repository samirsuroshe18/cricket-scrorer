import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/config/theme/palettes/custom_color_scheme.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  tearDown(Get.reset);

  bool? closedWith;

  Future<void> openWarning(
    WidgetTester tester,
    ThemeData theme, {
    bool withX = false,
  }) async {
    closedWith = null;
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      GetMaterialApp(
        theme: theme,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              closedWith = await CustomBottomSheet.warningBottomSheet<bool>(
                title: 'Delete this match?',
                message: 'This removes it from your history.',
                confirmButtonName: 'Delete match',
                isXButtonRequired: withX,
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  TextStyle styleOf(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style!;

  // The title and message used the theme's unset displayMedium/headlineSmall
  // slots, which fall back to Material's near-black 45px/24px — unreadable on
  // the dark sheet. They must now carry the theme's own readable colours.
  testWidgets('dark theme: title and message are readable, not near-black', (
    tester,
  ) async {
    await openWarning(tester, AppTheme.darkTheme);

    const dark = CustomColorScheme.darkColorScheme;
    expect(styleOf(tester, 'Delete this match?').color, dark.onSurface);
    expect(
      styleOf(tester, 'This removes it from your history.').color,
      dark.onSurfaceVariant,
    );
  });

  testWidgets('light theme: same slots, light colours', (tester) async {
    await openWarning(tester, AppTheme.lightTheme);

    const light = CustomColorScheme.lightColorScheme;
    expect(styleOf(tester, 'Delete this match?').color, light.onSurface);
    expect(
      styleOf(tester, 'This removes it from your history.').color,
      light.onSurfaceVariant,
    );
  });

  testWidgets('the title is no longer Material\'s 45px default', (
    tester,
  ) async {
    await openWarning(tester, AppTheme.darkTheme);

    expect(
      styleOf(tester, 'Delete this match?').fontSize,
      lessThanOrEqualTo(28),
    );
  });

  testWidgets('no X button unless asked for', (tester) async {
    await openWarning(tester, AppTheme.darkTheme);

    expect(find.byIcon(LucideIcons.circleX), findsNothing);
  });

  testWidgets('the X closes the sheet without confirming', (tester) async {
    await openWarning(tester, AppTheme.darkTheme, withX: true);

    expect(find.byIcon(LucideIcons.circleX), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.circleX));
    await tester.pumpAndSettle();

    expect(find.text('Delete this match?'), findsNothing);
    // Cancel-equivalent: the caller only deletes on `true`.
    expect(closedWith, isFalse);
  });

  // The theme's handle floated as an orphan dash above the sheet's X button.
  for (final isDark in [true, false]) {
    testWidgets(
      '${isDark ? 'dark' : 'light'} theme: no drag handle above the sheet',
      (
        tester,
      ) async {
        // Built inside the test: constructing the theme touches Google Fonts,
        // which must not run at collection time.
        final theme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
        await openWarning(tester, theme, withX: true);

        expect(theme.bottomSheetTheme.showDragHandle, isFalse);
        expect(
          find.byWidgetPredicate(
            (w) => w.runtimeType.toString().contains('DragHandle'),
          ),
          findsNothing,
        );
      },
    );
  }
}
