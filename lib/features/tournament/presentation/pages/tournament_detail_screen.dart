import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/enroll_team_sheet.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/edit_tournament_sheet.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/format_status_chips.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A tournament's detail plus its enrolled-team roster — reached by
/// tapping a tournament row on `OrganizationDetailScreen`. Shares that
/// screen's and `TeamProfileScreen`'s section/row vocabulary.
class TournamentDetailScreen extends StatefulWidget {
  const TournamentDetailScreen({super.key});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  late final String _tournamentId = Get.parameters['tournamentId']?.trim() ?? '';
  late final TournamentDetailController controller =
      Get.find<TournamentDetailController>(tag: _tournamentId);

  Future<void> _confirmRemoveTeam(TournamentTeamRef team) async {
    final confirmed = await CustomBottomSheet.warningBottomSheet<bool>(
      title: TranslationKeys.removeTeamConfirmTitle.tr,
      message: TranslationKeys.removeTeamConfirmMessage.tr,
      confirmButtonName: TranslationKeys.removeTeam.tr,
    );
    if (confirmed != true) return;

    final success = await controller.removeTeam(team.id);
    if (success) {
      CricketSnackbar.showSuccessMessage(
        TranslationKeys.teamRemovedFromTournament.tr,
      );
    } else {
      CricketSnackbar.showErrorMessage(TranslationKeys.somethingWentWrong.tr);
    }
  }

  Future<void> _confirmDeleteTournament() async {
    final confirmed = await CustomBottomSheet.warningBottomSheet<bool>(
      title: TranslationKeys.deleteTournamentConfirmTitle.tr,
      message: TranslationKeys.deleteTournamentConfirmMessage.tr,
      confirmButtonName: TranslationKeys.deleteTournament.tr,
    );
    if (confirmed != true) return;

    final success = await controller.deleteTournament();
    if (success) {
      Get.back<dynamic>();
    } else {
      CricketSnackbar.showErrorMessage(TranslationKeys.somethingWentWrong.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: TranslationKeys.tournamentDetail.tr,
        actions: [
          Obx(() {
            if (!controller.isOwner) return const SizedBox.shrink();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => showEditTournamentSheet(controller: controller),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _confirmDeleteTournament,
                ),
              ],
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final loading = controller.isLoading.value;
          final error = controller.loadError.value;
          final data = controller.detail.value;

          if (loading && data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null && data == null) {
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
                      onPressed: controller.loadDetail,
                      width: 160,
                    ),
                  ],
                ),
              ),
            );
          }
          if (data == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: controller.loadDetail,
            child: ListView(
              padding: 16.p,
              children: [
                CricketText(
                  text: data.name,
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                8.h,
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.chipBackground,
                        borderRadius: 8.radius,
                      ),
                      child: CricketText(
                        text: tournamentFormatLabel(data.format),
                        style: context.textTheme.labelSmall,
                      ),
                    ),
                    8.w,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tournamentStatusColor(
                          context,
                          data.status,
                        ).withValues(alpha: 0.12),
                        borderRadius: 8.radius,
                      ),
                      child: CricketText(
                        text: tournamentStatusLabel(data.status),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: tournamentStatusColor(context, data.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                4.h,
                CricketText(
                  text: data.organization.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                24.h,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CricketText(
                      text: TranslationKeys.teams.tr,
                      style: context.textTheme.titleSmall,
                    ),
                    if (controller.isOwner)
                      TextButton.icon(
                        onPressed: () =>
                            showEnrollTeamSheet(controller: controller),
                        icon: const Icon(Icons.add, size: 18),
                        label: CricketText(text: TranslationKeys.enrollTeam.tr),
                      ),
                  ],
                ),
                8.h,
                if (data.teams.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CricketText(
                      text: TranslationKeys.noTeamsInTournament.tr,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (final team in data.teams) ...[
                    _EnrolledTeamRow(
                      team: team,
                      canRemove: controller.isOwner,
                      onRemove: () => _confirmRemoveTeam(team),
                    ),
                    4.h,
                  ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _EnrolledTeamRow extends StatelessWidget {
  const _EnrolledTeamRow({
    required this.team,
    required this.canRemove,
    required this.onRemove,
  });

  final TournamentTeamRef team;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: 8.radius,
        onTap: () => Get.toNamed<dynamic>(AppRoutes.teamProfilePath(team.id)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: CricketText(
                  text: team.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.secondary,
                  ),
                ),
              ),
              if (team.shortName != null) ...[
                CricketText(
                  text: team.shortName!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                8.w,
              ],
              if (canRemove)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onRemove,
                )
              else
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
