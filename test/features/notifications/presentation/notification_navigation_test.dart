import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/main_shell_controller.dart';
import 'package:cricket_scorer/features/notifications/presentation/utils/notification_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  Future<MainShellController> pumpApp(WidgetTester tester) async {
    final shell = Get.put(MainShellController());
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/start',
        getPages: [
          GetPage<dynamic>(name: '/start', page: () => const SizedBox()),
          GetPage<dynamic>(
            name: AppRoutes.home,
            page: () => const Text('home'),
          ),
        ],
      ),
    );
    return shell;
  }

  testWidgets(
    'a payload with inviteId opens the invite sheet, not the Matches tab',
    (
      tester,
    ) async {
      final shell = await pumpApp(tester);
      final opened = <String>[];

      navigateForNotificationData(
        {'type': 'player_invite', 'inviteId': 'i1', 'teamId': 't1'},
        showInvite: (id) async => opened.add(id),
      );
      await tester.pumpAndSettle();

      expect(opened, ['i1']);
      expect(shell.tabIndex.value, 0);
      expect(find.text('home'), findsNothing);
    },
  );

  testWidgets('an empty inviteId is ignored and falls through', (tester) async {
    await pumpApp(tester);
    final opened = <String>[];

    navigateForNotificationData(
      {'inviteId': ''},
      showInvite: (id) async => opened.add(id),
    );
    await tester.pumpAndSettle();

    expect(opened, isEmpty);
  });

  testWidgets('a matchId-only payload still routes to the Matches tab', (
    tester,
  ) async {
    final shell = await pumpApp(tester);
    final opened = <String>[];

    navigateForNotificationData(
      {'matchId': 'm1'},
      showInvite: (id) async => opened.add(id),
    );
    await tester.pumpAndSettle();

    expect(opened, isEmpty);
    expect(shell.tabIndex.value, 1);
    expect(find.text('home'), findsOneWidget);
  });
}
