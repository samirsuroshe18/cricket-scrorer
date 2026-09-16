import 'dart:async';

import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_language.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_version.dart';
import 'package:cricket_scorer/core/global/domain/usecases/update_language.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/services/language_service.dart';
import 'package:cricket_scorer/core/services/theme_service.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Consolidates what used to be scattered across Home's app bar: the
/// language picker, the theme picker, and — most importantly — logout,
/// which used to be a `Icons.settings` icon that actually called
/// `HomeController.logout` directly with no settings screen behind it at
/// all. One accidental tap logged a scorer out mid-match; that's why this
/// screen exists now instead of just adding a real settings icon next to
/// the fake one.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();

    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.settings.tr),
      body: SafeArea(
        child: ListView(
          padding: 16.p,
          children: [
            _SectionLabel(text: TranslationKeys.appearance.tr),
            8.h,
            Obx(() {
              final icon = switch (themeService.themeMode) {
                ThemeMode.light => Icons.light_mode_outlined,
                ThemeMode.dark => Icons.dark_mode_outlined,
                ThemeMode.system => Icons.settings_suggest_outlined,
              };
              final label = switch (themeService.themeMode) {
                ThemeMode.light => TranslationKeys.light.tr,
                ThemeMode.dark => TranslationKeys.dark.tr,
                ThemeMode.system => TranslationKeys.system.tr,
              };
              return _SettingsTile(
                icon: icon,
                title: TranslationKeys.theme.tr,
                value: label,
                onTap: () => unawaited(themeService.selectTheme()),
              );
            }),
            8.h,
            Obx(
              () => _SettingsTile(
                icon: Icons.language,
                title: TranslationKeys.language.tr,
                value: Get.find<LanguageService>().currentLanguage
                    .toUpperCase(),
                onTap: () => unawaited(
                  Get.find<LanguageService>().selectLanguage(
                    getVersionUseCase: Get.find<GetVersionUseCase>(),
                    getLanguageUseCase: Get.find<GetLanguageUseCase>(),
                    updateLanguageUseCase: Get.find<UpdateLanguageUseCase>(),
                  ),
                ),
              ),
            ),

            28.h,

            _SectionLabel(text: TranslationKeys.account.tr),
            8.h,
            _SettingsTile(
              icon: Icons.logout,
              title: TranslationKeys.logout.tr,
              isDestructive: true,
              onTap: Get.find<HomeController>().logout,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return CricketText(
      text: text,
      style: context.textTheme.labelLarge?.copyWith(
        color: context.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? context.colors.statusDanger
        : context.colorScheme.onSurfaceVariant;

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
              Icon(icon, color: color),
              12.w,
              Expanded(
                child: CricketText(
                  text: title,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: isDestructive ? color : null,
                  ),
                ),
              ),
              if (value != null) ...[
                CricketText(
                  text: value!,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                8.w,
              ],
              if (!isDestructive)
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
