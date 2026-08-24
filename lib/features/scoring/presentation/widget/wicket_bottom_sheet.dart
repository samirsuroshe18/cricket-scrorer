import 'dart:async';

import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/strike.dart';
import 'package:cricket_scorer/features/scoring/data/scoring_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Everything a dismissal needs, in one sheet and one request.
///
/// The sheet owns `runs` rather than reusing the console's run grid. That is
/// what makes an invalid combination unreachable instead of merely rejected:
/// the five striker-only types always send 0, and only a run out exposes a runs
/// input at all.
class WicketBottomSheet extends StatefulWidget {
  const WicketBottomSheet({
    required this.strike,
    required this.extraType,
    required this.isFinalWicket,
    required this.isSubmitting,
    required this.onSubmit,
    super.key,
  });

  /// The two batsmen at the crease, so the who-is-out tiles can name people
  /// rather than ends.
  final Strike? strike;

  /// The armed delivery fault, which narrows the legal dismissal types.
  final String? extraType;

  /// True when this wicket is the 10th — nobody comes in, so the sheet does not
  /// ask for a name.
  final bool isFinalWicket;

  final RxBool isSubmitting;

  /// Returns true once the ball is accepted; the sheet stays open on failure so
  /// a rejected entry is corrected rather than retyped.
  final Future<bool> Function({
    required String wicketType,
    required String dismissedBatsman,
    required int runs,
    String? incomingBatsmanName,
  })
  onSubmit;

  static Future<void> show({
    required Strike? strike,
    required String? extraType,
    required bool isFinalWicket,
    required RxBool isSubmitting,
    required Future<bool> Function({
      required String wicketType,
      required String dismissedBatsman,
      required int runs,
      String? incomingBatsmanName,
    })
    onSubmit,
  }) {
    return CustomBottomSheet.cricketCustomBottomSheet<void>(
      headlineText: TranslationKeys.howOut.tr,
      heightFactor: 0.8,
      child: WicketBottomSheet(
        strike: strike,
        extraType: extraType,
        isFinalWicket: isFinalWicket,
        isSubmitting: isSubmitting,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<WicketBottomSheet> createState() => _WicketBottomSheetState();
}

/// Display label per wire value. Kept beside the sheet rather than on
/// [WicketType], which holds wire values only and must not carry UI strings.
const Map<String, String> _wicketLabels = <String, String>{
  WicketType.bowled: TranslationKeys.bowled,
  WicketType.caught: TranslationKeys.caught,
  WicketType.lbw: TranslationKeys.lbw,
  WicketType.runOut: TranslationKeys.runOut,
  WicketType.stumped: TranslationKeys.stumped,
  WicketType.hitWicket: TranslationKeys.hitWicket,
};

class _WicketBottomSheetState extends State<WicketBottomSheet> {
  String? _type;
  String _dismissed = DismissedBatsman.striker;
  int _runs = 0;

  final _incomingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final List<String> _allowed = WicketType.allowedFor(widget.extraType);

  bool get _isRunOut => _type == WicketType.runOut;

  /// Why a type is unavailable. Shown instead of hiding it, so a scorer hunting
  /// for "caught" mid-over finds it and learns why it is greyed.
  String get _disabledReason => widget.extraType == ExtraType.noBall
      ? TranslationKeys.notPossibleOffNoBall.tr
      : TranslationKeys.notPossibleOffWide.tr;

  String? _validateIncoming(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.batsmanNameRequired.tr;
    }
    return null;
  }

  Future<void> _submit() async {
    final type = _type;
    if (type == null) {
      CricketSnackbar.showAlertMessage(TranslationKeys.howOut.tr);
      return;
    }

    String? incoming;
    if (!widget.isFinalWicket) {
      if (!_formKey.currentState!.validate()) return;
      incoming = _incomingController.text.trim();

      // Same check the server applies, surfaced without a round trip.
      final atCrease = <String?>[
        widget.strike?.strikerName,
        widget.strike?.nonStrikerName,
      ].whereType<String>().map((String n) => n.toLowerCase());

      if (atCrease.contains(incoming.toLowerCase())) {
        CricketSnackbar.showAlertMessage(
          TranslationKeys.batsmenMustDiffer.tr,
        );
        return;
      }
    }

    final accepted = await widget.onSubmit(
      wicketType: type,
      // Only a run out can take the non-striker; everything else is the batsman
      // facing, so the sheet never sends anything else.
      dismissedBatsman: _isRunOut ? _dismissed : DismissedBatsman.striker,
      // Nothing is scored off the other five.
      runs: _isRunOut ? _runs : 0,
      incomingBatsmanName: incoming,
    );

    if (accepted) Get.back<void>();
  }

  @override
  void dispose() {
    _incomingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strike = widget.strike;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // No section label here — the sheet headline already reads
            // "How out?", and repeating it wastes a line the scorer is reading
            // under time pressure.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WicketType.all.map((String type) {
                final enabled = _allowed.contains(type);
                return FilterChip(
                  label: CricketText(text: _wicketLabels[type]!.tr),
                  selected: _type == type,
                  onSelected: enabled
                      ? (_) => setState(() => _type = type)
                      : null,
                );
              }).toList(),
            ),
            if (_allowed.length < WicketType.all.length) ...[
              8.h,
              CricketText(
                text: _disabledReason,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            // Only a run out can take either batsman or carry runs.
            if (_isRunOut) ...[
              16.h,
              _Label(text: TranslationKeys.whoIsOut.tr),
              8.h,
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: CricketText(
                      text: strike?.strikerName ?? TranslationKeys.striker.tr,
                    ),
                    selected: _dismissed == DismissedBatsman.striker,
                    onSelected: (_) => setState(
                      () => _dismissed = DismissedBatsman.striker,
                    ),
                  ),
                  ChoiceChip(
                    label: CricketText(
                      text:
                          strike?.nonStrikerName ??
                          TranslationKeys.nonStriker.tr,
                    ),
                    selected: _dismissed == DismissedBatsman.nonStriker,
                    onSelected: (_) => setState(
                      () => _dismissed = DismissedBatsman.nonStriker,
                    ),
                  ),
                ],
              ),
              16.h,
              _Label(text: TranslationKeys.runsCompleted.tr),
              8.h,
              Wrap(
                spacing: 8,
                children: [0, 1, 2, 3].map((int r) {
                  return ChoiceChip(
                    label: CricketText(text: '$r'),
                    selected: _runs == r,
                    onSelected: (_) => setState(() => _runs = r),
                  );
                }).toList(),
              ),
            ],

            if (!widget.isFinalWicket) ...[
              16.h,
              CricketTextField(
                controller: _incomingController,
                labelText: TranslationKeys.newBatsman.tr,
                hintText: TranslationKeys.enterNewBatsmanName.tr,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
                isRequired: true,
                validator: _validateIncoming,
              ),
            ],

            24.h,
            Obx(
              () => CricketButton(
                buttonText: TranslationKeys.confirmWicket.tr,
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

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return CricketText(text: text, style: context.textTheme.titleSmall);
  }
}
