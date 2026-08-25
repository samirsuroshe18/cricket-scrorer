import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The unauthenticated entry point: type a share code, land in
/// [SpectatorScreen]. Reachable from [LoginScreen] specifically because it is
/// the one auth-flow screen someone without an account actually opens.
///
/// This sheet does not resolve or validate the code itself beyond "not
/// empty" — it hands whatever was typed to the same route a `/spectate/<code>`
/// deep link resolves to, and [SpectatorController] surfaces a real 404 from
/// the server if it is wrong. Duplicating server-side validation here would
/// just be a second place for the two to disagree.
class WatchMatchBottomSheet extends StatefulWidget {
  const WatchMatchBottomSheet({super.key});

  static Future<void> show() {
    return CustomBottomSheet.cricketCustomBottomSheet<void>(
      headlineText: TranslationKeys.watchLiveMatch.tr,
      isDismissible: true,
      heightFactor: 0.45,
      child: const WatchMatchBottomSheet(),
    );
  }

  @override
  State<WatchMatchBottomSheet> createState() => _WatchMatchBottomSheetState();
}

class _WatchMatchBottomSheetState extends State<WatchMatchBottomSheet> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _validateCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.matchCodeRequired.tr;
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final code = _controller.text.trim();
    Get.back<void>();
    unawaited(Get.toNamed(AppRoutes.spectatorPath(code)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CricketText(
            text: TranslationKeys.enterMatchCodeDescription.tr,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          16.h,
          CricketTextField(
            controller: _controller,
            labelText: TranslationKeys.matchCode.tr,
            hintText: TranslationKeys.enterMatchCode.tr,
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
            isRequired: true,
            validator: _validateCode,
          ),
          24.h,
          CricketButton(
            buttonText: TranslationKeys.watchLiveMatch.tr,
            onPressed: _submit,
          ),
          16.h,
        ],
      ),
    );
  }
}
