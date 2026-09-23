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
import 'package:cricket_scorer/features/scoring/presentation/controllers/select_team_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The overs quick-pick pills on the Match format card. `custom` means "the
/// field is free text, no pill is the source of truth" — set both when a
/// pill is tapped and when the field's own text drifts away from the
/// selected pill's value (see [_handleOversTextChanged]).
enum OversPreset { custom, five, t20, odi }

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

  /// Non-null exactly while side A's field holds a selected, existing
  /// team's own name untouched — see [_handleTeamATextChanged]. Null means
  /// free-text mode: submitting creates a brand-new team from whatever name
  /// is typed, today's original behavior.
  final selectedTeamAId = Rxn<String>();
  final selectedTeamBId = Rxn<String>();

  final selectedOversPreset = OversPreset.five.obs;
  static const Map<OversPreset, String> _oversPresetValues = {
    OversPreset.five: '5',
    OversPreset.t20: '20',
    OversPreset.odi: '50',
  };

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
    oversController.text = _oversPresetValues[OversPreset.five]!;
    oversController.addListener(_handleOversTextChanged);
  }

  /// The selected team's own logo — `null` in free-text mode, or when the
  /// selected team never had one uploaded. Purely presentational (the Teams
  /// banner's avatar); [createMatch] never reads these.
  String? selectedTeamALogoUrl;
  String? selectedTeamBLogoUrl;

  /// The name selection last set, so the listeners below can tell a
  /// programmatic `.text = team.name` assignment (matches, no-op) apart from
  /// the scorer editing over it or picking a different suggestion (doesn't
  /// match, clears the selection). Unlike the old chip picker, search
  /// results are ephemeral — nothing keeps a full team list around to look
  /// the name back up by id — so the name is captured at selection time
  /// instead.
  String? _selectedTeamAName;
  String? _selectedTeamBName;

  void _handleTeamATextChanged() {
    if (selectedTeamAId.value == null) return;
    if (teamAController.text != _selectedTeamAName) {
      selectedTeamAId.value = null;
      _selectedTeamAName = null;
      selectedTeamALogoUrl = null;
    }
  }

  void _handleTeamBTextChanged() {
    if (selectedTeamBId.value == null) return;
    if (teamBController.text != _selectedTeamBName) {
      selectedTeamBId.value = null;
      _selectedTeamBName = null;
      selectedTeamBLogoUrl = null;
    }
  }

  void selectTeamA(TeamSummary team) {
    selectedTeamAId.value = team.id;
    _selectedTeamAName = team.name;
    selectedTeamALogoUrl = team.logoUrl;
    teamAController.value = TextEditingValue(
      text: team.name,
      selection: TextSelection.collapsed(offset: team.name.length),
    );
  }

  void selectTeamB(TeamSummary team) {
    selectedTeamBId.value = team.id;
    _selectedTeamBName = team.name;
    selectedTeamBLogoUrl = team.logoUrl;
    teamBController.value = TextEditingValue(
      text: team.name,
      selection: TextSelection.collapsed(offset: team.name.length),
    );
  }

  /// Free-text mode — the picker screen returned a typed name with no
  /// matching team, so submitting will create a brand-new team from it,
  /// exactly like leaving the old inline field on free text did.
  void setTeamAFreeText(String name) {
    selectedTeamAId.value = null;
    _selectedTeamAName = null;
    selectedTeamALogoUrl = null;
    teamAController.text = name;
  }

  void setTeamBFreeText(String name) {
    selectedTeamBId.value = null;
    _selectedTeamBName = null;
    selectedTeamBLogoUrl = null;
    teamBController.text = name;
  }

  /// Pushes [AppRoutes.selectTeam] and applies whatever comes back — an
  /// existing team (`is TeamSummary`) via [selectTeamA], or a confirmed new
  /// name (`is String`) via [setTeamAFreeText]. `null` means the scorer
  /// backed out without picking anything, so the field is left untouched.
  Future<void> onTapTeamA() async {
    final result = await Get.toNamed<dynamic>(
      AppRoutes.selectTeam,
      arguments: SelectTeamArgs(
        title: TranslationKeys.selectTeamATitle.tr,
        initialQuery: teamAController.text,
      ),
    );
    if (result is TeamSummary) {
      selectTeamA(result);
    } else if (result is String && result.trim().isNotEmpty) {
      setTeamAFreeText(result.trim());
    }
  }

  Future<void> onTapTeamB() async {
    final result = await Get.toNamed<dynamic>(
      AppRoutes.selectTeam,
      arguments: SelectTeamArgs(
        title: TranslationKeys.selectTeamBTitle.tr,
        initialQuery: teamBController.text,
      ),
    );
    if (result is TeamSummary) {
      selectTeamB(result);
    } else if (result is String && result.trim().isNotEmpty) {
      setTeamBFreeText(result.trim());
    }
  }

  /// Trades everything about side A and side B — name, selection and logo.
  /// The id/name/logo are set *before* the controller text, so the
  /// text-changed listeners above (which clear a selection the moment the
  /// field's text stops matching it) see the freshly swapped text already
  /// matching the freshly swapped name, and leave it alone.
  void swapTeams() {
    final aText = teamAController.text;
    final bText = teamBController.text;
    final aId = selectedTeamAId.value;
    final bId = selectedTeamBId.value;
    final aName = _selectedTeamAName;
    final bName = _selectedTeamBName;
    final aLogo = selectedTeamALogoUrl;
    final bLogo = selectedTeamBLogoUrl;

    selectedTeamAId.value = bId;
    _selectedTeamAName = bName;
    selectedTeamALogoUrl = bLogo;
    selectedTeamBId.value = aId;
    _selectedTeamBName = aName;
    selectedTeamBLogoUrl = aLogo;

    teamAController.text = bText;
    teamBController.text = aText;
  }

  void selectOversPreset(OversPreset preset) {
    selectedOversPreset.value = preset;
    final value = _oversPresetValues[preset];
    if (value != null) oversController.text = value;
  }

  void _handleOversTextChanged() {
    final current = selectedOversPreset.value;
    if (current == OversPreset.custom) return;
    if (oversController.text != _oversPresetValues[current]) {
      selectedOversPreset.value = OversPreset.custom;
    }
  }

  Future<void> createMatch() async {
    // Team A/B no longer live inside the Form — they're picked by
    // navigating to SelectTeamScreen rather than typed into a FormField —
    // so they're validated explicitly here with the same [validateTeamName]
    // the old inline fields used, instead of via formKey.currentState.
    // Overs is still a real FormField, so this still gates on it.
    if (!formKey.currentState!.validate()) {
      return;
    }
    final teamAFieldError = validateTeamName(teamAController.text);
    final teamBFieldError = validateTeamName(teamBController.text);
    if (teamAFieldError != null || teamBFieldError != null) {
      CricketSnackbar.showAlertMessage(teamAFieldError ?? teamBFieldError!);
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
