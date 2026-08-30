import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:get/get.dart';

/// The resolution UI for [SyncPhase.blockedOnRule] — a queued delivery
/// failed a genuine server-side rule check, not a connectivity problem, so
/// retrying it would fail identically forever. Undismissable for the same
/// reason [SyncConflictBottomSheet] is: leaving this state with nowhere for
/// the scorer to see it is indistinguishable from the app silently hanging.
///
/// Returns `true` only if the scorer chose to undo back through the stuck
/// delivery — the one resolution this state has, since the queue cannot
/// apply past it. `false`/`null` means "review later": nothing changes, and
/// `ScoreBallController._promptIfNeeded` will offer this sheet again next
/// time it runs, since [OfflineSyncService.phase] stays at `blockedOnRule`
/// until the scorer actually resolves it.
class SyncBlockedBottomSheet {
  const SyncBlockedBottomSheet._();

  static Future<bool?> show() {
    return CustomBottomSheet.warningBottomSheet<bool>(
      title: TranslationKeys.syncBlockedTitle.tr,
      message: TranslationKeys.syncBlockedMessage.tr,
      confirmButtonName: TranslationKeys.undoBackToHere.tr,
      cancelButtonName: TranslationKeys.reviewLater.tr,
      isDismissible: false,
    );
  }
}
