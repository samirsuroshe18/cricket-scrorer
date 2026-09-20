import 'package:cached_network_image/cached_network_image.dart';
import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/auth/data/models/user.dart';
import 'package:cricket_scorer/features/home/presentation/utils/home_match_view.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:cricket_scorer/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Avatar, time-of-day greeting, the signed-in user's handle and the bell.
/// Replaces the old brand strip + "Hi, name" pair: the wordmark said nothing
/// the app icon doesn't, and the header is the first thing seen on every open.
class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.user, this.now, super.key});

  final User? user;

  /// Overridable so the greeting is testable without depending on the clock.
  final DateTime? now;

  String _greeting() {
    final hour = (now ?? DateTime.now()).hour;
    if (hour < 12) return TranslationKeys.greetingMorning.tr;
    if (hour < 17) return TranslationKeys.greetingAfternoon.tr;
    return TranslationKeys.greetingEvening.tr;
  }

  String _displayName() {
    final userName = user?.userName;
    if (userName != null && userName.isNotEmpty) return userName;
    final fullName = user?.fullName;
    if (fullName != null && fullName.isNotEmpty) return fullName;
    return TranslationKeys.homeGreetingNoName.tr;
  }

  @override
  Widget build(BuildContext context) {
    final name = _displayName();

    return Row(
      children: [
        _Avatar(
          initials: initialsFor(user?.userName ?? user?.fullName),
          photoUrl: user?.photoUrl,
        ),
        10.w,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CricketText(
                text: _greeting(),
                maxLines: 1,
                textOverflow: TextOverflow.ellipsis,
                style: context.homeText(12, color: context.homeMuted),
              ),
              CricketText(
                text: name,
                maxLines: 1,
                textOverflow: TextOverflow.ellipsis,
                style: context.homeText(16, weight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const _Bell(),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, required this.photoUrl});

  final String initials;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final url = photoUrl;
    final fallback = CricketText(
      text: initials,
      style: context.homeText(
        14,
        weight: FontWeight.w600,
        color: context.isDark ? Colors.white : scheme.primary,
      ),
    );

    return ExcludeSemantics(
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.primary.withValues(alpha: context.isDark ? 0.35 : 0.12),
        ),
        child: (url == null || url.isEmpty)
            ? fallback
            : ClipOval(
                child: CachedNetworkImage(
                  imageUrl: url,
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => fallback,
                  errorWidget: (_, _, _) => fallback,
                ),
              ),
      ),
    );
  }
}

/// The 38px bell sits in a 44px hit area — the visual size the design asks
/// for, without shrinking the target below what a thumb needs.
class _Bell extends StatelessWidget {
  const _Bell();

  @override
  Widget build(BuildContext context) {
    final notifications = Get.find<NotificationsController>();

    return Obx(() {
      final count = notifications.unreadCount.value;
      return Semantics(
        button: true,
        label: TranslationKeys.notifications.tr,
        value: count > 0 ? '$count' : null,
        child: InkResponse(
          onTap: () => Get.toNamed<dynamic>(AppRoutes.notifications),
          radius: 24,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.homeCard,
                  border: context.isDark
                      ? null
                      : Border.all(color: context.homeLine),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 19,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    if (count > 0)
                      Positioned(
                        top: 8,
                        right: 9,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
