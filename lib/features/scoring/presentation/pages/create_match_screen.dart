import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/create_match_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/coin_flip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateMatchScreen extends GetView<CreateMatchController> {
  const CreateMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.createMatch.tr),
      body: SingleChildScrollView(
        padding: 24.p,
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TeamChipRow(
                isLoadingTeams: controller.isLoadingTeams,
                myTeams: controller.myTeams,
                selectedTeamId: controller.selectedTeamAId,
                onSelect: controller.selectTeamA,
              ),
              CricketTextField(
                controller: controller.teamAController,
                hintText: TranslationKeys.enterTeamAName.tr,
                labelText: TranslationKeys.teamAName.tr,
                prefixIcon: const Icon(Icons.sports_cricket),
                validator: controller.validateTeamName,
                textCapitalization: TextCapitalization.words,
                // Matches Team.name's backend maxlength: 50 — without this,
                // a name over the limit passes this form cleanly and only
                // fails on the backend's own validation.
                maxLength: 50,
                isRequired: true,
              ),
              16.h,
              _TeamChipRow(
                isLoadingTeams: controller.isLoadingTeams,
                myTeams: controller.myTeams,
                selectedTeamId: controller.selectedTeamBId,
                onSelect: controller.selectTeamB,
              ),
              CricketTextField(
                controller: controller.teamBController,
                hintText: TranslationKeys.enterTeamBName.tr,
                labelText: TranslationKeys.teamBName.tr,
                prefixIcon: const Icon(Icons.sports_cricket),
                validator: controller.validateTeamName,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
                isRequired: true,
              ),
              16.h,
              CricketTextField(
                controller: controller.oversController,
                hintText: TranslationKeys.enterOvers.tr,
                labelText: TranslationKeys.overs.tr,
                prefixIcon: const Icon(Icons.timer_outlined),
                validator: controller.validateOvers,
                keyboardType: TextInputType.number,
                isRequired: true,
              ),
              24.h,
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
              CoinFlip(onResult: controller.recordTossWinner),
              16.h,
              // The decision only makes sense once a winner exists — showing
              // it beforehand would let the scorer pick bat/bowl for nobody
              // in particular.
              Obx(() {
                if (controller.tossWinner.value == null) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
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
                          selected: controller.tossDecision.value == 'bat',
                          onSelected: (_) =>
                              controller.toggleTossDecision('bat'),
                        ),
                        FilterChip(
                          label: CricketText(text: TranslationKeys.bowl.tr),
                          selected: controller.tossDecision.value == 'bowl',
                          onSelected: (_) =>
                              controller.toggleTossDecision('bowl'),
                        ),
                      ],
                    ),
                  ],
                );
              }),
              24.h,
              CricketButton(
                buttonText: TranslationKeys.createMatch.tr,
                onPressed: controller.createMatch,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The "reuse an existing team" chip picker shown above each side's name
/// field — identical shape for team A and team B, parameterized by which
/// selection/callback it drives.
class _TeamChipRow extends StatelessWidget {
  const _TeamChipRow({
    required this.isLoadingTeams,
    required this.myTeams,
    required this.selectedTeamId,
    required this.onSelect,
  });

  final RxBool isLoadingTeams;
  final RxList<TeamSummary> myTeams;
  final Rxn<String> selectedTeamId;
  final void Function(TeamSummary) onSelect;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoadingTeams.value || myTeams.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CricketText(
            text: TranslationKeys.reuseExistingTeam.tr,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          8.h,
          Wrap(
            spacing: 8,
            children: [
              for (final team in myTeams)
                FilterChip(
                  label: CricketText(text: team.name),
                  selected: selectedTeamId.value == team.id,
                  onSelected: (_) => onSelect(team),
                ),
            ],
          ),
          8.h,
        ],
      );
    });
  }
}
