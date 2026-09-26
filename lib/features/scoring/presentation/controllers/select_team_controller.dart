import 'dart:async';

import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Navigation arguments for [AppRoutes.selectTeam] — `title` is the app bar
/// text ("Select Team A"/"Select Team B"), `initialQuery` seeds the search
/// field with whatever the create-match field already held. `excludeTeamId` /
/// `excludeName` describe the team already chosen for the *other* side, so it
/// can't be picked again — by id (an existing team) or by name (a typed one).
class SelectTeamArgs {
  final String title;
  final String initialQuery;
  final String? excludeTeamId;
  final String? excludeName;

  const SelectTeamArgs({
    required this.title,
    this.initialQuery = '',
    this.excludeTeamId,
    this.excludeName,
  });
}

/// Search-as-you-type over `GET /v1/team`, same debounce/stale-response-guard
/// shape as [CricketSearchController] (`features/search`) — a slow early
/// keystroke's response must never overwrite a faster later one's. Differs
/// from that controller in one way: a blank query still searches (the
/// backend returns the caller's most recent teams for `?q=`-less requests),
/// it never resets to an empty idle state, since browsing recent teams
/// before typing anything is the whole point of this screen.
class SelectTeamController extends GetxController {
  final GetMyTeamsUseCase getMyTeamsUseCase;
  final Duration debounceDuration;

  SelectTeamController({
    required this.getMyTeamsUseCase,
    this.debounceDuration = const Duration(milliseconds: 400),
  });

  final queryController = TextEditingController();
  final query = ''.obs;
  final owner = Rxn<TeamOwnerFilter>();
  final isLoading = false.obs;
  final hasSearched = false.obs;
  final results = <TeamSummary>[].obs;

  /// The app bar title — read once from [Get.arguments] here so the screen
  /// doesn't have to parse them independently.
  String title = '';

  String? _excludeTeamId;
  String _excludeName = '';

  Timer? _debounceTimer;

  /// Whether [team] is already the other side's team. Matches on id, and on
  /// name too so a team can't sneak in when the other side was typed as free
  /// text — the server's own `TEAM_NAMES_MUST_DIFFER` rule compares names.
  bool isOtherSide(TeamSummary team) =>
      (_excludeTeamId != null && team.id == _excludeTeamId) ||
      _sameName(team.name);

  /// Whether the typed query is the other side's name, so "use as new team"
  /// would just collide with it.
  bool get queryIsOtherSide => _sameName(query.value);

  bool _sameName(String name) =>
      _excludeName.isNotEmpty &&
      name.trim().toLowerCase() == _excludeName.toLowerCase();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    _excludeTeamId = args is SelectTeamArgs ? args.excludeTeamId : null;
    _excludeName = args is SelectTeamArgs
        ? (args.excludeName ?? '').trim()
        : '';
    final initialQuery = args is SelectTeamArgs ? args.initialQuery.trim() : '';
    title = args is SelectTeamArgs ? args.title : '';
    queryController.text = initialQuery;
    query.value = initialQuery;
    unawaited(_runSearch(initialQuery));
  }

  void onQueryChanged(String value) {
    query.value = value;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () => _runSearch(value.trim()));
  }

  /// Deselecting the active filter clears it back to "both" — same
  /// affordance the create-match toss decision and (previously) the inline
  /// owner-filter chips already use.
  void setOwnerFilter(TeamOwnerFilter filter) {
    owner.value = owner.value == filter ? null : filter;
    _debounceTimer?.cancel();
    unawaited(_runSearch(query.value.trim()));
  }

  Future<void> _runSearch(String trimmedQuery) async {
    isLoading.value = true;

    final response = await getMyTeamsUseCase(
      params: GetMyTeamsParams(
        search: trimmedQuery.isEmpty ? null : trimmedQuery,
        owner: owner.value,
      ),
    );

    // The query (or filter) may have moved on again while this request was
    // in flight — dropping a stale response here is what keeps a slow
    // request from clobbering a faster, more recent one.
    final isStale = query.value.trim() != trimmedQuery;
    isLoading.value = false;
    hasSearched.value = true;
    if (isStale) return;

    results.assignAll(
      response.isResult ? (response.result.data?.teams ?? const []) : const [],
    );
  }

  /// Pops back with the picked team — [CreateMatchController] reads this via
  /// `result is TeamSummary`, the same runtime-type-check pattern
  /// `choose_theme.dart`/`choose_language.dart` already use for their own
  /// `Get.back(result: ...)`.
  void selectTeam(TeamSummary team) {
    if (isOtherSide(team)) return;
    Get.back(result: team);
  }

  /// Pops back with the typed name as a plain [String] — the caller treats
  /// this as "create a new team from this name", exactly like leaving the
  /// old inline field on free text did.
  void useAsNewTeam() {
    final name = queryController.text.trim();
    if (name.isEmpty || _sameName(name)) return;
    Get.back(result: name);
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    queryController.dispose();
    super.onClose();
  }
}
