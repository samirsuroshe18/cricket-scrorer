import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organization_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/format_status_chips.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// An organization's members and teams, and the owner-only actions to
/// manage both — reached by tapping a row on `OrganizationsListScreen`.
/// Shares `TeamProfileScreen`'s monogram-header and role-pill vocabulary so
/// the two feel like one continuous surface.
class OrganizationDetailScreen extends StatefulWidget {
  const OrganizationDetailScreen({super.key});

  @override
  State<OrganizationDetailScreen> createState() =>
      _OrganizationDetailScreenState();
}

class _OrganizationDetailScreenState extends State<OrganizationDetailScreen> {
  late final String _orgId = Get.parameters['orgId']?.trim() ?? '';
  late final OrganizationDetailController controller =
      Get.find<OrganizationDetailController>(tag: _orgId);

  Future<void> _showAddMemberSheet() async {
    final emailController = TextEditingController();
    final added = await CustomBottomSheet.wrapBottomSheet<bool>(
      headlineText: TranslationKeys.addMember.tr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CricketTextField(
            controller: emailController,
            hintText: TranslationKeys.memberEmail.tr,
            labelText: TranslationKeys.memberEmail.tr,
            prefixIcon: const Icon(Icons.alternate_email),
            keyboardType: TextInputType.emailAddress,
            isRequired: true,
          ),
          20.h,
          CricketButton(
            buttonText: TranslationKeys.add.tr,
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;
              final success = await controller.addMember(email);
              if (success) {
                Get.back<bool>(result: true);
              } else {
                CricketSnackbar.showErrorMessage(
                  TranslationKeys.somethingWentWrong.tr,
                );
              }
            },
          ),
        ],
      ),
    );
    if (added == true) {
      CricketSnackbar.showSuccessMessage(TranslationKeys.memberAdded.tr);
    }
  }

  Future<void> _showAddTeamSheet() async {
    final nameController = TextEditingController();
    final shortNameController = TextEditingController();
    final added = await CustomBottomSheet.wrapBottomSheet<bool>(
      headlineText: TranslationKeys.addTeam.tr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CricketTextField(
            controller: nameController,
            hintText: TranslationKeys.teamName.tr,
            labelText: TranslationKeys.teamName.tr,
            prefixIcon: const Icon(Icons.shield_outlined),
            isRequired: true,
          ),
          12.h,
          CricketTextField(
            controller: shortNameController,
            hintText: TranslationKeys.teamShortName.tr,
            labelText: TranslationKeys.teamShortName.tr,
            prefixIcon: const Icon(Icons.short_text),
          ),
          20.h,
          CricketButton(
            buttonText: TranslationKeys.add.tr,
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final shortName = shortNameController.text.trim();
              final success = await controller.createTeam(
                name,
                shortName.isEmpty ? null : shortName,
              );
              if (success) {
                Get.back<bool>(result: true);
              } else {
                CricketSnackbar.showErrorMessage(
                  TranslationKeys.somethingWentWrong.tr,
                );
              }
            },
          ),
        ],
      ),
    );
    if (added == true) {
      CricketSnackbar.showSuccessMessage(TranslationKeys.teamAdded.tr);
    }
  }

  Future<void> _showAddTournamentSheet() async {
    final nameController = TextEditingController();
    var selectedFormat = tournamentFormats.first;

    final created = await CustomBottomSheet.wrapBottomSheet<bool>(
      headlineText: TranslationKeys.addTournament.tr,
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CricketTextField(
              controller: nameController,
              hintText: TranslationKeys.tournamentName.tr,
              labelText: TranslationKeys.tournamentName.tr,
              prefixIcon: const Icon(Icons.emoji_events_outlined),
              isRequired: true,
            ),
            16.h,
            FormatChoiceChips(
              selected: selectedFormat,
              onSelected: (format) =>
                  setSheetState(() => selectedFormat = format),
            ),
            20.h,
            CricketButton(
              buttonText: TranslationKeys.create.tr,
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final success = await controller.createTournament(
                  name,
                  selectedFormat,
                );
                if (success) {
                  Get.back<bool>(result: true);
                } else {
                  CricketSnackbar.showErrorMessage(
                    TranslationKeys.somethingWentWrong.tr,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
    if (created == true) {
      CricketSnackbar.showSuccessMessage(TranslationKeys.tournamentCreated.tr);
    }
  }

  Future<void> _confirmRemoveMember(
    OrganizationMemberRes member,
    bool isSelf,
  ) async {
    final confirmed = await CustomBottomSheet.warningBottomSheet<bool>(
      title: isSelf
          ? TranslationKeys.leaveOrganizationConfirmTitle.tr
          : TranslationKeys.removeMemberConfirmTitle.tr,
      message: isSelf
          ? TranslationKeys.leaveOrganizationConfirmMessage.tr
          : TranslationKeys.removeMemberConfirmMessage.tr,
      confirmButtonName: isSelf
          ? TranslationKeys.leaveOrganization.tr
          : TranslationKeys.removeMember.tr,
    );
    if (confirmed != true) return;

    final success = await controller.removeMember(member.id);
    if (!success) {
      CricketSnackbar.showErrorMessage(TranslationKeys.somethingWentWrong.tr);
    }
  }

  Future<void> _confirmDeleteOrganization() async {
    final confirmed = await CustomBottomSheet.warningBottomSheet<bool>(
      title: TranslationKeys.deleteOrganizationConfirmTitle.tr,
      message: TranslationKeys.deleteOrganizationConfirmMessage.tr,
      confirmButtonName: TranslationKeys.deleteOrganization.tr,
    );
    if (confirmed != true) return;

    final success = await controller.deleteOrganization();
    if (success) {
      Get.back<dynamic>();
    } else {
      CricketSnackbar.showErrorMessage(TranslationKeys.somethingWentWrong.tr);
    }
  }

  String _monogram(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    final letters = words.take(2).map((w) => w.isEmpty ? '' : w[0]).join();
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: TranslationKeys.organizationDetail.tr,
        actions: [
          Obx(() {
            if (!controller.isOwner) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDeleteOrganization,
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final loading = controller.isLoading.value;
          final error = controller.loadError.value;
          final detail = controller.detail.value;

          if (loading && detail == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null && detail == null) {
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
          if (detail == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: controller.loadDetail,
            child: ListView(
              padding: 16.p,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: context.colors.chipBackground,
                      child: CricketText(
                        text: _monogram(detail.name),
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    16.w,
                    Expanded(
                      child: CricketText(
                        text: detail.name,
                        style: context.textTheme.headlineSmall?.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                24.h,
                _SectionHeader(
                  title: TranslationKeys.members.tr,
                  actionLabel: controller.isOwner
                      ? TranslationKeys.addMember.tr
                      : null,
                  onAction: _showAddMemberSheet,
                ),
                8.h,
                for (final member in detail.members) ...[
                  _MemberRow(
                    member: member,
                    canAct:
                        controller.isOwner ||
                        member.id == controller.currentUserId,
                    onRemove: member.role == 'owner'
                        ? null
                        : () => _confirmRemoveMember(
                            member,
                            member.id == controller.currentUserId,
                          ),
                  ),
                  4.h,
                ],
                24.h,
                _SectionHeader(
                  title: TranslationKeys.teams.tr,
                  actionLabel: controller.isOwner
                      ? TranslationKeys.addTeam.tr
                      : null,
                  onAction: _showAddTeamSheet,
                ),
                8.h,
                if (detail.teams.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CricketText(
                      text: TranslationKeys.noTeamsYet.tr,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (final team in detail.teams) ...[
                    _TeamRow(team: team),
                    4.h,
                  ],
                24.h,
                _SectionHeader(
                  title: TranslationKeys.tournaments.tr,
                  actionLabel: controller.isOwner
                      ? TranslationKeys.addTournament.tr
                      : null,
                  onAction: _showAddTournamentSheet,
                ),
                8.h,
                if (detail.tournaments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CricketText(
                      text: TranslationKeys.noTournamentsYet.tr,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (final tournament in detail.tournaments) ...[
                    _TournamentRow(tournament: tournament),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CricketText(text: title, style: context.textTheme.titleSmall),
        if (actionLabel != null)
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add, size: 18),
            label: CricketText(text: actionLabel!),
          ),
      ],
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.canAct,
    required this.onRemove,
  });

  final OrganizationMemberRes member;
  final bool canAct;

  /// Null when this row can't be acted on at all (viewer is neither the
  /// owner nor this row), or when this row is the owner (never removable
  /// through this action) — in the second case the close icon still shows,
  /// disabled, so the owner row visually matches its neighbours instead of
  /// looking like a rendering gap.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final isOwnerRow = member.role == 'owner';
    final (roleLabel, roleColor) = isOwnerRow
        ? ('owner', context.colors.statusInfo)
        : ('member', context.colorScheme.onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: CricketText(
              text: member.name,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.secondary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isOwnerRow
                  ? roleColor.withValues(alpha: 0.12)
                  : null,
              borderRadius: 8.radius,
            ),
            child: CricketText(
              text: roleLabel,
              style: context.textTheme.labelSmall?.copyWith(
                color: roleColor,
                fontWeight: isOwnerRow ? FontWeight.w600 : null,
              ),
            ),
          ),
          if (canAct) ...[
            4.w,
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.close,
                size: 18,
                color: context.colorScheme.onSurfaceVariant,
              ),
              onPressed: onRemove,
            ),
          ],
        ],
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.team});

  final OrganizationTeamRef team;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: 8.radius,
        onTap: () =>
            Get.toNamed<dynamic>(AppRoutes.teamProfilePath(team.id)),
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

class _TournamentRow extends StatelessWidget {
  const _TournamentRow({required this.tournament});

  final OrganizationTournamentRef tournament;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: 8.radius,
        onTap: () => Get.toNamed<dynamic>(
          AppRoutes.tournamentDetailPath(tournament.id),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: CricketText(
                  text: tournament.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.secondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: tournamentStatusColor(
                    context,
                    tournament.status,
                  ).withValues(alpha: 0.12),
                  borderRadius: 8.radius,
                ),
                child: CricketText(
                  text: tournamentStatusLabel(tournament.status),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: tournamentStatusColor(context, tournament.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              8.w,
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
