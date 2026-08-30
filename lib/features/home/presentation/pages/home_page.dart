import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_language.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_version.dart';
import 'package:cricket_scorer/core/global/domain/usecases/update_language.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/services/language_service.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The confirmation for [HomeController.deleteMatch] — permanent and
/// unresumable, so it goes through the same warning-sheet pattern as
/// [ScoreBallScreen]'s abandon confirmation rather than firing straight off
/// an icon tap.
Future<void> _confirmDelete(
  HomeController controller,
  MatchHistoryItem item,
) async {
  final confirmed = await CustomBottomSheet.warningBottomSheet<bool>(
    title: TranslationKeys.deleteMatchConfirmTitle.tr,
    message: TranslationKeys.deleteMatchConfirmMessage.tr,
    confirmButtonName: TranslationKeys.deleteMatch.tr,
  );
  if (confirmed == true) {
    await controller.deleteMatch(item);
  }
}

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: TranslationKeys.matchHistory.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: controller.logout,
          ),
          IconButton(
            onPressed: () => Get.find<LanguageService>().selectLanguage(
              getVersionUseCase: Get.find<GetVersionUseCase>(),
              getLanguageUseCase: Get.find<GetLanguageUseCase>(),
              updateLanguageUseCase: Get.find<UpdateLanguageUseCase>(),
            ),
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed<dynamic>(AppRoutes.createMatch),
        icon: const Icon(Icons.add),
        label: CricketText(text: TranslationKeys.startMatch.tr),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.matches.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final error = controller.loadError.value;
          if (error != null && controller.matches.isEmpty) {
            return _ErrorState(message: error, onRetry: controller.loadHistory);
          }

          if (controller.matches.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: controller.loadHistory,
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
                itemCount: controller.matches.length + 1,
                separatorBuilder: (_, _) => 12.h,
                itemBuilder: (context, index) {
                  if (index == controller.matches.length) {
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
                  final item = controller.matches[index];
                  return _MatchHistoryCard(
                    item: item,
                    onTap: () => controller.openMatch(item),
                    onDelete: () =>
                        unawaited(_confirmDelete(controller, item)),
                    isDeleting: () =>
                        controller.deletingMatchIds.contains(item.matchId),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: 24.p,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_cricket_outlined,
              size: 56,
              color: context.colorScheme.onSurfaceVariant,
            ),
            16.h,
            CricketText(
              text: TranslationKeys.noMatchesYet.tr,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            8.h,
            CricketText(
              text: TranslationKeys.noMatchesYetHint.tr,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
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
            CricketText(
              text: message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            24.h,
            CricketButton(
              buttonText: TranslationKeys.retry.tr,
              onPressed: () => onRetry(),
              width: 160,
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchHistoryCard extends StatelessWidget {
  const _MatchHistoryCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.isDeleting,
  });

  final MatchHistoryItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  /// A callback rather than a plain `bool`: [deletingMatchIds] is reactive,
  /// and this card needs to read it live, but the card list itself is
  /// rebuilt from a plain (non-`Obx`) `ListView.separated` — wrapping just
  /// the icon in its own `Obx` below is what makes only this one card's
  /// icon react, not the whole list re-diffing on every delete.
  final bool Function() isDeleting;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CricketText(
                      text: '${item.teamA.name} vs ${item.teamB.name}',
                      style: context.textTheme.titleSmall,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  ),
                  8.w,
                  _StatusBadge(status: item.status),
                  Obx(
                    () => isDeleting()
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : IconButton(
                            tooltip: TranslationKeys.deleteMatch.tr,
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                            onPressed: onDelete,
                          ),
                  ),
                ],
              ),
              6.h,
              CricketText(
                text:
                    '${item.totalOvers} ${TranslationKeys.overs.tr} · '
                    '${_formatDate(item.createdAt)}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// No `intl` dependency in this project (see pubspec.yaml) — a plain
  /// "20 Aug 2026" built from the ISO string's own fields, deliberately not
  /// locale-aware, matches every other date shown in this codebase today.
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return iso;
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'live' => (TranslationKeys.statusLive.tr, context.colors.statusInfo),
      'innings_break' => (
        TranslationKeys.statusInningsBreak.tr,
        context.colors.statusInfo,
      ),
      'completed' => (
        TranslationKeys.statusCompleted.tr,
        context.colors.statusSuccess,
      ),
      'abandoned' => (
        TranslationKeys.statusAbandoned.tr,
        context.colors.statusDanger,
      ),
      _ => (TranslationKeys.statusUpcoming.tr, context.colors.statusWarning),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: 8.radius,
      ),
      child: CricketText(
        text: label,
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
