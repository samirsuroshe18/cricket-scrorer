import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/notifications/presentation/widget/player_invite_sheet.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/player_invite_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_player_invite.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/respond_to_player_invite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _FakeGetPlayerInvite implements GetPlayerInviteUseCase {
  Either<CricketResponse<PlayerInviteRes>, CricketFailure>? response;
  String? lastInviteId;

  @override
  Future<Either<CricketResponse<PlayerInviteRes>, CricketFailure>> call({
    GetPlayerInviteParams? params,
  }) async {
    lastInviteId = params!.inviteId;
    return response!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeRespond implements RespondToPlayerInviteUseCase {
  Either<CricketResponse<PlayerInviteAnswerRes>, CricketFailure>? response;
  final calls = <RespondToPlayerInviteParams>[];

  @override
  Future<Either<CricketResponse<PlayerInviteAnswerRes>, CricketFailure>> call({
    RespondToPlayerInviteParams? params,
  }) async {
    calls.add(params!);
    return response ??
        Either.result(
          CricketResponse(
            message: 'Server says done',
            data: PlayerInviteAnswerRes(
              inviteId: params.inviteId,
              status: params.accept ? 'accepted' : 'declined',
            ),
          ),
        );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

Either<CricketResponse<PlayerInviteRes>, CricketFailure> _invite(
  String status,
) => Either.result(
  CricketResponse(
    message: 'ok',
    data: PlayerInviteRes(
      inviteId: 'i1',
      status: status,
      teamId: 't1',
      teamName: 'Riverside U19',
      invitedByName: 'Scorer Sam',
      playerName: 'Rahul Sharma',
    ),
  ),
);

void main() {
  late _FakeGetPlayerInvite getInvite;
  late _FakeRespond respond;
  late List<(bool, String?)> reported;

  setUp(() {
    Get.testMode = true;
    getInvite = _FakeGetPlayerInvite();
    respond = _FakeRespond();
    reported = [];
    Get.put<GetPlayerInviteUseCase>(getInvite);
    Get.put<RespondToPlayerInviteUseCase>(respond);
  });
  tearDown(Get.reset);

  Future<void> pumpSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showPlayerInviteSheet(
                  'i1',
                  reportResult: (ok, message) => reported.add((ok, message)),
                ),
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

  testWidgets(
    'fetches the invite by id and shows Accept and Decline while pending',
    (
      tester,
    ) async {
      getInvite.response = _invite('pending');

      await pumpSheet(tester);

      expect(getInvite.lastInviteId, 'i1');
      expect(find.text(TranslationKeys.acceptInvite), findsOneWidget);
      expect(find.text(TranslationKeys.declineInvite), findsOneWidget);
    },
  );

  testWidgets(
    'Accept responds with accept: true, closes, and shows the server message',
    (
      tester,
    ) async {
      getInvite.response = _invite('pending');
      await pumpSheet(tester);

      await tester.tap(find.text(TranslationKeys.acceptInvite));
      await tester.pumpAndSettle();

      expect(respond.calls.single.inviteId, 'i1');
      expect(respond.calls.single.accept, isTrue);
      expect(find.byType(PlayerInviteSheetBody), findsNothing);
      expect(reported, [(true, 'Server says done')]);
    },
  );

  testWidgets('Decline responds with accept: false and closes', (tester) async {
    getInvite.response = _invite('pending');
    await pumpSheet(tester);

    await tester.tap(find.text(TranslationKeys.declineInvite));
    await tester.pumpAndSettle();

    expect(respond.calls.single.accept, isFalse);
    expect(find.byType(PlayerInviteSheetBody), findsNothing);
  });

  testWidgets('an accepted invite is read-only: message, no buttons', (
    tester,
  ) async {
    getInvite.response = _invite('accepted');

    await pumpSheet(tester);

    expect(find.text(TranslationKeys.inviteAlreadyAccepted), findsOneWidget);
    expect(find.text(TranslationKeys.acceptInvite), findsNothing);
    expect(find.text(TranslationKeys.declineInvite), findsNothing);
  });

  testWidgets('a declined invite is read-only: message, no buttons', (
    tester,
  ) async {
    getInvite.response = _invite('declined');

    await pumpSheet(tester);

    expect(find.text(TranslationKeys.inviteAlreadyDeclined), findsOneWidget);
    expect(find.text(TranslationKeys.acceptInvite), findsNothing);
  });

  testWidgets(
    'PLAYER_ALREADY_CLAIMED on accept closes the sheet and shows the server message',
    (
      tester,
    ) async {
      getInvite.response = _invite('pending');
      respond.response = Either.fallback(
        CricketBadRequestFailure(
          statusCode: 409,
          code: 'PLAYER_ALREADY_CLAIMED',
          message: 'This player has already been claimed',
        ),
      );
      await pumpSheet(tester);

      await tester.tap(find.text(TranslationKeys.acceptInvite));
      await tester.pumpAndSettle();

      expect(find.byType(PlayerInviteSheetBody), findsNothing);
      expect(reported, [(false, 'This player has already been claimed')]);
    },
  );

  testWidgets('a failed load shows the server message and no buttons', (
    tester,
  ) async {
    getInvite.response = Either.fallback(
      CricketNotFoundErrorFailure(statusCode: 404, message: 'Invite not found'),
    );

    await pumpSheet(tester);

    expect(find.text('Invite not found'), findsOneWidget);
    expect(find.text(TranslationKeys.acceptInvite), findsNothing);
  });

  testWidgets('double-tapping Accept sends one request', (tester) async {
    getInvite.response = _invite('pending');
    await pumpSheet(tester);

    await tester.tap(find.text(TranslationKeys.acceptInvite));
    await tester.tap(
      find.text(TranslationKeys.acceptInvite),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(respond.calls, hasLength(1));
  });
}
