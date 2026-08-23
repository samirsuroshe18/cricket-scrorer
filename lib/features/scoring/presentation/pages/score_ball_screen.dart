import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/scoring_constants.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/score_ball_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScoreBallScreen extends GetView<ScoreBallController> {
  const ScoreBallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.liveScore.tr),
      body: Padding(
        padding: 24.p,
        child: Column(
          children: [
            CricketText(
              text:
                  '${controller.match.teamA.name} vs ${controller.match.teamB.name}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            24.h,
            Obx(
              () => Column(
                children: [
                  CricketText(
                    text:
                        '${controller.totalRuns.value}/${controller.wickets.value}',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  8.h,
                  CricketText(
                    text:
                        '${TranslationKeys.overs.tr}: ${controller.overs.value}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  4.h,
                  CricketText(
                    text:
                        '${TranslationKeys.extras.tr}: ${controller.extrasTotal.value}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            24.h,
            CricketText(
              text: TranslationKeys.wideOrNoBall.tr,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            8.h,
            Obx(
              () => Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  FilterChip(
                    label: CricketText(text: TranslationKeys.wide.tr),
                    selected: controller.selectedFault.value == ExtraType.wide,
                    onSelected: (_) => controller.toggleFault(ExtraType.wide),
                  ),
                  FilterChip(
                    label: CricketText(text: TranslationKeys.noBall.tr),
                    selected:
                        controller.selectedFault.value == ExtraType.noBall,
                    onSelected: (_) => controller.toggleFault(ExtraType.noBall),
                  ),
                ],
              ),
            ),
            16.h,
            CricketText(
              text: TranslationKeys.byeOrLegBye.tr,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            8.h,
            Obx(
              () => Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  FilterChip(
                    label: CricketText(text: TranslationKeys.bye.tr),
                    selected: controller.selectedRunsFrom.value == RunsFrom.bye,
                    onSelected: controller.isRunsFromDisabled
                        ? null
                        : (_) => controller.toggleRunsFrom(RunsFrom.bye),
                  ),
                  FilterChip(
                    label: CricketText(text: TranslationKeys.legBye.tr),
                    selected:
                        controller.selectedRunsFrom.value == RunsFrom.legBye,
                    onSelected: controller.isRunsFromDisabled
                        ? null
                        : (_) => controller.toggleRunsFrom(RunsFrom.legBye),
                  ),
                ],
              ),
            ),
            24.h,
            CricketText(
              text: TranslationKeys.selectRuns.tr,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            16.h,
            Obx(
              () => Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [0, 1, 2, 3, 4, 6]
                    .map(
                      (runs) => SizedBox(
                        width: 64,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: controller.isScoring.value
                              ? null
                              : () => controller.scoreRuns(runs),
                          child: CricketText(text: '$runs'),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
