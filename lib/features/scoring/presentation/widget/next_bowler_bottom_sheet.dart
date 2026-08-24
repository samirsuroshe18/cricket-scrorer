import 'dart:async';

import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Who bowls the next over. Opens the moment an over ends and blocks until it
/// is answered — the server refuses every delivery with `BOWLER_NOT_SELECTED`
/// meanwhile, so there is nothing useful behind it to return to.
///
/// **The previous over's bowler is shown and greyed, not hidden.** Law 17.6
/// says he cannot bowl two overs running, and the server enforces that with
/// `BOWLER_CANNOT_BOWL_CONSECUTIVE_OVERS`. Hiding him would leave a scorer
/// hunting for a name that ought to be there; greying him with a reason answers
/// the question before it is asked. This mirrors how the wicket sheet treats
/// dismissal types that are impossible off the armed delivery.
///
/// **The name field is not a convenience — it is what stops this being a dead
/// end.** Nothing but `start-innings` and `select-bowler` ever creates a Player
/// on the bowling side, so there is no roster to list: [knownBowlers] holds
/// only bowlers seen this innings, and on a fresh app launch mid-match that can
/// be a single name — the greyed one. The field is always present and always
/// enabled.
class NextBowlerBottomSheet extends StatefulWidget {
  const NextBowlerBottomSheet({
    required this.excludedBowlerName,
    required this.knownBowlers,
    required this.isSubmitting,
    required this.onSubmit,
    super.key,
  });

  /// Whom the server will refuse, straight from `nextBowler.excludedBowlerName`.
  /// Null only if the server sent no exclusion, in which case nothing is greyed.
  final String? excludedBowlerName;

  /// Bowlers seen this innings. A shortcut, not a roster — see the class doc.
  final List<String> knownBowlers;

  /// Button-level loading, owned by the controller.
  final RxBool isSubmitting;

  /// Returns true once the server accepts the bowler. While it returns false
  /// the sheet stays up with the typed name intact, so a rejected name is
  /// corrected rather than retyped.
  final Future<bool> Function(String bowlerName) onSubmit;

  static Future<void> show({
    required String? excludedBowlerName,
    required List<String> knownBowlers,
    required RxBool isSubmitting,
    required Future<bool> Function(String) onSubmit,
  }) {
    return CustomBottomSheet.cricketCustomBottomSheet<void>(
      headlineText: TranslationKeys.selectBowler.tr,
      isXButtonRequired: false,
      isDismissible: false,
      heightFactor: 0.6,
      child: NextBowlerBottomSheet(
        excludedBowlerName: excludedBowlerName,
        knownBowlers: knownBowlers,
        isSubmitting: isSubmitting,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<NextBowlerBottomSheet> createState() => _NextBowlerBottomSheetState();
}

class _NextBowlerBottomSheetState extends State<NextBowlerBottomSheet> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isExcluded(String name) {
    final excluded = widget.excludedBowlerName?.trim().toLowerCase();
    if (excluded == null || excluded.isEmpty) return false;
    return name.trim().toLowerCase() == excluded;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.bowlerNameRequired.tr;
    }
    return null;
  }

  /// Tapping a chip fills the field rather than submitting, so the chips and
  /// the field are one input with one confirm — a scorer can pick a name and
  /// still correct a typo in it before sending.
  void _pick(String name) {
    setState(() {
      _controller.text = name;
      _controller.selection = TextSelection.collapsed(offset: name.length);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _controller.text.trim();

    // The same rule the server applies, checked here so the scorer sees it
    // without a round trip. The server rejects it independently — this is a
    // shortcut, never the enforcement.
    if (_isExcluded(name)) {
      CricketSnackbar.showAlertMessage(
        TranslationKeys.cannotBowlConsecutiveOvers.tr,
      );
      return;
    }

    if (await widget.onSubmit(name)) {
      Get.back<void>();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final excluded = widget.excludedBowlerName;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CricketText(
              text: TranslationKeys.chooseBowler.tr,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),

            if (widget.knownBowlers.isNotEmpty) ...[
              16.h,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.knownBowlers.map((String name) {
                  final blocked = _isExcluded(name);
                  return ChoiceChip(
                    label: CricketText(text: name),
                    selected: _controller.text.trim() == name,
                    // Greyed, not removed. `onSelected: null` is what disables a
                    // chip in Material; the reason line below says why.
                    onSelected: blocked ? null : (_) => _pick(name),
                  );
                }).toList(),
              ),
            ],

            if (excluded != null && excluded.isNotEmpty) ...[
              8.h,
              CricketText(
                text: TranslationKeys.cannotBowlConsecutiveOvers.tr,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            16.h,
            CricketTextField(
              controller: _controller,
              labelText: TranslationKeys.bowlerName.tr,
              hintText: TranslationKeys.enterBowlerName.tr,
              textCapitalization: TextCapitalization.words,
              maxLength: 50,
              isRequired: true,
              validator: _validateName,
            ),

            24.h,
            Obx(
              () => CricketButton(
                buttonText: TranslationKeys.selectBowler.tr,
                isDisabled: widget.isSubmitting.value,
                onPressed: () => unawaited(_submit()),
              ),
            ),
            16.h,
          ],
        ),
      ),
    );
  }
}
