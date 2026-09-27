import 'dart:async';

import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/looked_up_user_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_players_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invite_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/add_player_picker.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/add_player_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

import '../helpers/picker_fakes.dart';

Either<CricketResponse<MyPlayersRes>, CricketFailure> _players(
  List<MyPlayerRow> rows, {
  int page = 1,
  int total = -1,
}) => Either.result(
  CricketResponse(
    message: 'ok',
    data: MyPlayersRes(
      players: rows,
      page: page,
      limit: 20,
      total: total < 0 ? rows.length : total,
    ),
  ),
);

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  late FakeGetMyPlayersUseCase myPlayers;
  late FakeLookupUserByEmailUseCase lookup;
  late FakeInviteTeamPlayerUseCase invite;
  late FakeAddTeamPlayerUseCase add;

  Future<void> pumpPicker(WidgetTester tester) async {
    myPlayers = FakeGetMyPlayersUseCase()
      ..response = _players([
        MyPlayerRow(playerId: 'p1', playerName: 'Rohit', role: 'batsman'),
        MyPlayerRow(
          playerId: 'p2',
          playerName: 'Amit',
          role: 'bowler',
          onTeam: true,
        ),
      ]);
    lookup = FakeLookupUserByEmailUseCase();
    invite = FakeInviteTeamPlayerUseCase();
    add = FakeAddTeamPlayerUseCase();
    final controller = buildPickerTestController(
      myPlayers: myPlayers,
      lookup: lookup,
      invite: invite,
      add: add,
    );

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showAddPlayerSheet(controller: controller),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> openAppUsers(WidgetTester tester) async {
    await tester.tap(find.text(TranslationKeys.appUsers));
    await tester.pumpAndSettle();
  }

  Future<void> findByEmail(WidgetTester tester, String email) async {
    await tester.enterText(find.byType(TextField).last, email);
    await tester.pump();
    await tester.tap(find.text(TranslationKeys.findUser));
    await tester.pumpAndSettle();
  }

  group('My players', () {
    testWidgets('lists the scorer\'s players and requests them for this team', (
      tester,
    ) async {
      await pumpPicker(tester);

      expect(find.text('Rohit'), findsOneWidget);
      expect(find.text('Amit'), findsOneWidget);
      expect(myPlayers.calls.first.teamId, 'team-1');
      expect(myPlayers.calls.first.page, 1);
    });

    testWidgets('Add sends the playerId, then closes the sheet', (
      tester,
    ) async {
      await pumpPicker(tester);

      await tester.tap(find.byKey(const ValueKey('add-player-p1')));
      await tester.pumpAndSettle();

      expect(add.calls.single.req.playerId, 'p1');
      expect(add.calls.single.req.name, isNull);
      expect(find.byType(AddPlayerPicker), findsNothing);
    });

    testWidgets(
      'a player already on the roster is labelled and cannot be added',
      (
        tester,
      ) async {
        await pumpPicker(tester);

        expect(find.text(TranslationKeys.onRoster), findsOneWidget);
        expect(find.byKey(const ValueKey('add-player-p2')), findsNothing);
      },
    );

    testWidgets('typing in the search field re-queries after a pause', (
      tester,
    ) async {
      await pumpPicker(tester);
      myPlayers.response = _players([
        MyPlayerRow(playerId: 'p3', playerName: 'Rohan'),
      ]);

      await tester.enterText(find.byType(TextField).first, 'roh');
      await tester.pump(const Duration(milliseconds: 100));
      expect(myPlayers.calls.length, 1); // still debouncing
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(myPlayers.calls.last.q, 'roh');
      expect(find.text('Rohan'), findsOneWidget);
      expect(find.text('Rohit'), findsNothing);
    });

    testWidgets('Load more appends the next page', (tester) async {
      await pumpPicker(tester);
      myPlayers.response = _players([
        MyPlayerRow(playerId: 'p1', playerName: 'Rohit'),
      ], total: 25);
      await tester.tap(find.byType(TextField).first);
      await tester.enterText(find.byType(TextField).first, 'r');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      myPlayers.response = _players(
        [
          MyPlayerRow(playerId: 'p9', playerName: 'Zed'),
        ],
        page: 2,
        total: 25,
      );

      await tester.tap(find.text(TranslationKeys.loadMorePlayers));
      await tester.pumpAndSettle();

      expect(myPlayers.calls.last.page, 2);
      expect(find.text('Rohit'), findsOneWidget);
      expect(find.text('Zed'), findsOneWidget);
    });

    testWidgets('shows an empty message when the scorer has no players', (
      tester,
    ) async {
      await pumpPicker(tester);
      myPlayers.response = _players(const []);
      await tester.enterText(find.byType(TextField).first, 'zzz');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text(TranslationKeys.noPlayersYet), findsOneWidget);
    });

    testWidgets('a server error on add shows inline and the sheet stays open', (
      tester,
    ) async {
      await pumpPicker(tester);
      add.response = Either.fallback(
        CricketNotFoundErrorFailure(statusCode: 404, message: 'Player gone'),
      );

      await tester.tap(find.byKey(const ValueKey('add-player-p1')));
      await tester.pumpAndSettle();

      expect(find.text('Player gone'), findsOneWidget);
      expect(find.byType(AddPlayerPicker), findsOneWidget);
    });
  });

  group('App users', () {
    testWidgets('Find is disabled until the field looks like an email', (
      tester,
    ) async {
      await pumpPicker(tester);
      await openAppUsers(tester);

      Finder findButton() => find.ancestor(
        of: find.text(TranslationKeys.findUser),
        matching: find.byType(ElevatedButton),
      );
      Future<bool> enabled() async =>
          tester.widget<ElevatedButton>(findButton()).onPressed != null;

      expect(await enabled(), isFalse);
      await tester.enterText(find.byType(TextField).last, 'rahul@');
      await tester.pump();
      expect(await enabled(), isFalse);
      await tester.enterText(find.byType(TextField).last, 'rahul@example.com');
      await tester.pump();
      expect(await enabled(), isTrue);
    });

    testWidgets('a found user shows name and username, and Invite sends once', (
      tester,
    ) async {
      await pumpPicker(tester);
      await openAppUsers(tester);
      lookup.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: LookedUpUserRes(
            userId: 'u1',
            fullName: 'Rahul Sharma',
            userName: 'rahul_s',
          ),
        ),
      );
      invite.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: TeamInviteRes(
            inviteId: 'i1',
            status: 'pending',
            player: TeamRosterPlayer(
              playerId: 'p1',
              playerName: 'Rahul Sharma',
              role: 'unknown',
            ),
          ),
        ),
      );

      await findByEmail(tester, '  rahul@example.com ');

      expect(lookup.calls.single.email, 'rahul@example.com');
      expect(find.text('Rahul Sharma'), findsOneWidget);
      expect(find.text('@rahul_s'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('invite-user')));
      await tester.tap(find.byKey(const ValueKey('invite-user')));
      await tester.pumpAndSettle();

      expect(invite.calls, hasLength(1));
      expect(invite.calls.single.userId, 'u1');
      expect(find.byType(AddPlayerPicker), findsNothing);
    });

    testWidgets('a lookup failure shows the server message inline', (
      tester,
    ) async {
      await pumpPicker(tester);
      await openAppUsers(tester);
      lookup.response = Either.fallback(
        CricketNotFoundErrorFailure(statusCode: 404, message: 'User not found'),
      );

      await findByEmail(tester, 'nobody@example.com');

      expect(find.text('User not found'), findsOneWidget);
      expect(find.byKey(const ValueKey('invite-user')), findsNothing);
    });

    testWidgets('an invite failure shows inline and the sheet stays open', (
      tester,
    ) async {
      await pumpPicker(tester);
      await openAppUsers(tester);
      lookup.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: LookedUpUserRes(userId: 'u1', fullName: 'Rahul Sharma'),
        ),
      );
      invite.response = Either.fallback(
        CricketBadRequestFailure(statusCode: 409, message: 'Already claimed'),
      );
      await findByEmail(tester, 'rahul@example.com');

      await tester.tap(find.byKey(const ValueKey('invite-user')));
      await tester.pumpAndSettle();

      expect(find.text('Already claimed'), findsOneWidget);
      expect(find.byType(AddPlayerPicker), findsOneWidget);
    });

    testWidgets('a lookup answered after the email was edited is discarded', (
      tester,
    ) async {
      await pumpPicker(tester);
      await openAppUsers(tester);
      lookup.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: LookedUpUserRes(userId: 'u1', fullName: 'Rahul Sharma'),
        ),
      );
      lookup.gate = Completer<void>();

      await tester.enterText(find.byType(TextField).last, 'rahul@example.com');
      await tester.pump();
      await tester.tap(find.text(TranslationKeys.findUser));
      await tester.pump(); // the lookup is now in flight
      await tester.enterText(find.byType(TextField).last, 'other@example.com');
      await tester.pump();
      lookup.gate!.complete();
      await tester.pumpAndSettle();

      // The card for the old address must not appear under the new one, or
      // tapping Invite would invite someone the scorer never asked for.
      expect(find.text('Rahul Sharma'), findsNothing);
      expect(find.byKey(const ValueKey('invite-user')), findsNothing);

      // ...and Find is usable again for the address now in the field.
      lookup.gate = null;
      await tester.tap(find.text(TranslationKeys.findUser));
      await tester.pumpAndSettle();
      expect(lookup.calls.last.email, 'other@example.com');
    });

    testWidgets('editing the email clears a previous result', (tester) async {
      await pumpPicker(tester);
      await openAppUsers(tester);
      lookup.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: LookedUpUserRes(userId: 'u1', fullName: 'Rahul Sharma'),
        ),
      );
      await findByEmail(tester, 'rahul@example.com');
      expect(find.text('Rahul Sharma'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'other@example.com');
      await tester.pump();

      expect(find.text('Rahul Sharma'), findsNothing);
    });
  });

  group('Create new player', () {
    testWidgets('opens the existing form; a successful add closes the sheet', (
      tester,
    ) async {
      await pumpPicker(tester);

      await tester.tap(find.text(TranslationKeys.createNewPlayer));
      await tester.pumpAndSettle();

      expect(find.byType(AddPlayerForm), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Brand New');
      await tester.tap(find.text(TranslationKeys.addPlayer).last);
      await tester.pumpAndSettle();

      expect(add.calls.single.req.name, 'Brand New');
      expect(find.byType(AddPlayerPicker), findsNothing);
    });

    testWidgets('Back to players returns to the picker', (tester) async {
      await pumpPicker(tester);
      await tester.tap(find.text(TranslationKeys.createNewPlayer));
      await tester.pumpAndSettle();

      await tester.tap(find.text(TranslationKeys.backToPlayers));
      await tester.pumpAndSettle();

      expect(find.byType(AddPlayerForm), findsNothing);
      expect(find.text('Rohit'), findsOneWidget);
    });
  });
}
