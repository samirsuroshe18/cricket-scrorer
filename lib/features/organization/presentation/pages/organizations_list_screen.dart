import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_entity_avatar.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_grouped_card.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organizations_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The create-organization sheet — top-level (not a method on
/// [OrganizationsListScreen]) so `TeamsTab`'s Organizations section can
/// trigger the exact same flow off its own FAB instead of duplicating it.
Future<void> showCreateOrganizationSheet(
  OrganizationsListController controller,
) async {
  final nameController = TextEditingController();
  final created = await CustomBottomSheet.wrapBottomSheet<bool>(
    headlineText: TranslationKeys.createOrganization.tr,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CricketTextField(
          controller: nameController,
          hintText: TranslationKeys.organizationName.tr,
          labelText: TranslationKeys.organizationName.tr,
          prefixIcon: const Icon(Icons.groups_outlined),
          isRequired: true,
        ),
        20.h,
        CricketButton(
          buttonText: TranslationKeys.create.tr,
          onPressed: () async {
            final name = nameController.text.trim();
            if (name.isEmpty) return;
            final success = await controller.createOrganization(name);
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
  if (created == true) {
    CricketSnackbar.showSuccessMessage(TranslationKeys.organizationCreated.tr);
  }
}

/// Every organization the caller owns or belongs to — reached from the
/// Teams tab's Organizations section "See all". Mirrors
/// `MatchHistoryCard`'s card treatment and `TeamProfileScreen`'s
/// monogram-avatar pattern so this reads as the same app, not a bolted-on
/// generic list.
class OrganizationsListScreen extends GetView<OrganizationsListController> {
  const OrganizationsListScreen({super.key});

  /// Same confirm copy `OrganizationDetailScreen._confirmRemoveMember` uses
  /// for `isSelf` — this is that same action, reachable without opening the
  /// org first. Never wired for a row the caller owns (see
  /// [OrganizationsListController.leaveOrganization]).
  Future<void> _confirmLeave(
    BuildContext context,
    OrganizationSummaryRes org,
  ) async {
    final confirmed = await CustomBottomSheet.warningBottomSheet<bool>(
      title: TranslationKeys.leaveOrganizationConfirmTitle.tr,
      message: TranslationKeys.leaveOrganizationConfirmMessage.tr,
      confirmButtonName: TranslationKeys.leaveOrganization.tr,
    );
    if (confirmed != true) return;

    final success = await controller.leaveOrganization(org.id);
    if (!success) {
      CricketSnackbar.showErrorMessage(TranslationKeys.somethingWentWrong.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.organizations.tr),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCreateOrganizationSheet(controller),
        icon: const Icon(Icons.add),
        label: CricketText(text: TranslationKeys.create.tr),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.organizations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final error = controller.loadError.value;
          if (error != null && controller.organizations.isEmpty) {
            return OrganizationMessageState(
              icon: Icons.error_outline,
              message: error,
              action: CricketButton(
                buttonText: TranslationKeys.retry.tr,
                onPressed: controller.loadOrganizations,
                width: 160,
              ),
            );
          }

          if (controller.organizations.isEmpty) {
            return OrganizationMessageState(
              icon: Icons.groups_outlined,
              message: TranslationKeys.noOrganizationsYet.tr,
              action: CricketButton(
                buttonText: TranslationKeys.createOrganization.tr,
                onPressed: () => showCreateOrganizationSheet(controller),
                width: 220,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadOrganizations,
            child: ListView.separated(
              padding: 16.p,
              itemCount: controller.organizations.length,
              separatorBuilder: (_, _) => 12.h,
              itemBuilder: (context, index) {
                final org = controller.organizations[index];
                return OrganizationCard(
                  org: org,
                  onLeave: org.myRole == 'owner'
                      ? null
                      : () => _confirmLeave(context, org),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

/// Public so the Teams tab's Organizations section (`TeamsTab`) can render
/// the same empty/error message treatment as this standalone screen without
/// a second copy of it.
class OrganizationMessageState extends StatelessWidget {
  const OrganizationMessageState({
    required this.icon,
    required this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: 24.p,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: context.colorScheme.onSurfaceVariant),
            16.h,
            CricketText(
              text: message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            if (action != null) ...[24.h, action!],
          ],
        ),
      ),
    );
  }
}

/// One organization as a tappable row: logo or monogram, name, how big it is,
/// and the caller's role. Public so `TeamsTab` can stack several inside one
/// `CricketGroupedCard`; [OrganizationCard] wraps a single one for this
/// screen. Needs a Material ancestor for its ripple, which the card provides.
class OrganizationRow extends StatelessWidget {
  const OrganizationRow({required this.org, this.onLeave, super.key});

  final OrganizationSummaryRes org;

  /// Null for a row the caller owns — an owner leaves by deleting the
  /// organization instead (`OrganizationDetailScreen`'s own delete action),
  /// never by this row-level shortcut.
  final VoidCallback? onLeave;

  @override
  Widget build(BuildContext context) {
    final isOwner = org.myRole == 'owner';
    final scheme = context.colorScheme;

    return InkWell(
      onTap: () =>
          Get.toNamed<dynamic>(AppRoutes.organizationDetailPath(org.id)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CricketEntityAvatar(name: org.name, logoUrl: org.logoUrl),
              12.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CricketText(
                      text: org.name,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall,
                    ),
                    2.h,
                    CricketText(
                      text:
                          '${org.memberCount} ${TranslationKeys.members.tr}, '
                          '${org.teamCount} ${TranslationKeys.teams.tr}',
                      maxLines: 2,
                      textOverflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              8.w,
              // The owner pill is filled with the ink colour (the same
              // treatment as a selected filter chip); a member's is outlined.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isOwner ? scheme.onSurface : null,
                  border: Border.all(
                    color: isOwner ? scheme.onSurface : scheme.outline,
                  ),
                  borderRadius: 8.radius,
                ),
                child: CricketText(
                  text: isOwner
                      ? TranslationKeys.roleOwner.tr
                      : TranslationKeys.roleMember.tr,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: isOwner ? scheme.surface : scheme.onSurfaceVariant,
                    fontWeight: isOwner ? FontWeight.w600 : null,
                  ),
                ),
              ),
              if (onLeave != null)
                IconButton(
                  tooltip: TranslationKeys.leaveOrganization.tr,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.logout,
                    size: 18,
                    color: context.colors.statusDanger,
                  ),
                  onPressed: onLeave,
                )
              else
                4.w,
              Icon(
                Icons.chevron_right,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single [OrganizationRow] on its own card — the full Organizations
/// screen lists these one per organization.
class OrganizationCard extends StatelessWidget {
  const OrganizationCard({required this.org, this.onLeave, super.key});

  final OrganizationSummaryRes org;
  final VoidCallback? onLeave;

  @override
  Widget build(BuildContext context) {
    return CricketGroupedCard(
      children: [OrganizationRow(org: org, onLeave: onLeave)],
    );
  }
}
