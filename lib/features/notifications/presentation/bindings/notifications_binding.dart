import 'package:cricket_scorer/features/notifications/domain/usecases/get_notifications.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/get_unread_count.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/mark_all_notifications_read.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:cricket_scorer/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:get/get.dart';

/// Only used as a fallback if `NotificationsScreen` is ever reached without
/// the home shell already having registered `NotificationsController` (see
/// `HomeBinding`) — `Get.lazyPut` here is a no-op when one is already
/// registered, so this is safe either way, not a second instance.
class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsController>(
      () => NotificationsController(
        getNotificationsUseCase: Get.find<GetNotificationsUseCase>(),
        getUnreadCountUseCase: Get.find<GetUnreadCountUseCase>(),
        markNotificationReadUseCase: Get.find<MarkNotificationReadUseCase>(),
        markAllNotificationsReadUseCase:
            Get.find<MarkAllNotificationsReadUseCase>(),
      ),
    );
  }
}
