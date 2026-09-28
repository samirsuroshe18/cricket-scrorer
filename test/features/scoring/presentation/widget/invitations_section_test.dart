import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invites_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/invitations_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

TeamInviteItemRes _item(String id, String status, {String name = 'Rahul'}) =>
    TeamInviteItemRes(
      inviteId: id,
      status: status,
      respondedAt: status == 'pending' ? null : '2026-09-28T10:00:00.000Z',
      player: InvitedPlayerRes(playerId: 'p-$id', playerName: name),
      invitee: InviteeUserRes(userId: 'u-$id', fullName: name),
    );

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  Future<void> pumpSection(
    WidgetTester tester,
    List<TeamInviteItemRes> invites, {
    ValueChanged<TeamInviteItemRes>? onCancel,
    ValueChanged<TeamInviteItemRes>? onInviteAgain,
  }) => tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: InvitationsSection(
            invites: invites,
            onCancel: onCancel ?? (_) {},
            onInviteAgain: onInviteAgain ?? (_) {},
          ),
        ),
      ),
    ),
  );

  testWidgets('renders nothing when there are no invites', (tester) async {
    await pumpSection(tester, const []);

    expect(find.text(TranslationKeys.squadInvitations), findsNothing);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('each status shows its chip and only the matching action', (
    tester,
  ) async {
    await pumpSection(tester, [
      _item('i1', 'pending', name: 'Pia'),
      _item('i2', 'accepted', name: 'Amit'),
      _item('i3', 'declined', name: 'Dev'),
    ]);

    expect(find.text(TranslationKeys.squadInvitations), findsOneWidget);
    expect(find.text(TranslationKeys.inviteStatusWaiting), findsOneWidget);
    expect(find.text(TranslationKeys.inviteStatusAccepted), findsOneWidget);
    expect(find.text(TranslationKeys.inviteStatusDeclined), findsOneWidget);
    expect(find.text('Pia'), findsOneWidget);

    expect(find.byKey(const Key('invite_cancel_i1')), findsOneWidget);
    expect(find.byKey(const Key('invite_again_i1')), findsNothing);
    expect(find.byKey(const Key('invite_cancel_i2')), findsNothing);
    expect(find.byKey(const Key('invite_again_i2')), findsNothing);
    expect(find.byKey(const Key('invite_again_i3')), findsOneWidget);
    expect(find.byKey(const Key('invite_cancel_i3')), findsNothing);
    expect(find.byKey(const Key('invite_row_i2')), findsOneWidget);
  });

  testWidgets('the actions hand back that row\'s own invite', (tester) async {
    final pending = _item('i1', 'pending');
    final declined = _item('i3', 'declined');
    TeamInviteItemRes? cancelled;
    TeamInviteItemRes? again;
    await pumpSection(
      tester,
      [pending, declined],
      onCancel: (item) => cancelled = item,
      onInviteAgain: (item) => again = item,
    );

    await tester.tap(find.byKey(const Key('invite_cancel_i1')));
    await tester.tap(find.byKey(const Key('invite_again_i3')));

    expect(cancelled, same(pending));
    expect(again, same(declined));
  });
}
