import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organization_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
            keyboardType: TextInputType.emailAddress,
            isRequired: true,
          ),
          const SizedBox(height: 20),
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
            isRequired: true,
          ),
          const SizedBox(height: 12),
          CricketTextField(
            controller: shortNameController,
            hintText: TranslationKeys.teamShortName.tr,
            labelText: TranslationKeys.teamShortName.tr,
          ),
          const SizedBox(height: 20),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CricketText(text: error, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  CricketButton(
                    buttonText: TranslationKeys.retry.tr,
                    onPressed: controller.loadDetail,
                    width: 160,
                  ),
                ],
              ),
            );
          }
          if (detail == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: controller.loadDetail,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CricketText(
                  text: detail.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CricketText(
                      text: TranslationKeys.members.tr,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (controller.isOwner)
                      TextButton(
                        onPressed: _showAddMemberSheet,
                        child: CricketText(text: TranslationKeys.addMember.tr),
                      ),
                  ],
                ),
                for (final member in detail.members)
                  ListTile(
                    title: CricketText(text: member.name),
                    subtitle: CricketText(text: member.role),
                    trailing:
                        controller.isOwner ||
                            member.id == controller.currentUserId
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: member.role == 'owner'
                                ? null
                                : () => _confirmRemoveMember(
                                    member,
                                    member.id == controller.currentUserId,
                                  ),
                          )
                        : null,
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CricketText(
                      text: TranslationKeys.teams.tr,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (controller.isOwner)
                      TextButton(
                        onPressed: _showAddTeamSheet,
                        child: CricketText(text: TranslationKeys.addTeam.tr),
                      ),
                  ],
                ),
                if (detail.teams.isEmpty)
                  CricketText(text: TranslationKeys.noTeamsYet.tr)
                else
                  for (final team in detail.teams)
                    ListTile(
                      title: CricketText(text: team.name),
                      subtitle: team.shortName != null
                          ? CricketText(text: team.shortName!)
                          : null,
                    ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
