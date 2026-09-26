import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/squad_rules.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/save_squad.dart';
import 'package:get/get.dart';

/// Drives `SquadScreen`: one [SquadDraft] per side, edited through
/// [SquadRules]-style methods on the draft, saved one side at a time.
///
/// Optional throughout — [skip] goes straight to scoring without touching the
/// server, and a failed save never blocks the scorer: the draft stays on
/// screen and they can retry or skip.
class SquadController extends GetxController {
  final CreateMatchRes match;
  final GetTeamProfileUseCase getTeamProfileUseCase;
  final SaveSquadUseCase saveSquadUseCase;

  /// Both default to the real thing; injectable so the controller can be
  /// tested without a `GetMaterialApp` to host a snackbar or a route.
  final void Function(String message) showError;
  final void Function(CreateMatchRes match) openScoring;

  SquadController({
    required this.match,
    required this.getTeamProfileUseCase,
    required this.saveSquadUseCase,
    void Function(String message)? showError,
    void Function(CreateMatchRes match)? openScoring,
  }) : showError = showError ?? CricketSnackbar.showAlertMessage,
       openScoring =
           openScoring ??
           ((match) =>
               Get.offNamed<dynamic>(AppRoutes.scoreBall, arguments: match));

  static const String sideA = 'teamA';
  static const String sideB = 'teamB';

  final side = sideA.obs;
  final teamA = SquadDraft.empty().obs;
  final teamB = SquadDraft.empty().obs;
  final isLoading = false.obs;
  final isSaving = false.obs;

  final Set<String> _dirty = {};

  /// Bumped on every edit of a side. A save only clears that side's dirty
  /// flag if no edit landed while it was in flight — otherwise the edit made
  /// during a slow save would be reported saved and never sent.
  final Map<String, int> _revision = {sideA: 0, sideB: 0};

  /// Saves run one after another, so an older in-flight request can never
  /// land on the server after a newer one and roll the squad back.
  Future<void> _saveChain = Future<void>.value();

  Rx<SquadDraft> _draft(String forSide) => forSide == sideA ? teamA : teamB;

  SquadDraft get current => _draft(side.value).value;

  @override
  void onInit() {
    super.onInit();
    loadRosters();
  }

  /// Seeds each side from its team's existing roster — a returning team keeps
  /// its earlier players, a brand-new one has none. A failed fetch just leaves
  /// the side empty; the scorer can still type a squad by hand.
  Future<void> loadRosters() async {
    isLoading.value = true;
    try {
      teamA.value = await _seed(match.teamA.id);
      teamB.value = await _seed(match.teamB.id);
      // A prefilled side is the scorer's squad as it stands, so it counts as
      // unsaved: Save & continue must persist it even if they never touch it.
      if (teamA.value.rows.isNotEmpty) _dirty.add(sideA);
      if (teamB.value.rows.isNotEmpty) _dirty.add(sideB);
    } finally {
      isLoading.value = false;
    }
  }

  Future<SquadDraft> _seed(String teamId) async {
    final response = await getTeamProfileUseCase(
      params: GetTeamProfileParams(teamId: teamId),
    );
    final roster = response.isResult ? response.result.data?.roster : null;

    var draft = SquadDraft.empty();
    for (final player in roster ?? const <TeamRosterPlayer>[]) {
      draft = draft.addPlayer(
        player.playerName,
        role: squadRoles.contains(player.role) ? player.role : null,
        playerId: player.playerId,
      );
    }
    return draft;
  }

  void _edit(SquadDraft Function(SquadDraft draft) change) {
    final target = _draft(side.value);
    target.value = change(target.value);
    _dirty.add(side.value);
    _revision[side.value] = _revision[side.value]! + 1;
  }

  void addPlayer(String name) => _edit((d) => d.addPlayer(name));
  void removePlayer(String name) => _edit((d) => d.removePlayer(name));
  void setRole(String name, String role) => _edit((d) => d.setRole(name, role));
  void toggleCaptain(String name) => _edit((d) => d.setCaptain(name));
  void toggleViceCaptain(String name) => _edit((d) => d.setViceCaptain(name));
  void toggleKeeper(String name) => _edit((d) => d.setKeeper(name));

  /// Saves [forSide] if it has unsaved edits. Returns false only on a server
  /// failure, having reported it; an untouched side counts as saved.
  Future<bool> _saveSide(String forSide, {required bool report}) {
    final run = _saveChain.then((_) => _send(forSide, report: report));
    _saveChain = run.then((_) {}, onError: (_) {});
    return run;
  }

  Future<bool> _send(String forSide, {required bool report}) async {
    if (!_dirty.contains(forSide)) return true;

    final sentRevision = _revision[forSide];
    final response = await saveSquadUseCase(
      params: SaveSquadParams(
        matchId: match.matchId,
        req: _draft(forSide).value.toRequest(forSide),
      ),
    );
    if (response.isResult) {
      if (_revision[forSide] == sentRevision) _dirty.remove(forSide);
      return true;
    }
    if (report) showError(response.fallback.message);
    return false;
  }

  /// Switching away from an edited side saves it first, quietly — a failure
  /// keeps the draft (still dirty) for the explicit save later.
  Future<void> selectSide(String next) async {
    if (next == side.value) return;
    final leaving = side.value;
    side.value = next;
    await _saveSide(leaving, report: false);
  }

  Future<void> saveAndContinue() async {
    if (isSaving.value) return;
    isSaving.value = true;
    try {
      for (final forSide in const [sideA, sideB]) {
        if (!await _saveSide(forSide, report: true)) return;
      }
    } finally {
      isSaving.value = false;
    }
    openScoring(match);
  }

  void skip() => openScoring(match);
}
