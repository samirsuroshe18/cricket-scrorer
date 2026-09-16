import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image_source.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/current_user.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Profile tab: the avatar-tap-to-edit-form shortcut Home used to be is
/// replaced by an actual identity destination — a view first, with edit and
/// "my stats" as explicit actions off it, plus the entry point into the new
/// Settings screen (which is where logout now lives; see
/// `SettingsScreen`'s doc comment for why it moved off Home's app bar).
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.navProfile.tr),
      body: SafeArea(
        child: ListView(
          padding: 16.p,
          children: [
            Obx(() {
              final user = controller.currentUserProfile.value;
              final photoUrl = user?.photoUrl;
              return Row(
                children: [
                  (photoUrl == null || photoUrl.isEmpty)
                      ? CircleAvatar(
                          radius: 32,
                          backgroundColor: context.colors.chipBackground,
                          child: Icon(
                            Icons.person_outline,
                            size: 32,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : CricketImage(
                          source: CricketImageSource.network(photoUrl),
                          height: 64,
                          width: 64,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(64),
                          ),
                        ),
                  16.w,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CricketText(
                          text: (user?.userName?.isNotEmpty ?? false)
                              ? user!.userName!
                              : TranslationKeys.username.tr,
                          style: context.textTheme.titleLarge,
                        ),
                        if (user?.bio?.isNotEmpty ?? false) ...[
                          4.h,
                          CricketText(
                            text: user!.bio!,
                            maxLines: 2,
                            textOverflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: TranslationKeys.editProfile.tr,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => Get.toNamed<dynamic>(
                      AppRoutes.updateProfile,
                      arguments: {'isEditing': true},
                    ),
                  ),
                ],
              );
            }),

            28.h,

            _ProfileMenuTile(
              icon: Icons.bar_chart_outlined,
              label: TranslationKeys.viewMyStats.tr,
              onTap: () => Get.toNamed<dynamic>(
                AppRoutes.playerStatsPath(currentUserId()),
              ),
            ),
            12.h,
            _ProfileMenuTile(
              icon: Icons.settings_outlined,
              label: TranslationKeys.settings.tr,
              onTap: () => Get.toNamed<dynamic>(AppRoutes.settings),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surfaceContainerHighest,
      borderRadius: 12.radius,
      child: InkWell(
        borderRadius: 12.radius,
        onTap: onTap,
        child: Padding(
          padding: 16.p,
          child: Row(
            children: [
              Icon(icon, color: context.colorScheme.onSurfaceVariant),
              12.w,
              Expanded(
                child: CricketText(
                  text: label,
                  style: context.textTheme.bodyLarge,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
