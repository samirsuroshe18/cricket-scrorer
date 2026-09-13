import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image_source.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organizations_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Every organization the caller owns or belongs to — reached from Home's
/// app bar. Mirrors `MatchHistoryCard`'s card treatment and
/// `TeamProfileScreen`'s monogram-avatar pattern so this reads as the same
/// app, not a bolted-on generic list.
class OrganizationsListScreen extends GetView<OrganizationsListController> {
  const OrganizationsListScreen({super.key});

  Future<void> _showCreateSheet(BuildContext context) async {
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
      CricketSnackbar.showSuccessMessage(
        TranslationKeys.organizationCreated.tr,
      );
    }
  }

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
        onPressed: () => _showCreateSheet(context),
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
            return _MessageState(
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
            return _MessageState(
              icon: Icons.groups_outlined,
              message: TranslationKeys.noOrganizationsYet.tr,
              action: CricketButton(
                buttonText: TranslationKeys.createOrganization.tr,
                onPressed: () => _showCreateSheet(context),
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
                return _OrganizationCard(
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

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.message, this.action});

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

class _OrganizationCard extends StatelessWidget {
  const _OrganizationCard({required this.org, this.onLeave});

  final OrganizationSummaryRes org;

  /// Null for a row the caller owns — an owner leaves by deleting the
  /// organization instead (`OrganizationDetailScreen`'s own delete action),
  /// never by this row-level shortcut.
  final VoidCallback? onLeave;

  /// Initials of the first two words of the name — same derivation
  /// `_TeamHeader._monogram` uses on `TeamProfileScreen`, minus the
  /// `shortName` branch (an org has no equivalent field).
  String _monogram() {
    final words = org.name.trim().split(RegExp(r'\s+'));
    final letters = words.take(2).map((w) => w.isEmpty ? '' : w[0]).join();
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }

  /// The uploaded logo when present (`OrganizationDetailScreen`'s owner-only
  /// upload is the only writer of it), else the same monogram fallback this
  /// card always showed.
  Widget _avatar(BuildContext context) {
    final logoUrl = org.logoUrl;
    if (logoUrl == null || logoUrl.isEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: context.colors.chipBackground,
        child: CricketText(
          text: _monogram(),
          style: context.textTheme.titleSmall?.copyWith(
            color: context.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 22,
      backgroundColor: context.colors.chipBackground,
      child: ClipOval(
        child: CricketImage(
          source: CricketImageSource.network(logoUrl),
          width: 44,
          height: 44,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = org.myRole == 'owner';

    return Material(
      color: context.colorScheme.surfaceContainerHighest,
      borderRadius: 12.radius,
      child: InkWell(
        borderRadius: 12.radius,
        onTap: () =>
            Get.toNamed<dynamic>(AppRoutes.organizationDetailPath(org.id)),
        child: Padding(
          padding: 16.p,
          child: Row(
            children: [
              _avatar(context),
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
                    4.h,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.groups_outlined,
                          size: 14,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        4.w,
                        CricketText(
                          text: '${org.memberCount} ${TranslationKeys.members.tr}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        12.w,
                        Icon(
                          Icons.shield_outlined,
                          size: 14,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        4.w,
                        CricketText(
                          text: '${org.teamCount} ${TranslationKeys.teams.tr}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              8.w,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isOwner
                      ? context.colors.statusInfo.withValues(alpha: 0.12)
                      : null,
                  border: isOwner
                      ? null
                      : Border.all(color: context.colorScheme.outline),
                  borderRadius: 8.radius,
                ),
                child: CricketText(
                  text: org.myRole,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: isOwner
                        ? context.colors.statusInfo
                        : context.colorScheme.onSurfaceVariant,
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
                color: context.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
