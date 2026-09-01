import 'dart:async';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/live_score_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_abandoned_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_result_info.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/public_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_undo_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/strike.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/run_rate.dart';
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

  /// Null in innings 1. See [ScoreBallRes.target] on the backend.
  final target = Rxn<int>();

  final currentRunRate = 0.0.obs;

  /// Null in innings 1, or once no legal deliveries remain.
  final requiredRunRate = Rxn<double>();

  /// The not-out pair's runs and legal balls faced together since the last
  /// wicket. See [PartnershipCheckpoint] for the resume/join-time limitation
  /// — a spectator opening the link mid-partnership has the same "since I
  /// connected" caveat a reconnecting scorer does.
  final partnershipRuns = 0.obs;
  final partnershipBalls = 0.obs;

  final _partnership = PartnershipCheckpoint();
  bool _partnershipInitialized = false;
  int _legalBalls = 0;

  /// The innings [_scoreSub] last saw. Unlike the scorer's console, this
  /// controller has no explicit "innings started" action to hook a reset
  /// into — a new innings is only ever noticed by its number changing on a
  /// live payload. Null until the first one arrives, which is deliberately
  /// not a change: nothing needs resetting before this controller has seen
  /// any innings at all.
  int? _observedInningsNumber;

  void _recomputeRates() {
    currentRunRate.value = computeCurrentRunRate(
      totalRuns: totalRuns.value,
      legalBalls: _legalBalls,
    );
    requiredRunRate.value = computeRequiredRunRate(
      target: target.value,
      totalRuns: totalRuns.value,
      legalBallsBowled: _legalBalls,
      totalOvers: matchInfo.value?.totalOvers ?? 0,
    );
    partnershipRuns.value = totalRuns.value - _partnership.runs;
    partnershipBalls.value = _legalBalls - _partnership.legalBalls;
  }

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

  /// True once the match has been abandoned — rain, a no-show. Mutually
  /// exclusive with [matchResult]: `abandonMatch` refuses a match that is
  /// already `completed`, and a genuine finish never sets `status` to
  /// `abandoned`, so the two can never both be true. Checked first in the UI
  /// for exactly that reason. Set two ways, mirroring [matchResult]: from
  /// `match.status` on the initial fetch, and from `match:abandoned` while
  /// connected live — the only way a spectator watching mid-match learns the
  /// match was just called off, since there is no REST ack the way the
  /// scorer's own console has.
  final isAbandoned = false.obs;

  StreamSubscription<Either<LiveScoreRes, CricketFailure>>? _scoreSub;
  StreamSubscription<Either<ScoreUndoRes, CricketFailure>>? _undoSub;
  StreamSubscription<Either<MatchCompleteRes, CricketFailure>>?
  _matchCompleteSub;
  StreamSubscription<Either<MatchAbandonedRes, CricketFailure>>?
  _matchAbandonedSub;

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
    isAbandoned.value = data.match.status == 'abandoned';
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

    target.value = innings.target;
    _legalBalls = legalBallsFromOvers(innings.overs);
    // A partnership already in progress at fetch time is seeded from the
    // server's own figure — see [PartnershipCheckpoint.startFromServerPartnership]
    // — rather than assumed to start here. The live socket join ack below
    // reports the same totals moments later and leaves this alone, since
    // [_partnershipInitialized] is now true.
    final partnershipRuns = innings.partnershipRuns;
    final partnershipBalls = innings.partnershipBalls;
    if (partnershipRuns != null && partnershipBalls != null) {
      _partnership.startFromServerPartnership(
        currentRuns: innings.totalRuns,
        currentLegalBalls: _legalBalls,
        partnershipRuns: partnershipRuns,
        partnershipLegalBalls: partnershipBalls,
      );
    } else {
      _partnership.start(runs: innings.totalRuns, legalBalls: _legalBalls);
    }
    _partnershipInitialized = true;
    _recomputeRates();
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

      // `absoluteBallSeq` is innings-scoped (resets to 1 each innings). A
      // controller that lived through the innings-1-to-2 transition still
      // has innings 1's high watermark, so every innings-2 ball would read
      // as older and [_applyStrike] would silently drop it — freezing the
      // striker/non-striker display on whoever was at the crease when
      // innings 1 ended. Detected here, since there is no explicit
      // "innings started" event to hook a reset into, unlike
      // [ScoreBallController.startInnings].
      if (_observedInningsNumber != null &&
          live.inningsNumber != _observedInningsNumber) {
        _lastAppliedSeq = 0;
        _partnershipInitialized = false;
      }
      _observedInningsNumber = live.inningsNumber;

      totalRuns.value = live.totalRuns;
      wickets.value = live.wickets;
      overs.value = live.overs;
      extrasTotal.value = live.extras?.total ?? extrasTotal.value;
      target.value = live.target;
      _legalBalls = legalBallsFromOvers(live.overs);

      final incomingSeq = live.lastBall?.absoluteBallSeq;
      final isNewBall = incomingSeq != null && incomingSeq > _lastAppliedSeq;

      if (!_partnershipInitialized) {
        // The initial REST fetch had no innings yet (a spectator who opened
        // the link before start-innings) — this join ack is the first state
        // this controller has ever seen. Seed from the server's own
        // partnership figure when it's there, same as [_applyInnings] above.
        final serverPartnershipRuns = live.partnershipRuns;
        final serverPartnershipBalls = live.partnershipBalls;
        if (serverPartnershipRuns != null && serverPartnershipBalls != null) {
          _partnership.startFromServerPartnership(
            currentRuns: live.totalRuns,
            currentLegalBalls: _legalBalls,
            partnershipRuns: serverPartnershipRuns,
            partnershipLegalBalls: serverPartnershipBalls,
          );
        } else {
          _partnership.start(runs: live.totalRuns, legalBalls: _legalBalls);
        }
        _partnershipInitialized = true;
      } else if (isNewBall && live.lastBall?.wicket != null) {
        _partnership.onWicket(
          totalRunsAfter: live.totalRuns,
          legalBallsAfter: _legalBalls,
        );
      }
      _recomputeRates();

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
      // Captured before [wickets] is overwritten below — the only way to
      // tell whether the undone ball was a dismissal, since `undoneBall`
      // carries no `wicket` field on this event (see docs/api.md's note on
      // `score:undo`). The scorer's own console doesn't need this: its REST
      // ack has the exact field.
      final wicketsBeforeUndo = wickets.value;

      totalRuns.value = undo.totalRuns;
      wickets.value = undo.wickets;
      overs.value = undo.overs;
      extrasTotal.value = undo.extras.total;
      target.value = undo.target;
      _legalBalls = legalBallsFromOvers(undo.overs);

      if (undo.wickets < wicketsBeforeUndo) _partnership.onUndoneWicket();
      _recomputeRates();

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

    // Same "only way this reaches a spectator" reasoning as the subscription
    // above, for the other way a match ends.
    _matchAbandonedSub = matchRepository
        .watchMatchAbandoned(matchId: matchId)
        .listen((event) {
          if (!event.isResult) return;
          isAbandoned.value = true;
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
    unawaited(_matchAbandonedSub?.cancel());
    super.onClose();
  }
}
