import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/notifications/data/models/response/notification_res.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/get_notifications.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/get_unread_count.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/mark_all_notifications_read.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:cricket_scorer/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:cricket_scorer/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeGetNotifications implements GetNotificationsUseCase {
  Either<CricketResponse<NotificationsRes>, CricketFailure>? response;
  final calls = <GetNotificationsParams>[];

  @override
  Future<Either<CricketResponse<NotificationsRes>, CricketFailure>> call({
    GetNotificationsParams? params,
  }) async {
    calls.add(params!);
    return response!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeUnreadCount implements GetUnreadCountUseCase {
  @override
  Future<Either<CricketResponse<int>, CricketFailure>> call({
    void params,
  }) async => Either.result(const CricketResponse(message: 'ok', data: 1));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedMarkRead implements MarkNotificationReadUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedMarkAll implements MarkAllNotificationsReadUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

NotificationItem _invite() => NotificationItem(
  notificationId: 'n1',
  type: 'player_invite',
  title: 'Sam invited you to join Riverside U19',
  body: 'Accept to link your account to your player profile.',
  data: const {'type': 'player_invite', 'inviteId': 'i1', 'teamId': 't1'},
  read: false,
  createdAt: '2026-09-27T10:00:00.000Z',
);

void main() {
  late _FakeGetNotifications getNotifications;

  setUp(() {
    Get.testMode = true;
    getNotifications = _FakeGetNotifications();
    Get.put(
      NotificationsController(
        getNotificationsUseCase: getNotifications,
        getUnreadCountUseCase: _FakeUnreadCount(),
        markNotificationReadUseCase: _UnusedMarkRead(),
        markAllNotificationsReadUseCase: _UnusedMarkAll(),
      ),
    );
  });
  tearDown(Get.reset);

  Future<void> openScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: const NotificationsScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('opening the inbox fetches the first page and lists the rows', (
    tester,
  ) async {
    getNotifications.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: NotificationsRes(
          notifications: [_invite()],
          page: 1,
          limit: 20,
          total: 1,
        ),
      ),
    );

    await openScreen(tester);

    expect(getNotifications.calls, hasLength(1));
    expect(getNotifications.calls.single.page, 1);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Sam invited you to join Riverside U19'), findsOneWidget);
  });

  testWidgets(
    'a failed fetch shows the error and Retry instead of spinning forever',
    (
      tester,
    ) async {
      getNotifications.response = Either.fallback(
        CricketServerErrorFailure(statusCode: 500, message: 'Server exploded'),
      );

      await openScreen(tester);

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Server exploded'), findsOneWidget);
      expect(find.text(TranslationKeys.retry), findsOneWidget);
    },
  );

  testWidgets('an empty inbox shows the empty state, not a spinner', (
    tester,
  ) async {
    getNotifications.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: NotificationsRes(
          notifications: const [],
          page: 1,
          limit: 20,
          total: 0,
        ),
      ),
    );

    await openScreen(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(TranslationKeys.noNotificationsYet), findsOneWidget);
  });
}
