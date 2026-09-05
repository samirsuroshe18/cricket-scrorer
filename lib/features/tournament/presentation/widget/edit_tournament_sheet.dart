import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/format_status_chips.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Renaming/re-formatting/re-statusing an existing tournament — a single
/// combined sheet, prefilled, mirroring `showAssignScorerSheet`'s
/// standalone-function shape.
Future<void> showEditTournamentSheet({
  required TournamentDetailController controller,
}) async {
  final tournament = controller.detail.value;
  if (tournament == null) return;

  final nameController = TextEditingController(text: tournament.name);
  var selectedFormat = tournament.format;
  var selectedStatus = tournament.status;

  final updated = await CustomBottomSheet.wrapBottomSheet<bool>(
    headlineText: TranslationKeys.editTournament.tr,
    child: StatefulBuilder(
      builder: (context, setSheetState) => SingleChildScrollView(
        child: Column(
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
            CricketText(text: TranslationKeys.format.tr),
            8.h,
            FormatChoiceChips(
              selected: selectedFormat,
              onSelected: (format) =>
                  setSheetState(() => selectedFormat = format),
            ),
            16.h,
            CricketText(text: TranslationKeys.status.tr),
            8.h,
            StatusChoiceChips(
              selected: selectedStatus,
              onSelected: (status) =>
                  setSheetState(() => selectedStatus = status),
            ),
            20.h,
            CricketButton(
              buttonText: TranslationKeys.save.tr,
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final success = await controller.updateTournament(
                  name: name,
                  format: selectedFormat,
                  status: selectedStatus,
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
    ),
  );

  if (updated == true) {
    CricketSnackbar.showSuccessMessage(TranslationKeys.tournamentUpdated.tr);
  }
}
