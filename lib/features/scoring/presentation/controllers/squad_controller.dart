import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/save_playing_xi_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/looked_up_user_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_squad_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invites_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/squad_rules.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/cancel_team_invite.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_match_squad.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_invites.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/invite_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/lookup_user_by_email.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/save_playing_xi.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/save_squad.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Arguments for opening the Squad screen from the scoring console, where a
/// save must return to it rather than continue on to scoring. (The Create
/// Match flow still passes a bare [CreateMatchRes].)
class SquadArgs {
  final CreateMatchRes match;
  final bool returnToScoring;

  const SquadArgs({required this.match, this.returnToScoring = false});
}

/// Drives `SquadScreen`: one [SquadDraft] per side — Playing XI, Bench and the
/// designations — plus the team's invitations, saved one side at a time.
///
/// Optional throughout — [skip] leaves without touching the server, and a
/// failed save never blocks the scorer: the draft stays on screen and they can
/// retry or skip.
///
/// Two save modes, chosen by the server (`inningsStarted`): before the innings
/// a side is saved with `PUT` (names, roles, designations, XI); after it, only
/// `PATCH …/playing-xi` (ids) is accepted, so that is all the screen offers.
class SquadController extends GetxController with WidgetsBindingObserver {
  final CreateMatchRes match;

  /// True when opened from the scoring console: leaving closes the screen
  /// instead of continuing to scoring.
  final bool returnToScoring;
  final GetTeamProfileUseCase getTeamProfileUseCase;
  final SaveSquadUseCase saveSquadUseCase;
  final GetMatchSquadUseCase getMatchSquadUseCase;
  final SavePlayingXiUseCase savePlayingXiUseCase;
  final GetTeamInvitesUseCase getTeamInvitesUseCase;
  final CancelTeamInviteUseCase cancelTeamInviteUseCase;
  final LookupUserByEmailUseCase lookupUserByEmailUseCase;
  final InviteTeamPlayerUseCase inviteTeamPlayerUseCase;

  /// Bumped when an invite accept/decline push arrives in the foreground (see
  /// `NotificationsController.inviteResponseTick`); null when unavailable.
  final RxInt? inviteResponseTick;

  /// All default to the real thing; injectable so the controller can be
  /// tested without a `GetMaterialApp` to host a snackbar or a route.
  final void Function(String message) showError;
  final void Function(CreateMatchRes match) openScoring;
  final void Function() close;

  SquadController({
    required this.match,
    this.returnToScoring = false,
    required this.getTeamProfileUseCase,
    required this.saveSquadUseCase,
    required this.getMatchSquadUseCase,
    required this.savePlayingXiUseCase,
    required this.getTeamInvitesUseCase,
    required this.cancelTeamInviteUseCase,
    required this.lookupUserByEmailUseCase,
    required this.inviteTeamPlayerUseCase,
    this.inviteResponseTick,
    void Function(String message)? showError,
    void Function(CreateMatchRes match)? openScoring,
    void Function()? close,
  }) : showError = showError ?? CricketSnackbar.showAlertMessage,
       openScoring =
           openScoring ??
           ((match) =>
               Get.offNamed<dynamic>(AppRoutes.scoreBall, arguments: match)),
       close = close ?? (() => Get.back<bool>(result: true));

  static const String sideA = 'teamA';
  static const String sideB = 'teamB';

  final side = sideA.obs;
  final teamA = SquadDraft.empty().obs;
  final teamB = SquadDraft.empty().obs;
  final isLoading = false.obs;
  final isSaving = false.obs;

  /// True once an innings exists: saves go through the playing-xi PATCH, and the
  /// screen hides everything that can only be saved with `PUT`.
  final midMatch = false.obs;

  final teamAInvites = <TeamInviteItemRes>[].obs;
  final teamBInvites = <TeamInviteItemRes>[].obs;

  final Set<String> _dirty = {};

  /// When each side was last saved with `PUT`, from the server (or, after this
  /// screen saves, from this device). An accepted invitee is new to the squad
  /// only if they answered after it.
  final Map<String, DateTime?> _savedAt = {sideA: null, sideB: null};

  /// Bumped on every edit of a side. A save only clears that side's dirty
  /// flag if no edit landed while it was in flight — otherwise the edit made
  /// during a slow save would be reported saved and never sent.
  final Map<String, int> _revision = {sideA: 0, sideB: 0};

  /// Saves run one after another, so an older in-flight request can never
  /// land on the server after a newer one and roll the squad back.
  Future<void> _saveChain = Future<void>.value();

  Rx<SquadDraft> _draft(String forSide) => forSide == sideA ? teamA : teamB;

  RxList<TeamInviteItemRes> _invites(String forSide) =>
      forSide == sideA ? teamAInvites : teamBInvites;

  String _teamId(String forSide) =>
      forSide == sideA ? match.teamA.id : match.teamB.id;

  SquadDraft get current => _draft(side.value).value;

  List<TeamInviteItemRes> get currentInvites => _invites(side.value);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    final tick = inviteResponseTick;
    if (tick != null) ever(tick, (_) => unawaited(refreshFromServer()));
    unawaited(loadRosters());
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// A push that arrived while backgrounded never reached the foreground hook,
  /// so the invites are re-read when the app returns.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(refreshFromServer());
  }

  /// Seeds each side from the saved squad when there is one, else from its
  /// team's roster — a returning team keeps its earlier players, a brand-new
  /// one has none. A failed fetch just leaves the side empty; the scorer can
  /// still type a squad by hand.
  Future<void> loadRosters() async {
    isLoading.value = true;
    try {
      final squad = await _fetchSquad();
      midMatch.value = squad?.inningsStarted ?? false;
      teamA.value = await _seed(sideA, squad?.teamA);
      teamB.value = await _seed(sideB, squad?.teamB);
      await _loadInvites();
      _appendAcceptedInvitees();
    } finally {
      isLoading.value = false;
    }
  }

  Future<MatchSquadRes?> _fetchSquad() async {
    final response = await getMatchSquadUseCase(
      params: GetMatchSquadParams(matchId: match.matchId),
    );
    return response.isResult ? response.result.data : null;
  }

  Future<SquadDraft> _seed(String forSide, SquadSideRes? saved) async {
    if (saved != null && saved.players.isNotEmpty) {
      _savedAt[forSide] = DateTime.tryParse(saved.savedAt ?? '');
      return _seedFromSaved(forSide, saved);
    }
    return _seedFromRoster(forSide);
  }

  SquadDraft _seedFromSaved(String forSide, SquadSideRes saved) {
    final rows = [
      for (final player in saved.players)
        SquadRow(
          playerId: player.playerId,
          name: player.name,
          role: squadRoles.contains(player.role) ? player.role : null,
        ),
    ];
    String? nameOf(String? id) {
      for (final player in saved.players) {
        if (player.playerId == id) return player.name;
      }
      return null;
    }

    final xiIds = saved.playingXI;
    var draft = SquadDraft.seeded(
      rows,
      xi: xiIds == null
          ? null
          : {
              for (final id in xiIds)
                if (nameOf(id) != null) nameOf(id)!,
            },
    );
    final captain = nameOf(saved.captainId);
    final viceCaptain = nameOf(saved.viceCaptainId);
    final keeper = nameOf(saved.keeperId);
    if (captain != null) draft = draft.setCaptain(captain);
    if (viceCaptain != null) draft = draft.setViceCaptain(viceCaptain);
    if (keeper != null) draft = draft.setKeeper(keeper);

    // A saved squad without an XI was given one by the first-11 rule just now;
    // saving is what makes that choice the scorer's. Not mid-match, though: a
    // match under way may have players who joined it while scoring and are not
    // in this squad, so a Save the scorer never meant would lock the pickers to
    // a guess that leaves them out. There only an explicit move saves.
    if (xiIds == null && !midMatch.value) _dirty.add(forSide);
    return draft;
  }

  Future<SquadDraft> _seedFromRoster(String forSide) async {
    final response = await getTeamProfileUseCase(
      params: GetTeamProfileParams(teamId: _teamId(forSide)),
    );
    final roster = response.isResult ? response.result.data?.roster : null;

    final rows = [
      for (final player in roster ?? const <TeamRosterPlayer>[])
        SquadRow(
          playerId: player.playerId,
          name: player.playerName,
          role: squadRoles.contains(player.role) ? player.role : null,
        ),
    ];
    // A prefilled side is the scorer's squad as it stands, so it counts as
    // unsaved: Save & continue must persist it even if they never touch it.
    // Not mid-match, for the reason given in [_seedFromSaved].
    if (rows.isNotEmpty && !midMatch.value) _dirty.add(forSide);
    return SquadDraft.seeded(rows);
  }

  Future<void> _loadInvites() async {
    for (final forSide in const [sideA, sideB]) {
      final response = await getTeamInvitesUseCase(
        params: GetTeamInvitesParams(teamId: _teamId(forSide)),
      );
      // A failed fetch keeps what was there: the list is informational.
      if (response.isResult) {
        _invites(forSide).assignAll(response.result.data?.invites ?? const []);
      }
    }
  }

  /// Puts every invitee who accepted since the side was last saved on the
  /// Bench. Repeated on every refresh and never touches anything already in the
  /// draft, so it cannot reset an edit or change the XI. Anyone accepted before
  /// the last save and absent from the draft was dropped on purpose and stays
  /// dropped.
  void _appendAcceptedInvitees() {
    for (final forSide in const [sideA, sideB]) {
      final savedAt = _savedAt[forSide];
      final target = _draft(forSide);
      for (final invite in _invites(forSide)) {
        if (invite.status != 'accepted') continue;
        final answeredAt = DateTime.tryParse(invite.respondedAt ?? '');
        final isNew =
            savedAt == null ||
            (answeredAt != null && answeredAt.isAfter(savedAt));
        if (!isNew) continue;
        final known = target.value.rows.any(
          (row) =>
              row.playerId == invite.player.playerId ||
              row.name.toLowerCase() == invite.player.playerName.toLowerCase(),
        );
        if (known) continue;
        target.value = target.value.addToBench(
          invite.player.playerName,
          playerId: invite.player.playerId,
        );
      }
    }
  }

  /// Re-reads the invitations (and so any newly accepted invitee). Named apart
  /// from `GetxController.refresh`, which this must not shadow.
  Future<void> refreshFromServer() async {
    await _loadInvites();
    _appendAcceptedInvitees();
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
  void moveToXi(String name) => _edit((d) => d.moveToXi(name));
  void moveToBench(String name) => _edit((d) => d.moveToBench(name));

  Future<(LookedUpUserRes?, String?)> lookupUserByEmail(String email) async {
    final response = await lookupUserByEmailUseCase(
      params: LookupUserParams(email: email.trim()),
    );
    if (!response.isResult) return (null, response.fallback.message);
    return (response.result.data, null);
  }

  /// Invites [userId] to the current side's team. Returns the server's own
  /// message on failure (shown inline by the sheet), null on success.
  Future<String?> inviteUser(String userId) async {
    final forSide = side.value;
    final response = await inviteTeamPlayerUseCase(
      params: InviteTeamPlayerParams(teamId: _teamId(forSide), userId: userId),
    );
    if (!response.isResult) return response.fallback.message;

    final data = response.result.data;
    // Already linked to that very account: there is no invite to wait on, they
    // are on the team now.
    if (data != null && data.status == 'accepted') {
      final target = _draft(forSide);
      target.value = target.value.addToBench(
        data.player.playerName,
        playerId: data.player.playerId,
      );
    }
    await refreshFromServer();
    return null;
  }

  /// Withdraws a waiting invite. A failure is reported and the row stays.
  Future<void> cancelInvite(TeamInviteItemRes item) async {
    final response = await cancelTeamInviteUseCase(
      params: CancelTeamInviteParams(
        teamId: _teamId(side.value),
        inviteId: item.inviteId,
      ),
    );
    if (!response.isResult) {
      showError(response.fallback.message);
      return;
    }
    await refreshFromServer();
  }

  /// Sends a declined invitee a fresh invite.
  Future<void> inviteAgain(TeamInviteItemRes item) async {
    final error = await inviteUser(item.invitee.userId);
    if (error != null) showError(error);
  }

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
    final draft = _draft(forSide).value;

    bool ok;
    String? message;
    if (midMatch.value) {
      final response = await savePlayingXiUseCase(
        params: SavePlayingXiParams(
          matchId: match.matchId,
          req: SavePlayingXiReq(
            side: forSide,
            playingXI: [
              for (final row in draft.xiRows)
                if (row.playerId != null) row.playerId!,
            ],
          ),
        ),
      );
      ok = response.isResult;
      message = ok ? null : response.fallback.message;
    } else {
      final response = await saveSquadUseCase(
        params: SaveSquadParams(
          matchId: match.matchId,
          req: draft.toRequest(forSide),
        ),
      );
      ok = response.isResult;
      message = ok ? null : response.fallback.message;
      if (ok) _savedAt[forSide] = DateTime.now().toUtc();
    }

    if (ok) {
      if (_revision[forSide] == sentRevision) _dirty.remove(forSide);
      return true;
    }
    if (report) showError(message ?? '');
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
    _leave();
  }

  void skip() => _leave();

  void _leave() => returnToScoring ? close() : openScoring(match);
}
