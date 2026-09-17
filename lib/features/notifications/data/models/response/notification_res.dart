import 'package:json_annotation/json_annotation.dart';

part 'notification_res.g.dart';

/// `match_started` / `scorer_assigned` / `your_turn_to_bat` /
/// `your_turn_to_bowl` / `auction_started` / `lot_sold` — see docs/api.md's
/// `## Notifications` section for what triggers each and who receives it.
/// Kept as a bare String, not an enum: a server-added type this client
/// doesn't recognise yet should still render (title/body are always
/// present, human-readable, pre-localized) rather than crash a `fromJson`.
@JsonSerializable(explicitToJson: true)
class NotificationItem {
  final String notificationId;
  final String type;
  final String title;
  final String body;

  /// The same deep-link payload the push itself carried (e.g. `{"matchId":
  /// "..."}") — lets a tap on this inbox row navigate identically to a tap
  /// on the original push. Untyped `Map` on purpose: the shape varies by
  /// [type], and there is no shared base to parse against.
  final Map<String, dynamic> data;
  final bool read;
  final String createdAt;

  NotificationItem({
    required this.notificationId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.read,
    required this.createdAt,
  });

  NotificationItem copyWith({bool? read}) => NotificationItem(
    notificationId: notificationId,
    type: type,
    title: title,
    body: body,
    data: data,
    read: read ?? this.read,
    createdAt: createdAt,
  );

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationItemToJson(this);
}

/// `GET /v1/notifications`.
@JsonSerializable(explicitToJson: true)
class NotificationsRes {
  final List<NotificationItem> notifications;
  final int page;
  final int limit;
  final int total;

  NotificationsRes({
    required this.notifications,
    required this.page,
    required this.limit,
    required this.total,
  });

  /// Same "compare against total, not list length" reasoning as
  /// `MatchHistoryRes.hasMore`.
  bool get hasMore => page * limit < total;

  factory NotificationsRes.fromJson(Map<String, dynamic> json) =>
      _$NotificationsResFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationsResToJson(this);
}
