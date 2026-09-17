import 'dart:async';

import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/features/notifications/data/models/response/notification_res.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/get_notifications.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/get_unread_count.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/mark_all_notifications_read.dart';
import 'package:cricket_scorer/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:get/get.dart';

/// Owns both the full inbox list (for the Notifications screen) and the
/// unread badge count (for the Home tab's bell icon) — registered once in
/// the home shell's binding, alongside `HomeController`, so the badge and
/// the list share one source of truth instead of drifting apart.
class NotificationsController extends GetxController {
  final GetNotificationsUseCase getNotificationsUseCase;
  final GetUnreadCountUseCase getUnreadCountUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase;

  NotificationsController({
    required this.getNotificationsUseCase,
    required this.getUnreadCountUseCase,
    required this.markNotificationReadUseCase,
    required this.markAllNotificationsReadUseCase,
  });

  static const int _pageSize = 20;

  final notifications = <NotificationItem>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final loadError = Rxn<String>();
  final unreadCount = 0.obs;
  int _page = 1;
  bool _isLoadingList = false;

  @override
  void onInit() {
    super.onInit();
    unawaited(refreshUnreadCount());
  }

  /// Cheap and independent of the full list — called from Home's `onInit`
  /// (for the badge, without paying for the full inbox fetch) and again
  /// whenever this controller's own list load might have changed it.
  Future<void> refreshUnreadCount() async {
    final response = await getUnreadCountUseCase();
    if (response.isResult) {
      unreadCount.value = response.result.data ?? 0;
    }
    // Best-effort — a failed badge refresh just leaves the last-known count
    // showing rather than surfacing an error for a non-critical number.
  }

  /// The Notifications screen's own `onInit`/pull-to-refresh entry point —
  /// not called from Home, which only ever needs [refreshUnreadCount].
  Future<void> loadNotifications() async {
    if (_isLoadingList) return;
    _isLoadingList = true;
    isLoading.value = true;
    loadError.value = null;
    _page = 1;

    final response = await getNotificationsUseCase(
      params: const GetNotificationsParams(page: 1, limit: _pageSize),
    );

    isLoading.value = false;
    _isLoadingList = false;

    if (response.isResult) {
      final data = response.result.data;
      notifications.assignAll(data?.notifications ?? []);
      hasMore.value = data?.hasMore ?? false;
    } else {
      loadError.value = response.fallback.message;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;

    final response = await getNotificationsUseCase(
      params: GetNotificationsParams(page: _page + 1, limit: _pageSize),
    );

    isLoadingMore.value = false;

    if (response.isResult) {
      final data = response.result.data;
      if (data != null) {
        notifications.addAll(data.notifications);
        hasMore.value = data.hasMore;
        _page += 1;
      }
    } else {
      CricketSnackbar.showErrorMessage(response.fallback.message);
    }
  }

  /// Marks one row read — patches it in place and decrements the badge
  /// locally rather than a full reload, same reasoning as
  /// `HomeController.assignScorer`'s in-place patch.
  Future<void> markRead(NotificationItem item) async {
    if (item.read) return;

    final response = await markNotificationReadUseCase(
      params: item.notificationId,
    );
    if (!response.isResult) return;

    final index = notifications.indexWhere(
      (n) => n.notificationId == item.notificationId,
    );
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(read: true);
    }
    if (unreadCount.value > 0) unreadCount.value -= 1;
  }

  Future<void> markAllRead() async {
    final response = await markAllNotificationsReadUseCase();
    if (!response.isResult) {
      CricketSnackbar.showErrorMessage(response.fallback.message);
      return;
    }
    notifications.assignAll(
      notifications.map((n) => n.copyWith(read: true)).toList(),
    );
    unreadCount.value = 0;
  }
}
