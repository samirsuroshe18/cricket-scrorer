import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/pool_entry_res.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// One sheet handles both register (no [existingEntry]) and edit-price
/// (with one): registering needs a name; editing only ever touches
/// `basePrice` on an already-identified player, so the name renders
/// read-only instead of as a second editable field for the same person.
Future<void> showPoolPlayerSheet({
  required TournamentDetailController controller,
  PoolEntryRes? existingEntry,
}) async {
  final nameController = TextEditingController(text: existingEntry?.playerName ?? '');
  final priceController = TextEditingController(
    text: existingEntry != null ? '${existingEntry.basePrice}' : '',
  );
  final formKey = GlobalKey<FormState>();

  final saved = await CustomBottomSheet.wrapBottomSheet<bool>(
    headlineText: existingEntry == null
        ? TranslationKeys.registerPlayer.tr
        : TranslationKeys.editBasePrice.tr,
    child: Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (existingEntry == null)
              CricketTextField(
                controller: nameController,
                hintText: TranslationKeys.playerName.tr,
                labelText: TranslationKeys.playerName.tr,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
                isRequired: true,
              )
            else
              CricketText(
                text: existingEntry.playerName,
                style: Theme.of(Get.context!).textTheme.bodyLarge,
              ),
            16.h,
            CricketTextField(
              controller: priceController,
              hintText: TranslationKeys.basePrice.tr,
              labelText: TranslationKeys.basePrice.tr,
              prefixIcon: const Icon(Icons.currency_rupee),
              keyboardType: TextInputType.number,
              isRequired: true,
              validator: (value) {
                final parsed = int.tryParse((value ?? '').trim());
                if (parsed == null || parsed < 1 || parsed > 100000000) {
                  return TranslationKeys.invalidBasePrice.tr;
                }
                return null;
              },
            ),
            20.h,
            CricketButton(
              buttonText: TranslationKeys.save.tr,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final basePrice = int.parse(priceController.text.trim());

                final success = existingEntry == null
                    ? await controller.registerPoolPlayer(
                        playerName: nameController.text.trim(),
                        basePrice: basePrice,
                      )
                    : await controller.updatePoolEntry(
                        playerId: existingEntry.playerId,
                        basePrice: basePrice,
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

  if (saved == true) {
    CricketSnackbar.showSuccessMessage(
      existingEntry == null
          ? TranslationKeys.playerRegisteredInPool.tr
          : TranslationKeys.poolEntryUpdated.tr,
    );
  }
}
