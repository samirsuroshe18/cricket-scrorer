import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:get/get.dart';

/// The delete confirmation for [HomeController.deleteMatch] — shared by
/// every place a [MatchHistoryCard] appears inside the home shell (the
/// dashboard's own sections and the full Matches tab), so both go through
/// the same warning-sheet pattern rather than each tab growing its own copy.
Future<void> confirmDeleteMatch(
  HomeController controller,
  MatchHistoryItem item,
) async {
  final confirmed = await CustomBottomSheet.warningBottomSheet<bool>(
    title: TranslationKeys.deleteMatchConfirmTitle.tr,
    message: TranslationKeys.deleteMatchConfirmMessage.tr,
    confirmButtonName: TranslationKeys.deleteMatch.tr,
  );
  if (confirmed == true) {
    await controller.deleteMatch(item);
  }
}
