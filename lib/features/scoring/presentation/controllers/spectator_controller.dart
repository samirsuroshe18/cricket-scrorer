import 'dart:async';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/live_score_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_result_info.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/public_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_undo_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/strike.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_public_match.dart';
import 'package:get/get.dart';

/// Read-only by construction, not by discipline: this controller has no
/// method that sends a score-ball, select-bowler, start-innings or undo-ball
/// request, because [SpectatorBinding] never gives it a usecase for any of
/// them. Every field here is written from a server payload, mirroring the
/// rule [ScoreBallController.strike] documents for the scorer's own console —
/// nothing here is ever computed from a tap, because there is no tap.
class SpectatorController extends GetxController {
  final GetPublicMatchUseCase getPublicMatchUseCase;
  final MatchRepository matchRepository;

  SpectatorController({
    required this.getPublicMatchUseCase,
    required this.matchRepository,
  });

  late final String _code;

  final isLoading = true.obs;

  /// Set on a failed initial fetch — an unknown code, a network failure, or a
  /// malformed link. Null once the fixture has loaded successfully; a later
  /// socket hiccup does NOT set this, it only shows a snackbar, so the score
  /// already on screen is never blanked by a reconnect.
  final loadError = Rxn<String>();

  final matchInfo = Rxn<PublicMatchInfo>();

  final totalRuns = 0.obs;
  final wickets = 0.obs;
  final overs = '0.0'.obs;
  final extrasTotal = 0.obs;

  /// Who is on strike. Server-computed and server-reported only, exactly as
  /// on the scorer's console — see [Strike]'s own doc comment.
  final strike = Rxn<Strike>();

  /// Best-known bowler name. **Known to go stale after the first over**:
  /// neither `score:update` nor `over:complete` carries the incoming bowler,
  /// and `select-bowler` broadcasts nothing at all — see docs/api.md. A
  /// spectator connected continuously through an over change keeps the
  /// previous over's name until this screen is reopened. Flagged rather than
  /// silently accepted; closing it is a backend contract change, out of
  /// scope here.
  final currentBowler = Rxn<String>();

  bool get hasInningsStarted => strike.value?.strikerName != null;

  /// Null until the match has ended. Set two ways: from `match.result` on the
  /// initial fetch (a spectator opening the link after the match is already
  /// over), and from `match:complete` while connected live. The two never
  /// race in a way that matters — the live event only ever fires after the
  /// state it describes is already true, so whichever sets this first is
  /// already correct.
  ///
  /// Deliberately not gated on [hasInningsStarted]: that flag reads the
  /// striker, which the server only nulls on the wicket-ending case — an
  /// overs-complete or target-achieved ending dismisses nobody, so the pair
  /// from the finished innings is still sitting there non-null. Checking
  /// this instead is what makes the completed state show for all three
  /// endings instead of just one.
  final matchResult = Rxn<MatchResultInfo>();

  StreamSubscription<Either<LiveScoreRes, CricketFailure>>? _scoreSub;
  StreamSubscription<Either<ScoreUndoRes, CricketFailure>>? _undoSub;
  StreamSubscription<Either<MatchCompleteRes, CricketFailure>>?
  _matchCompleteSub;

  /// Same guard, same reason, as `ScoreBallController._lastAppliedSeq`: strike
  /// arrives from more than one source — the join ack, `score:update`,
  /// `score:undo` — and a payload for an older delivery must never overwrite
  /// a newer one. Rewound in [_applyUndo] for the identical reason it is
  /// rewound there: the restored pair belongs to a lower sequence than the
  /// ball that was just removed.
  int _lastAppliedSeq = 0;

  @override
  void onInit() {
    super.onInit();

    final code = Get.parameters['code']?.trim();
    if (code == null || code.isEmpty) {
      loadError.value = TranslationKeys.invalidShareLink.tr;
      isLoading.value = false;
      return;
    }

    _code = code;
    unawaited(_load());
  }

  Future<void> retry() => _load();

  Future<void> _load() async {
    isLoading.value = true;
    loadError.value = null;

    final response = await getPublicMatchUseCase(
      params: GetPublicMatchParams(code: _code),
    );

    final data = response.isResult ? response.result.data : null;

    // A 200 with no body would be a server bug rather than a user-facing
    // case, but treating it as the same failure state as a real error is
    // the only safe choice — the alternative is a screen with a spinner and
    // no fixture, no error, and no retry.
    if (!response.isResult || data == null) {
      loadError.value = response.isResult
          ? TranslationKeys.somethingWentWrong.tr
          : response.fallback.message;
      isLoading.value = false;
      return;
    }

    matchInfo.value = data.match;
    matchResult.value = data.match.result;
    _applyInnings(data.innings);
    isLoading.value = false;

    unawaited(_subscribeToLiveUpdates(data.match.matchId));
  }

  void _applyInnings(PublicInningsState? innings) {
    if (innings == null) return;
    totalRuns.value = innings.totalRuns;
    wickets.value = innings.wickets;
    overs.value = innings.overs;
    extrasTotal.value = innings.extras.total;
    strike.value = innings.strike;
    currentBowler.value = innings.bowler?.currentBowlerName;
  }

  /// Joins the room by `matchId`, not by [_code]. The REST fetch above is
  /// what resolves a code to a match and is where a bad code surfaces as a
  /// real 404 — see the "resolve over REST first" guidance in docs/api.md.
  /// Joining by code here too would just be a second, worse way to fail: the
  /// socket answers an unresolvable code with silence, not an error.
  Future<void> _subscribeToLiveUpdates(String matchId) async {
    _scoreSub = matchRepository.watchScoreUpdates(matchId: matchId).listen((
      event,
    ) {
      if (!event.isResult) {
        CricketSnackbar.showErrorMessage(event.fallback.message);
        return;
      }

      final live = event.result;
      totalRuns.value = live.totalRuns;
      wickets.value = live.wickets;
      overs.value = live.overs;
      extrasTotal.value = live.extras?.total ?? extrasTotal.value;
      _applyStrike(live.strike, seq: live.lastBall?.absoluteBallSeq);

      // Only present on `match:state`, never on `score:update` — see the
      // field doc on LiveScoreRes.bowler. Applying it unconditionally
      // when present costs nothing and is what actually catches a
      // reconnect's fresh join ack.
      if (live.bowler != null) {
        currentBowler.value = live.bowler!.currentBowlerName;
      }
    });

    // The scorer's own console does not subscribe to this: it gets a
    // complete state snapshot back from the `undo-ball` REST call directly.
    // A spectator has no such ack — this socket event is the ONLY way an
    // undo ever reaches this screen.
    _undoSub = matchRepository.watchScoreUndo(matchId: matchId).listen((event) {
      if (!event.isResult) return;

      final undo = event.result;
      totalRuns.value = undo.totalRuns;
      wickets.value = undo.wickets;
      overs.value = undo.overs;
      extrasTotal.value = undo.extras.total;

      final undoneSeq = undo.undoneBall?.absoluteBallSeq;
      if (undoneSeq != null) {
        // The restored pair belongs to the ball BEFORE the one removed —
        // a lower sequence than the watermark. Without this rewind the
        // score would roll back while the striker stayed exactly as the
        // undone ball left it. Identical fix to
        // ScoreBallController._applyUndo, same bug class.
        _lastAppliedSeq = undoneSeq - 1;
      }
      _applyStrike(undo.strike);

      if (undo.bowler != null) {
        currentBowler.value = undo.bowler!.currentBowlerName;
      }
    });

    // The only way a spectator connected continuously through match
    // completion learns about it — there is no REST ack to fall back on the
    // way the scorer's console has. A spectator who opens the link after the
    // match already ended never needs this: [matchResult] is already set
    // from the initial fetch by the time this subscription even starts.
    _matchCompleteSub = matchRepository
        .watchMatchComplete(matchId: matchId)
        .listen((event) {
          if (!event.isResult) return;
          matchResult.value = event.result.result;
        });
  }

  void _applyStrike(Strike? incoming, {int? seq}) {
    if (seq != null) {
      if (seq <= _lastAppliedSeq) return;
      _lastAppliedSeq = seq;
    }
    strike.value = incoming;
  }

  @override
  void onClose() {
    unawaited(_scoreSub?.cancel());
    unawaited(_undoSub?.cancel());
    unawaited(_matchCompleteSub?.cancel());
    super.onClose();
  }
}
