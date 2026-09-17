import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/features/notifications/data/data_sources/remote/notification_api_service.dart';
import 'package:cricket_scorer/features/notifications/data/notification_endpoint.dart';
import 'package:cricket_scorer/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:cricket_scorer/features/notifications/domain/repositories/notification_repository.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/get_notifications.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/get_unread_count.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/mark_all_notifications_read.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:get/get.dart';

class NotificationInjection {
  NotificationInjection._();

  static void init() {
    const notificationEndpoint = NotificationEndpoint();

    Get.lazyPut<NotificationApiService>(
      () => NotificationApiService(
        apiClient: Get.find<ApiClient>(),
        notificationEndpoint: notificationEndpoint,
      ),
      fenix: true,
    );

    Get.lazyPut<NotificationRepository>(
      () => NotificationRepositoryImpl(
        notificationApiService: Get.find<NotificationApiService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetNotificationsUseCase>(
      () => GetNotificationsUseCase(
        notificationRepository: Get.find<NotificationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetUnreadCountUseCase>(
      () => GetUnreadCountUseCase(
        notificationRepository: Get.find<NotificationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<MarkNotificationReadUseCase>(
      () => MarkNotificationReadUseCase(
        notificationRepository: Get.find<NotificationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<MarkAllNotificationsReadUseCase>(
      () => MarkAllNotificationsReadUseCase(
        notificationRepository: Get.find<NotificationRepository>(),
      ),
      fenix: true,
    );
  }
}
