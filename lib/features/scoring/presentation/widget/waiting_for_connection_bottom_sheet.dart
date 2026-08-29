import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Blocks the console at an innings break reached while offline. A sync
/// batch can never carry `start-innings` — see docs/api.md — so there is
/// nothing valid to submit here until signal returns; unlike
/// [OpenersBottomSheet], this sheet has no form and no submit action.
///
/// Self-closes the moment [isBlocked] goes false — which happens once the
/// innings-ending batch actually syncs clean, at which point
/// `ScoreBallController`'s existing `isInningsComplete` listener takes over
/// and reopens the real, online openers sheet unchanged.
class WaitingForConnectionBottomSheet extends StatefulWidget {
  const WaitingForConnectionBottomSheet({
    required this.isFinalInnings,
    required this.isBlocked,
    super.key,
  });

  /// True when the innings that just (provisionally) ended was innings 2 —
  /// there is no "next innings" to wait for, only the match result.
  final bool isFinalInnings;

  final RxBool isBlocked;

  static Future<void> show({
    required bool isFinalInnings,
    required RxBool isBlocked,
  }) {
    return CustomBottomSheet.cricketCustomBottomSheet<void>(
      headlineText: TranslationKeys.waitingForConnectionTitle.tr,
      isXButtonRequired: false,
      isDismissible: false,
      heightFactor: 0.4,
      child: WaitingForConnectionBottomSheet(
        isFinalInnings: isFinalInnings,
        isBlocked: isBlocked,
      ),
    );
  }

  @override
  State<WaitingForConnectionBottomSheet> createState() =>
      _WaitingForConnectionBottomSheetState();
}

class _WaitingForConnectionBottomSheetState
    extends State<WaitingForConnectionBottomSheet> {
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    _worker = ever<bool>(widget.isBlocked, (blocked) {
      if (!blocked && (Get.isBottomSheetOpen ?? false)) {
        Get.back<void>();
      }
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.wifiOff,
            size: 40,
            color: context.colors.statusWarning,
          ),
          16.h,
          CricketText(
            text: widget.isFinalInnings
                ? TranslationKeys.waitingForConnectionMessageFinal.tr
                : TranslationKeys.waitingForConnectionMessage.tr,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
