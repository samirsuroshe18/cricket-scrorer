import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/notifications/data/data_sources/remote/notification_api_service.dart';
import 'package:cricket_scorer/features/notifications/data/models/response/notification_res.dart';
import 'package:cricket_scorer/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl extends NotificationRepository {
  final NotificationApiService notificationApiService;

  NotificationRepositoryImpl({required this.notificationApiService});

  @override
  Future<Either<CricketResponse<NotificationsRes>, CricketFailure>>
  getNotifications({required int page, required int limit}) async {
    Either<ApiResponseModel, CricketFailure> response =
        await notificationApiService.getNotifications(
          page: page,
          limit: limit,
        );
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: NotificationsRes.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<int>, CricketFailure>> getUnreadCount() async {
    Either<ApiResponseModel, CricketFailure> response =
        await notificationApiService.getUnreadCount();
    if (response.isResult) {
      final data = response.result.data as Map<String, dynamic>;
      return Either.result(
        CricketResponse(
          data: (data['count'] as num).toInt(),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  markRead({required String notificationId}) async {
    Either<ApiResponseModel, CricketFailure> response =
        await notificationApiService.markRead(notificationId: notificationId);
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: {}, message: response.result.message),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  markAllRead() async {
    Either<ApiResponseModel, CricketFailure> response =
        await notificationApiService.markAllRead();
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: {}, message: response.result.message),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }
}
