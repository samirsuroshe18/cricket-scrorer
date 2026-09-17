import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/notifications/data/notification_endpoint.dart';

class NotificationApiService {
  final ApiClient apiClient;
  final NotificationEndpoint notificationEndpoint;

  NotificationApiService({
    required this.apiClient,
    required this.notificationEndpoint,
  });

  Future<Either<ApiResponseModel, CricketFailure>> getNotifications({
    required int page,
    required int limit,
  }) async {
    return await apiClient.get(
      endpoint: notificationEndpoint.list,
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> getUnreadCount() async {
    return await apiClient.get(endpoint: notificationEndpoint.unreadCount);
  }

  Future<Either<ApiResponseModel, CricketFailure>> markRead({
    required String notificationId,
  }) async {
    return await apiClient.patch(
      endpoint: notificationEndpoint.markRead(notificationId),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> markAllRead() async {
    return await apiClient.post(endpoint: notificationEndpoint.readAll);
  }
}
