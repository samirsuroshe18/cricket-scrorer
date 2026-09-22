import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/wigets/choose_photo_option.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/global/widgets/dialogue/custom_dialog.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image_source.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/services/compression_service.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/current_user.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_profile_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/assign_scorer_sheet.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/edit_team_sheet.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/match_history_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// A team's roster plus its past results — reached by tapping a team's name
/// on a `MatchHistoryCard` (home's match history, or another team's own
/// past-results list). Not a stats page: v1 is deliberately roster + past
/// results only, no aggregate wins/losses/win% — see docs/api.md.
class TeamProfileScreen extends StatefulWidget {
  const TeamProfileScreen({super.key});

  @override
  State<TeamProfileScreen> createState() => _TeamProfileScreenState();
}

class _TeamProfileScreenState extends State<TeamProfileScreen> {
  // Captured once, in State construction — not read from `Get.parameters`
  // inside build(). Get.parameters is one global, mutated by whichever
  // route is current, and this widget can rebuild for reasons unrelated to
  // navigation (a language or theme change force-rebuilds the whole tree —
  // see LanguageService.changeLanguage/ThemeService.changeThemeMode). A
  // build()-time read would resolve against whatever route happened to be
  // current at that rebuild, not the route this screen actually belongs
  // to — reintroducing the same wrong-team failure the tagged lazyPut here
  // was added to fix.
  late final String _teamId = Get.parameters['teamId']?.trim() ?? '';
  late final TeamProfileController controller = Get.find<TeamProfileController>(
    tag: _teamId,
  );
  late final String _currentUserId = currentUserId();

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadLogo() async {
    await CustomBottomSheet.wrapBottomSheet<dynamic>(
      headlineText: TranslationKeys.updateTeamLogo.tr,
      child: ChoosePhotoOption(
        onCameraCallback: () async {
          Get.back<dynamic>();
          await _pickCompressAndUploadLogo(ImageSource.camera);
        },
        onGalleryCallback: () async {
          Get.back<dynamic>();
          await _pickCompressAndUploadLogo(ImageSource.gallery);
        },
      ),
    );
  }

  Future<void> _pickCompressAndUploadLogo(ImageSource source) async {
    XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: source,
        requestFullMetadata: true,
        imageQuality: 100,
      );
    } catch (_) {
      CricketSnackbar.showErrorMessage(TranslationKeys.somethingWentWrong.tr);
      return;
    }
    if (picked == null) return;

    CricketLoaderDialog.show();
    final compressed = await Get.find<CompressionService>().imageCompression(
      inputPath: picked.path,
    );
    if (!compressed.isResult) {
      CricketLoaderDialog.hide();
      CricketSnackbar.showErrorMessage(compressed.fallback.message);
      return;
    }

    final success = await controller.updateLogo(compressed.result);
    CricketLoaderDialog.hide();
    if (success) {
      CricketSnackbar.showSuccessMessage(TranslationKeys.teamLogoUpdated.tr);
    }
  }

  Future<void> _editTeam(TeamProfileRes data) async {
    await showEditTeamSheet(
      controller: controller,
      currentName: data.name,
      currentShortName: data.shortName,
    );
  }

  Future<void> _confirmDeleteTeam() async {
    final confirmed = await CustomBottomSheet.warningBottomSheet<bool>(
      title: TranslationKeys.deleteTeamConfirmTitle.tr,
      message: TranslationKeys.deleteTeamConfirmMessage.tr,
      confirmButtonName: TranslationKeys.deleteTeam.tr,
    );
    if (confirmed != true) return;

    final error = await controller.deleteTeam();
    if (error == null) {
      // Pop before showing the snackbar, not after: a GetX snackbar is
      // itself a route, so `Get.back()` called while one is still open
      // closes the snackbar instead of this screen (see the sibling
      // `showEditTeamSheet`, which pops via `onUpdated` before its caller
      // shows `teamUpdated`, for the same reason).
      Get.back<dynamic>();
      CricketSnackbar.showSuccessMessage(TranslationKeys.teamDeleted.tr);
    } else {
      CricketSnackbar.showErrorMessage(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: TranslationKeys.teamProfile.tr,
        actions: [
          Obx(() {
            final data = controller.profile.value;
            if (data == null || !data.canManage) {
              return const SizedBox.shrink();
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => unawaited(_editTeam(data)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => unawaited(_confirmDeleteTeam()),
                ),
              ],
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final loading = controller.isLoadingProfile.value;
          final error = controller.profileError.value;
          final data = controller.profile.value;

          if (loading && data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null && data == null) {
            return _ErrorState(message: error, onRetry: controller.loadProfile);
          }
          if (data == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: () => Future.wait([
              controller.loadProfile(),
              controller.loadMatches(),
            ]),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200) {
                  controller.loadMoreMatches();
                }
                return false;
              },
              child: ListView(
                padding: 16.p,
                children: [
                  _TeamHeader(profile: data, onUpdateLogo: _pickAndUploadLogo),
                  24.h,
                  CricketText(
                    text: TranslationKeys.pastResults.tr,
                    style: context.textTheme.titleSmall,
                  ),
                  12.h,
                  Obx(() {
                    if (controller.isLoadingMatches.value &&
                        controller.matches.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final matchesError = controller.matchesError.value;
                    if (matchesError != null && controller.matches.isEmpty) {
                      return _ErrorState(
                        message: matchesError,
                        onRetry: controller.loadMatches,
                      );
                    }

                    if (controller.matches.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: CricketText(
                          text: TranslationKeys.noMatchesYet.tr,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return Column(
                      children: [
                        for (final item in controller.matches) ...[
                          MatchHistoryCard(
                            item: item,
                            currentUserId: _currentUserId,
                            onTap: () => controller.openMatch(item),
                            onAssignScorer: () => unawaited(
                              showAssignScorerSheet(
                                item: item,
                                loadCandidates: controller.loadScorerCandidates,
                                onAssign: controller.assignScorer,
                              ),
                            ),
                            highlightTeamId: controller.teamId,
                          ),
                          12.h,
                        ],
                        if (controller.isLoadingMore.value)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        }),
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

class _TeamHeader extends StatelessWidget {
  const _TeamHeader({required this.profile, required this.onUpdateLogo});

  final TeamProfileRes profile;
  final VoidCallback onUpdateLogo;

  /// `shortName` if the team has one (a club almost always names one for
  /// exactly this purpose — think "MI", "CSK"), otherwise the initials of
  /// the first two words of `name`. Purely derived from the team's own
  /// data, not a decorative flourish.
  String _monogram() {
    final short = profile.shortName?.trim();
    if (short != null && short.isNotEmpty) {
      return short.substring(0, short.length.clamp(0, 3)).toUpperCase();
    }
    final words = profile.name.trim().split(RegExp(r'\s+'));
    final letters = words.take(2).map((w) => w.isEmpty ? '' : w[0]).join();
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: context.colors.chipBackground,
              child: (profile.logoUrl == null || profile.logoUrl!.isEmpty)
                  ? CricketText(
                      text: _monogram(),
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : ClipOval(
                      child: CricketImage(
                        source: CricketImageSource.network(profile.logoUrl!),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            16.w,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CricketText(
                    text: profile.name,
                    // headlineSmall carries no explicit color override in
                    // this app's theme (unlike every other TextTheme member
                    // it defines) — it falls back to Google Fonts' default,
                    // which is unreadable on the dark theme's navy surface.
                    // Pinning it to onSurface here rather than relying on
                    // the fallback.
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  if (profile.shortName != null) ...[
                    4.h,
                    CricketText(
                      text: profile.shortName!,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: onUpdateLogo,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
          ),
          child: CricketText(text: TranslationKeys.updateTeamLogo.tr),
        ),
        16.h,
        CricketText(
          text: TranslationKeys.roster.tr,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        8.h,
        // Full width, a sibling of the header row rather than nested inside
        // it — a roster row previously sat under the avatar+gap indent and
        // rendered narrower than the past-results cards directly below it.
        if (profile.roster.isEmpty)
          CricketText(text: TranslationKeys.noRosterYet.tr)
        else
          for (final player in profile.roster) ...[
            _RosterRow(player: player),
            4.h,
          ],
      ],
    );
  }
}

class _RosterRow extends StatelessWidget {
  const _RosterRow({required this.player});

  final TeamRosterPlayer player;

  // batsman/bowler/allrounder reuse the app's status-color family — plenty
  // distinct from each other, and none of the three read as an alarm.
  // Wicketkeeper deliberately does NOT reuse statusDanger: that's the same
  // red `_StatusBadge` uses for "abandoned" two inches away on the results
  // list below, and a red pill next to a player's own name reads as a
  // problem indicator rather than a fielding position. `onSurface` (used
  // here as both the pill's tint source and its text color, same as the
  // other three roles) gives a neutral, still-legible pill in both themes
  // without borrowing a semantic status color.
  (String, Color) _role(BuildContext context) => switch (player.role) {
    'batsman' => (TranslationKeys.roleBatsman.tr, context.colors.statusInfo),
    'bowler' => (TranslationKeys.roleBowler.tr, context.colors.statusWarning),
    'allrounder' => (
      TranslationKeys.roleAllrounder.tr,
      context.colors.statusSuccess,
    ),
    'wicketkeeper' => (
      TranslationKeys.roleWicketkeeper.tr,
      context.colorScheme.onSurface,
    ),
    _ => (TranslationKeys.roleUnknown.tr, context.colorScheme.onSurfaceVariant),
  };

  @override
  Widget build(BuildContext context) {
    final (roleLabel, roleColor) = _role(context);
    final isUnknownRole =
        player.role != 'batsman' &&
        player.role != 'bowler' &&
        player.role != 'allrounder' &&
        player.role != 'wicketkeeper';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: 8.radius,
        onTap: () =>
            Get.toNamed<dynamic>(AppRoutes.playerStatsPath(player.playerId)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: CricketText(
                  text: player.playerName,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.secondary,
                  ),
                ),
              ),
              if (player.jerseyNumber != null) ...[
                CricketText(
                  text: '#${player.jerseyNumber}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                8.w,
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isUnknownRole
                      ? null
                      : roleColor.withValues(alpha: 0.12),
                  borderRadius: 8.radius,
                ),
                child: CricketText(
                  text: roleLabel,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: roleColor,
                    fontWeight: isUnknownRole ? null : FontWeight.w600,
                  ),
                ),
              ),
              4.w,
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
