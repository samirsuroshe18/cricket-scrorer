import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_state_placeholders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets(
    'tapping the empty-state CTA navigates to the same create-match route '
    "the shell's FAB uses",
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          initialRoute: '/home',
          getPages: [
            GetPage(
              name: '/home',
              page: () => const Scaffold(body: EmptyMatchesState()),
            ),
            GetPage(
              name: AppRoutes.createMatch,
              page: () => const Scaffold(body: Text('create match')),
            ),
          ],
        ),
      );

      // Raw key — no translations loaded in this bare test.
      await tester.tap(find.textContaining('start_first_match'));
      await tester.pumpAndSettle();

      expect(find.text('create match'), findsOneWidget);
    },
  );
}
