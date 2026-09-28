import 'dart:async';

import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/looked_up_user_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/invite_by_email_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  final lookedUp = LookedUpUserRes(userId: 'u1', fullName: 'Rahul Sharma');

  Future<void> pumpPanel(
    WidgetTester tester, {
    required Future<(LookedUpUserRes?, String?)> Function(String email) lookup,
    required Future<String?> Function(String userId) invite,
    required VoidCallback onDone,
  }) => tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: InviteByEmailPanel(
            lookup: lookup,
            invite: invite,
            onDone: onDone,
          ),
        ),
      ),
    ),
  );

  Future<void> findByEmail(WidgetTester tester, String email) async {
    await tester.enterText(find.byType(TextField), email);
    await tester.pump();
    await tester.tap(find.text(TranslationKeys.findUser));
    await tester.pumpAndSettle();
  }

  testWidgets('Find is disabled until the address looks like an email', (
    tester,
  ) async {
    await pumpPanel(
      tester,
      lookup: (_) async => (lookedUp, null),
      invite: (_) async => null,
      onDone: () {},
    );
    bool enabled() =>
        tester
            .widget<ElevatedButton>(
              find.ancestor(
                of: find.text(TranslationKeys.findUser),
                matching: find.byType(ElevatedButton),
              ),
            )
            .onPressed !=
        null;

    expect(enabled(), isFalse);
    await tester.enterText(find.byType(TextField), 'rahul@');
    await tester.pump();
    expect(enabled(), isFalse);
    await tester.enterText(find.byType(TextField), 'rahul@example.com');
    await tester.pump();
    expect(enabled(), isTrue);
  });

  testWidgets('an unknown address shows the returned message inline', (
    tester,
  ) async {
    await pumpPanel(
      tester,
      lookup: (_) async => (null, 'User not found'),
      invite: (_) async => null,
      onDone: () {},
    );

    await findByEmail(tester, 'nobody@example.com');

    expect(find.text('User not found'), findsOneWidget);
    expect(find.byKey(const ValueKey('invite-user')), findsNothing);
  });

  testWidgets('a found user is shown; Invite sends once, then onDone fires', (
    tester,
  ) async {
    final sent = <String>[];
    var done = 0;
    String? searched;
    await pumpPanel(
      tester,
      lookup: (email) async {
        searched = email;
        return (lookedUp, null);
      },
      invite: (userId) async {
        sent.add(userId);
        return null;
      },
      onDone: () => done++,
    );

    await findByEmail(tester, 'rahul@example.com');
    expect(searched, 'rahul@example.com');
    expect(find.text('Rahul Sharma'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('invite-user')));
    await tester.tap(find.byKey(const ValueKey('invite-user')));
    // Not pumpAndSettle: the spinner keeps animating because, unlike the real
    // sheet, this harness never closes on onDone.
    await tester.pump();
    await tester.pump();

    expect(sent, ['u1']);
    expect(done, 1);
  });

  testWidgets('an invite failure shows inline and does not call onDone', (
    tester,
  ) async {
    var done = 0;
    await pumpPanel(
      tester,
      lookup: (_) async => (lookedUp, null),
      invite: (_) async => 'Already claimed',
      onDone: () => done++,
    );
    await findByEmail(tester, 'rahul@example.com');

    await tester.tap(find.byKey(const ValueKey('invite-user')));
    await tester.pumpAndSettle();

    expect(find.text('Already claimed'), findsOneWidget);
    expect(done, 0);
  });

  testWidgets('a lookup answered after the address was edited is discarded', (
    tester,
  ) async {
    final gate = Completer<void>();
    await pumpPanel(
      tester,
      lookup: (_) async {
        await gate.future;
        return (lookedUp, null);
      },
      invite: (_) async => null,
      onDone: () {},
    );

    await tester.enterText(find.byType(TextField), 'rahul@example.com');
    await tester.pump();
    await tester.tap(find.text(TranslationKeys.findUser));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'other@example.com');
    await tester.pump();
    gate.complete();
    await tester.pumpAndSettle();

    expect(find.text('Rahul Sharma'), findsNothing);
    expect(find.byKey(const ValueKey('invite-user')), findsNothing);
  });
}
