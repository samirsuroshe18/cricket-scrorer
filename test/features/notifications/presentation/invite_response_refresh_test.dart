import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/get_notifications.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/get_unread_count.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/mark_all_notifications_read.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:cricket_scorer/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:cricket_scorer/features/notifications/presentation/utils/notification_navigation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _Unread implements GetUnreadCountUseCase {
  @override
  Future<Either<CricketResponse<int>, CricketFailure>> call({
    void params,
  }) async => Either.result(const CricketResponse(message: 'ok', data: 0));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _Unused implements GetNotificationsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedRead implements MarkNotificationReadUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedReadAll implements MarkAllNotificationsReadUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  NotificationsController register() => Get.put(
    NotificationsController(
      getNotificationsUseCase: _Unused(),
      getUnreadCountUseCase: _Unread(),
      markNotificationReadUseCase: _UnusedRead(),
      markAllNotificationsReadUseCase: _UnusedReadAll(),
    ),
  );

  test('notifyInviteResponse bumps the tick', () {
    final controller = register();
    final before = controller.inviteResponseTick.value;

    controller.notifyInviteResponse();

    expect(controller.inviteResponseTick.value, before + 1);
  });

  test('an accepted or declined push bumps the tick once each', () {
    final controller = register();

    refreshOnInviteResponse({'type': 'player_invite_accepted', 'teamId': 't1'});
    refreshOnInviteResponse({'type': 'player_invite_declined', 'teamId': 't1'});

    expect(controller.inviteResponseTick.value, 2);
  });

  test('any other push, or a malformed payload, leaves the tick alone', () {
    final controller = register();

    refreshOnInviteResponse({'type': 'player_invite', 'inviteId': 'i1'});
    refreshOnInviteResponse({'type': 'your_turn_to_bat'});
    refreshOnInviteResponse({'matchId': 'm1'});
    refreshOnInviteResponse({'type': 7});
    refreshOnInviteResponse(<String, dynamic>{});

    expect(controller.inviteResponseTick.value, 0);
  });

  test('with no notifications controller registered it does nothing', () {
    expect(
      () => refreshOnInviteResponse({
        'type': 'player_invite_accepted',
        'teamId': 't1',
      }),
      returnsNormally,
    );
  });
}
