import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/notifications/data/models/response/notification_res.dart';

abstract class NotificationRepository {
  Future<Either<CricketResponse<NotificationsRes>, CricketFailure>>
  getNotifications({required int page, required int limit});

  Future<Either<CricketResponse<int>, CricketFailure>> getUnreadCount();

  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  markRead({required String notificationId});

  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  markAllRead();
}
