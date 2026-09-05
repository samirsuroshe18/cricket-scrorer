import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organizations_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
            isRequired: true,
          ),
          const SizedBox(height: 20),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.organizations.tr),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.organizations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final error = controller.loadError.value;
          if (error != null && controller.organizations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CricketText(text: error, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  CricketButton(
                    buttonText: TranslationKeys.retry.tr,
                    onPressed: controller.loadOrganizations,
                    width: 160,
                  ),
                ],
              ),
            );
          }

          if (controller.organizations.isEmpty) {
            return Center(
              child: CricketText(text: TranslationKeys.noOrganizationsYet.tr),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadOrganizations,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.organizations.length,
              itemBuilder: (context, index) {
                final org = controller.organizations[index];
                return _OrganizationRow(org: org);
              },
            ),
          );
        }),
      ),
    );
  }
}

class _OrganizationRow extends StatelessWidget {
  const _OrganizationRow({required this.org});

  final OrganizationSummaryRes org;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: CricketText(text: org.name),
      subtitle: CricketText(
        text: '${org.memberCount} members · ${org.teamCount} teams',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () =>
          Get.toNamed<dynamic>(AppRoutes.organizationDetailPath(org.id)),
    );
  }
}
