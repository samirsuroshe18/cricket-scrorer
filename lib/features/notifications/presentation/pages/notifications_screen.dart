import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/notifications/data/models/response/notification_res.dart';
import 'package:cricket_scorer/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:cricket_scorer/features/notifications/presentation/utils/notification_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Map<String, IconData> _typeIcons = <String, IconData>{
  'match_started': Icons.sports_cricket,
  'scorer_assigned': Icons.person_add_alt,
  'your_turn_to_bat': Icons.sports_cricket,
  'your_turn_to_bowl': Icons.sports_baseball_outlined,
  'auction_started': Icons.gavel_outlined,
  'lot_sold': Icons.emoji_events_outlined,
};

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: TranslationKeys.notifications.tr,
        actions: [
          Obx(
            () => controller.unreadCount.value > 0
                ? TextButton(
                    onPressed: controller.markAllRead,
                    child: CricketText(
                      text: TranslationKeys.markAllRead.tr,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: context.colorScheme.secondary,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final error = controller.loadError.value;
          if (error != null && controller.notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: 24.p,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 56,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    16.h,
                    CricketText(text: error, textAlign: TextAlign.center),
                    24.h,
                    CricketButton(
                      buttonText: TranslationKeys.retry.tr,
                      onPressed: controller.loadNotifications,
                      width: 160,
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: 24.p,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 56,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    16.h,
                    CricketText(
                      text: TranslationKeys.noNotificationsYet.tr,
                      style: context.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadNotifications,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200) {
                  controller.loadMore();
                }
                return false;
              },
              child: ListView.separated(
                padding: 16.p,
                itemCount: controller.notifications.length + 1,
                separatorBuilder: (_, _) => 8.h,
                itemBuilder: (context, index) {
                  if (index == controller.notifications.length) {
                    return Obx(
                      () => controller.isLoadingMore.value
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    );
                  }
                  return _NotificationTile(item: controller.notifications[index]);
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final NotificationItem item;

  void _onTap() {
    Get.find<NotificationsController>().markRead(item);
    navigateForNotificationData(item.data);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.read
          ? context.colorScheme.surfaceContainerHighest
          : context.colors.chipSelected,
      borderRadius: 12.radius,
      child: InkWell(
        borderRadius: 12.radius,
        onTap: _onTap,
        child: Padding(
          padding: 16.p,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _typeIcons[item.type] ?? Icons.notifications_none,
                color: context.colorScheme.primary,
              ),
              12.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CricketText(
                      text: item.title,
                      style: context.textTheme.titleSmall,
                    ),
                    4.h,
                    CricketText(
                      text: item.body,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!item.read) ...[
                8.w,
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
