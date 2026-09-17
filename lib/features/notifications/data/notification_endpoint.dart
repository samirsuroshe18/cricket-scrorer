class NotificationEndpoint {
  const NotificationEndpoint();

  final String list = '/v1/notifications';

  final String unreadCount = '/v1/notifications/unread-count';

  final String readAll = '/v1/notifications/read-all';

  String markRead(String notificationId) =>
      '/v1/notifications/$notificationId/read';
}
