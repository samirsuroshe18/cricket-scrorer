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
import 'package:cricket_scorer/core/global/widgets/images/cricket_image.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image_source.dart';
import 'package:cricket_scorer/core/services/language_service.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/current_user.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/assign_scorer_sheet.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/match_history_card.dart';
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
            icon: const Icon(Icons.search),
            onPressed: () => Get.toNamed<dynamic>(AppRoutes.search),
          ),
          IconButton(
            tooltip: TranslationKeys.organizations.tr,
            icon: const Icon(Icons.groups_outlined),
            onPressed: () => Get.toNamed<dynamic>(AppRoutes.organizations),
          ),
          IconButton(
            tooltip: TranslationKeys.myProfile.tr,
            icon: Obx(() {
              final photoUrl = controller.currentUserProfile.value?.photoUrl;
              if (photoUrl == null || photoUrl.isEmpty) {
                return const Icon(Icons.person_outline);
              }
              // A real photo earns a real avatar in the app bar — the whole
              // point of this being reachable from Home at all is to show
              // that saving a profile actually did something visible.
              return CricketImage(
                source: CricketImageSource.network(photoUrl),
                height: 28,
                width: 28,
                borderRadius: const BorderRadius.all(Radius.circular(28)),
              );
            }),
            onPressed: () => Get.toNamed<dynamic>(
              AppRoutes.updateProfile,
              arguments: {'isEditing': true},
            ),
          ),
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

          // Read once per rebuild of this list, not once per card — a plain
          // synchronous SharedPreferences read/decode, but no reason to
          // repeat it `matches.length` times over.
          final uid = currentUserId();

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
                  return MatchHistoryCard(
                    item: item,
                    currentUserId: uid,
                    onTap: () => controller.openMatch(item),
                    onDelete: () => unawaited(_confirmDelete(controller, item)),
                    onAssignScorer: () => unawaited(
                      showAssignScorerSheet(
                        item: item,
                        loadCandidates: controller.loadScorerCandidates,
                        onAssign: controller.assignScorer,
                      ),
                    ),
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
