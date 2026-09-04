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
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/create_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateMatchController extends GetxController {
  final CreateMatchUseCase createMatchUseCase;
  final GetMyTeamsUseCase getMyTeamsUseCase;

  CreateMatchController({
    required this.createMatchUseCase,
    required this.getMyTeamsUseCase,
  });

  final teamAController = TextEditingController();
  final teamBController = TextEditingController();
  final oversController = TextEditingController();

  /// The caller's own teams, for the "reuse an existing team" chip picker.
  /// A failure loading these just leaves the picker empty — free-text team
  /// creation still works either way, so it is not surfaced as an error.
  final myTeams = <TeamSummary>[].obs;
  final isLoadingTeams = true.obs;

  /// Non-null exactly while side A's field holds a selected, existing
  /// team's own name untouched — see [_handleTeamATextChanged]. Null means
  /// free-text mode: submitting creates a brand-new team from whatever name
  /// is typed, today's original behavior.
  final selectedTeamAId = Rxn<String>();
  final selectedTeamBId = Rxn<String>();

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

  @override
  void onInit() {
    super.onInit();
    teamAController.addListener(_handleTeamATextChanged);
    teamBController.addListener(_handleTeamBTextChanged);
    unawaited(_loadMyTeams());
  }

  Future<void> _loadMyTeams() async {
    isLoadingTeams.value = true;
    final response = await getMyTeamsUseCase();
    isLoadingTeams.value = false;
    if (response.isResult) {
      myTeams.assignAll(response.result.data?.teams ?? const []);
    }
  }

  String? _nameOf(String? teamId) {
    if (teamId == null) return null;
    for (final team in myTeams) {
      if (team.id == teamId) return team.name;
    }
    return null;
  }

  /// Clears [selectedTeamAId] the moment the field's text stops matching the
  /// selected team's own name — whether that's the scorer manually retyping
  /// over it, or [clearTeamASelection]'s own `.clear()` call. A
  /// programmatic `.text = team.name` assignment from [selectTeamA] always
  /// matches, so it never triggers this.
  void _handleTeamATextChanged() {
    final selectedId = selectedTeamAId.value;
    if (selectedId == null) return;
    if (teamAController.text != _nameOf(selectedId)) {
      selectedTeamAId.value = null;
    }
  }

  void _handleTeamBTextChanged() {
    final selectedId = selectedTeamBId.value;
    if (selectedId == null) return;
    if (teamBController.text != _nameOf(selectedId)) {
      selectedTeamBId.value = null;
    }
  }

  /// Tapping the already-selected chip again is the explicit "clear
  /// selection" action; tapping a different chip replaces the selection.
  void selectTeamA(TeamSummary team) {
    if (selectedTeamAId.value == team.id) {
      clearTeamASelection();
      return;
    }
    selectedTeamAId.value = team.id;
    teamAController.text = team.name;
  }

  void clearTeamASelection() {
    selectedTeamAId.value = null;
    teamAController.clear();
  }

  void selectTeamB(TeamSummary team) {
    if (selectedTeamBId.value == team.id) {
      clearTeamBSelection();
      return;
    }
    selectedTeamBId.value = team.id;
    teamBController.text = team.name;
  }

  void clearTeamBSelection() {
    selectedTeamBId.value = null;
    teamBController.clear();
  }

  Future<void> createMatch() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final teamAName = teamAController.text.trim();
    final teamBName = teamBController.text.trim();
    final teamAId = selectedTeamAId.value;
    final teamBId = selectedTeamBId.value;

    // Mirrors the server's own TEAM_NAMES_MUST_DIFFER rule, which also
    // fires when both sides resolve to the same team id — checked
    // explicitly here rather than relying only on the name-equality check
    // below, since that check is on the *displayed* text, not the id.
    final sameTeamSelected = teamAId != null && teamAId == teamBId;
    if (sameTeamSelected ||
        teamAName.toLowerCase() == teamBName.toLowerCase()) {
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
            teamAId: teamAId,
            teamBId: teamBId,
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
