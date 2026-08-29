import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:get/get.dart';

/// The reject-and-alert UI for a `409 SYNC_CONFLICT` — someone else scored
/// while this device was offline, and the queued deliveries here cannot
/// apply automatically. Undismissable on purpose: this is the one state
/// where the console must not let scoring continue unacknowledged, since a
/// rejected write nowhere the scorer can see it is the same failure as a
/// silent overwrite.
///
/// Returns `true` only if the scorer chose to discard the local queue and
/// reload from the server — the confirmed, explicit resolution this feature
/// offers. `false`/`null` means "review later": nothing changes, and
/// `ScoreBallController._promptIfNeeded` will offer this sheet again the
/// next time it runs, since [OfflineSyncService.phase] stays at `conflict`
/// until an actual resolution happens.
class SyncConflictBottomSheet {
  const SyncConflictBottomSheet._();

  static Future<bool?> show() {
    return CustomBottomSheet.warningBottomSheet<bool>(
      title: TranslationKeys.syncConflictTitle.tr,
      message: TranslationKeys.syncConflictMessage.tr,
      confirmButtonName: TranslationKeys.discardAndReload.tr,
      cancelButtonName: TranslationKeys.reviewLater.tr,
      isDismissible: false,
    );
  }
}
