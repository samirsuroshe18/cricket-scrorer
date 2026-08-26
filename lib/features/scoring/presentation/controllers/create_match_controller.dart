import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/dialogue/custom_dialog.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_match_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/create_match.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateMatchController extends GetxController {
  final CreateMatchUseCase createMatchUseCase;

  CreateMatchController({required this.createMatchUseCase});

  final teamAController = TextEditingController();
  final teamBController = TextEditingController();
  final oversController = TextEditingController();

  /// `teamA` / `teamB` / null (toss skipped — [CoinFlip] never tapped).
  /// Set only from [CoinFlip.onResult]; never tapped directly, unlike
  /// [tossDecision].
  final tossWinner = Rxn<String>();

  /// `bat` / `bowl` / null.
  final tossDecision = Rxn<String>();

  /// Called back from [CoinFlip] once a flip lands. A re-flip clears
  /// [tossDecision] too — a decision picked for the previous winner has
  /// nothing to do with whoever the coin names this time.
  void recordTossWinner(String value) {
    tossWinner.value = value;
    tossDecision.value = null;
  }

  void toggleTossDecision(String value) {
    tossDecision.value = tossDecision.value == value ? null : value;
  }

  final formKey = GlobalKey<FormState>();

  String? validateTeamName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.teamNameRequired.tr;
    }
    return null;
  }

  String? validateOvers(String? value) {
    final overs = int.tryParse(value?.trim() ?? '');
    if (overs == null || overs < 1 || overs > 50) {
      return TranslationKeys.invalidOvers.tr;
    }
    return null;
  }

  Future<void> createMatch() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final teamAName = teamAController.text.trim();
    final teamBName = teamBController.text.trim();

    if (teamAName.toLowerCase() == teamBName.toLowerCase()) {
      CricketSnackbar.showAlertMessage(TranslationKeys.teamNamesMustDiffer.tr);
      return;
    }

    // Both or neither, mirroring the server's own rule — caught here so a
    // half-filled toss never reaches the request only to bounce off
    // INVALID_TOSS_RESULT.
    if ((tossWinner.value == null) != (tossDecision.value == null)) {
      CricketSnackbar.showAlertMessage(TranslationKeys.tossIncomplete.tr);
      return;
    }

    CricketLoaderDialog.show();

    Either<CricketResponse<CreateMatchRes>, CricketFailure> response =
        await createMatchUseCase(
          params: CreateMatchReq(
            teamAName: teamAName,
            teamBName: teamBName,
            totalOvers: int.parse(oversController.text.trim()),
            tossWinner: tossWinner.value,
            tossDecision: tossDecision.value,
          ),
        );

    CricketLoaderDialog.hide();

    if (response.isResult) {
      CricketSnackbar.showSuccessMessage(response.result.message);
      unawaited(
        Get.toNamed<dynamic>(
          AppRoutes.scoreBall,
          arguments: response.result.data,
        ),
      );
    } else {
      CricketSnackbar.showAlertMessage(response.fallback.message);
    }
  }

  @override
  void onClose() {
    teamAController.dispose();
    teamBController.dispose();
    oversController.dispose();
    super.onClose();
  }
}
