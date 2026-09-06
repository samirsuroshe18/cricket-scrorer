import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/coin_flip.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Starting a scheduled fixture into a real match. Both teams are already
/// fixed by the fixture, so unlike `CreateMatchScreen` this only ever asks
/// for overs and an optional toss — reusing the exact same `CoinFlip`
/// widget and toss-decision chips `CreateMatchScreen` already has. On
/// success, navigates straight into the existing live-scoring screen the
/// same way `CreateMatchController` does today
/// (`Get.toNamed(AppRoutes.scoreBall, arguments: ...)`), so this sheet adds
/// no new scoring UI of its own.
Future<void> showStartFixtureMatchSheet({
  required TournamentDetailController controller,
  required FixtureRes fixture,
}) async {
  final oversController = TextEditingController();
  String? tossWinner;
  String? tossDecision;

  await CustomBottomSheet.wrapBottomSheet<void>(
    headlineText: TranslationKeys.startMatch.tr,
    child: StatefulBuilder(
      builder: (context, setSheetState) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CricketTextField(
              controller: oversController,
              hintText: TranslationKeys.enterOvers.tr,
              labelText: TranslationKeys.overs.tr,
              prefixIcon: const Icon(Icons.timer_outlined),
              keyboardType: TextInputType.number,
              isRequired: true,
            ),
            16.h,
            CricketText(
              text: TranslationKeys.tossOptional.tr,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            8.h,
            CricketText(
              text: TranslationKeys.tossWinner.tr,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            8.h,
            CoinFlip(
              // A re-flip clears the previous decision too — a decision
              // picked for the old winner has no meaning for the new one.
              // Mirrors CreateMatchController.recordTossWinner.
              onResult: (winner) => setSheetState(() {
                tossWinner = winner;
                tossDecision = null;
              }),
            ),
            if (tossWinner != null) ...[
              16.h,
              CricketText(
                text: TranslationKeys.tossDecision.tr,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              8.h,
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  FilterChip(
                    label: CricketText(text: TranslationKeys.bat.tr),
                    selected: tossDecision == 'bat',
                    onSelected: (_) => setSheetState(() => tossDecision = 'bat'),
                  ),
                  FilterChip(
                    label: CricketText(text: TranslationKeys.bowl.tr),
                    selected: tossDecision == 'bowl',
                    onSelected: (_) => setSheetState(() => tossDecision = 'bowl'),
                  ),
                ],
              ),
            ],
            20.h,
            CricketButton(
              buttonText: TranslationKeys.startMatch.tr,
              onPressed: () async {
                final overs = int.tryParse(oversController.text.trim());
                if (overs == null || overs < 1 || overs > 50) {
                  CricketSnackbar.showAlertMessage(TranslationKeys.invalidOvers.tr);
                  return;
                }
                if ((tossWinner == null) != (tossDecision == null)) {
                  CricketSnackbar.showAlertMessage(TranslationKeys.tossIncomplete.tr);
                  return;
                }

                final outcome = await controller.startFixtureMatch(
                  fixture.id,
                  totalOvers: overs,
                  tossWinner: tossWinner,
                  tossDecision: tossDecision,
                );

                if (outcome.match != null) {
                  Get.back<void>();
                  await Get.toNamed<dynamic>(
                    AppRoutes.scoreBall,
                    arguments: outcome.match,
                  );
                  // The live-scoring screen resolves the fixture (status,
                  // winner) server-side as the match completes; this
                  // screen's own cached fixtures list only reflects that
                  // once we reload after popping back — found on-device,
                  // the same class of gap `loadDetail`'s org-list
                  // counterpart was fixed for. A match that *completes*
                  // (rather than a manual back-out) pops all the way to
                  // home via offNamedUntil, which can tear this
                  // tag-registered controller down first — reloading a
                  // torn-down controller is dead work, not a crash, but
                  // there's no point doing it.
                  if (Get.isRegistered<TournamentDetailController>(
                    tag: controller.tournamentId,
                  )) {
                    await controller.loadDetail();
                  }
                } else {
                  CricketSnackbar.showAlertMessage(
                    outcome.errorMessage ?? TranslationKeys.somethingWentWrong.tr,
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}
