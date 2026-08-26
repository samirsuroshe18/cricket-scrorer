import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/select_bowler_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/start_innings_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/undo_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/live_score_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/over_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/strike.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/undo_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/wicket.dart';
import 'package:cricket_scorer/features/scoring/data/scoring_constants.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/run_rate.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/score_ball.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/select_bowler.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/start_innings.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/undo_ball.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/next_bowler_bottom_sheet.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/openers_bottom_sheet.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/wicket_bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class ScoreBallController extends GetxController {
  final ScoreBallUseCase scoreBallUseCase;
  final StartInningsUseCase startInningsUseCase;
  final SelectBowlerUseCase selectBowlerUseCase;
  final UndoBallUseCase undoBallUseCase;
  final MatchRepository matchRepository;

  ScoreBallController({
    required this.scoreBallUseCase,
    required this.startInningsUseCase,
    required this.selectBowlerUseCase,
    required this.undoBallUseCase,
    required this.matchRepository,
  });

  late final CreateMatchRes match;

  final totalRuns = 0.obs;
  final wickets = 0.obs;
  final overs = '0.0'.obs;
  final extrasTotal = 0.obs;
  final isScoring = false.obs;

  /// Null in innings 1 — nothing to chase yet. See [ScoreBallRes.target] on
  /// the backend for why this is repeated on every payload rather than cached
  /// from `start-innings` alone.
  final target = Rxn<int>();

  /// Runs per over so far this innings. Recomputed on every totals update;
  /// never itself a source of truth.
  final currentRunRate = 0.0.obs;

  /// Runs per over needed the rest of the way. Null in innings 1, or once
  /// there are no legal deliveries left to bowl.
  final requiredRunRate = Rxn<double>();

  /// The not-out pair's runs and legal balls faced together, since the last
  /// wicket. See [PartnershipCheckpoint] for the resume-time limitation.
  final partnershipRuns = 0.obs;
  final partnershipBalls = 0.obs;

  final _partnership = PartnershipCheckpoint();
  bool _partnershipInitialized = false;

  /// Legal deliveries bowled this innings. Mirrors [overs] as an integer for
  /// rate math — kept alongside rather than parsed from [overs] every time a
  /// payload already supplies it directly (`InningsTotals.legalBalls`).
  int _legalBalls = 0;

  /// Recomputes every rate/partnership observable from current state. Called
  /// after anything that can move [totalRuns], [_legalBalls] or [target] —
  /// cheap pure math, safe to call more often than strictly necessary.
  void _recomputeRates() {
    currentRunRate.value = computeCurrentRunRate(
      totalRuns: totalRuns.value,
      legalBalls: _legalBalls,
    );
    requiredRunRate.value = computeRequiredRunRate(
      target: target.value,
      totalRuns: totalRuns.value,
      legalBallsBowled: _legalBalls,
      totalOvers: match.totalOvers,
    );
    partnershipRuns.value = totalRuns.value - _partnership.runs;
    partnershipBalls.value = _legalBalls - _partnership.legalBalls;
  }

  /// True once the current innings has ended — the 10th wicket, the overs
  /// running out, or (innings 2) the target being chased down. The console
  /// locks: the server rejects further deliveries. Reset to `false` by
  /// [startInnings] on success, which is what lets the SAME openers sheet
  /// this flag currently blocks reopen for innings 2 — see [_promptIfNeeded].
  final isInningsComplete = false.obs;

  /// [isInningsComplete] narrowed to "and it was innings 2" — the match is
  /// over, not just the innings. Unlike [isInningsComplete] this is never
  /// reset; nothing on this screen continues past it. Set from either
  /// [ScoreBallRes.matchComplete] (primary) or the `match:complete` socket
  /// event (recovery), both of which trigger [_navigateToResult].
  final isMatchComplete = false.obs;

  /// Inline, button-level loading for the openers sheet. Deliberately not
  /// `CricketLoaderDialog`: that pushes a route over the sheet, and popping the
  /// dialog and the sheet back-to-back leaves the second pop with nothing to
  /// land on — the sheet stays up over a started innings.
  final isStartingInnings = false.obs;

  /// Button-level loading for the wicket sheet, same reasoning.
  final isScoringWicket = false.obs;

  /// Button-level loading for the next-bowler sheet, same reasoning again.
  final isSelectingBowler = false.obs;

  /// In flight for [undoLastBall]. Separate from [isScoring] so the two can
  /// disable each other without either claiming to be the other.
  final isUndoing = false.obs;

  /// Ball ids scored on this console, oldest first. [undoLastBall] takes the
  /// last one and pops it on success.
  ///
  /// A stack rather than one remembered id because undo is repeatable
  /// server-side, and the client can only chain if it knows the *previous*
  /// ball's id — `score:update` carries none, only the REST ack does. Keeping
  /// them all is what lets a scorer walk back three mis-taps instead of one.
  ///
  /// Session-local is enough today: nothing can resume a match, so no delivery
  /// on screen predates this console. The day a match list exists, the server's
  /// `canUndo` becomes the better source and this becomes a cache.
  final _scoredBallIds = <String>[].obs;

  /// The most recent dismissal, for the console to acknowledge. Server-reported
  /// like everything else here.
  final lastWicket = Rxn<Wicket>();

  /// Who is on strike, **only ever assigned from a server payload**. Rotation
  /// is computed server-side — odd runs run rotate strike, the end of an over
  /// rotates strike, and a single off the last ball does both and cancels out.
  /// None of that arithmetic belongs here: if the app ever disagreed with the
  /// server about who faced a ball, every downstream stat would be wrong and
  /// nothing on screen would reveal it.
  final strike = Rxn<Strike>();

  /// True once the last delivery completed an over. Kept distinct from
  /// [Strike.rotated] because it stays true when odd runs and the over end
  /// cancel — a new-bowler prompt needs it independently of the strike.
  final overComplete = false.obs;

  /// True while the server is owed a bowler for the over about to start. The
  /// console locks on this exactly as it locks on missing openers: without it
  /// the scorer taps a run and gets `BOWLER_NOT_SELECTED` for a reason the
  /// screen never showed them.
  ///
  /// Set only from server payloads — the score-ball ack, the `over:complete`
  /// event, or the `match:state` join ack. Never inferred from a local ball
  /// count.
  final needsBowler = false.obs;

  /// Whom the server will refuse for the next over, under Law 17.6. Read
  /// straight from `nextBowler.excludedBowlerName`; the picker greys this name
  /// rather than working out for itself who bowled last. Two sources of truth
  /// that can disagree would be worse than one that can be stale.
  final excludedBowler = Rxn<String>();

  /// Who is bowling right now, for the console to display. Null between overs.
  final currentBowler = Rxn<String>();

  /// Bowlers seen this innings, for the picker's chips. A **convenience list,
  /// not authority**: nothing but `start-innings` and `select-bowler` creates a
  /// Player on the bowling side, so there is no roster to fetch, and on a fresh
  /// app launch mid-match this holds at most the two names `match:state`
  /// supplies. That is exactly why the sheet always offers a name field.
  final bowlersSeen = <String>[].obs;

  /// Highest over number whose end has been acted on. The ack and the socket
  /// both report an over ending, and a replayed idempotency key can report an
  /// older one — the same ordering problem [_lastAppliedSeq] solves for strike,
  /// solved the same way rather than by trusting whichever arrived last.
  int _lastOverPrompted = 0;

  /// Guards against two blocking sheets racing to open. See [_promptIfNeeded].
  bool _prompting = false;

  /// Highest `absoluteBallSeq` whose strike has been applied. Strike arrives
  /// from two places — the REST ack and the socket — so a payload for an older
  /// delivery must not overwrite a newer one. An idempotent replay returns the
  /// strike as of *that* ball, which would otherwise visibly rewind the striker
  /// on screen. Ordering by a server-sent sequence is not local guessing.
  int _lastAppliedSeq = 0;

  bool get hasOpeners => strike.value?.strikerName != null;

  /// Everything the console can act on is gated on the same four facts, so a
  /// run button and the OUT button can never disagree about whether the match
  /// is scoreable. [needsBowler] belongs here for the same reason [hasOpeners]
  /// does: the server refuses the delivery either way, and a disabled button is
  /// a better explanation than a snackbar after the tap.
  bool get canScore =>
      !isScoring.value &&
      hasOpeners &&
      !isInningsComplete.value &&
      !needsBowler.value;

  /// Deliberately **not** gated on [isInningsComplete] or [needsBowler], unlike
  /// [canScore]. Undoing a mis-tapped tenth wicket, or the ball that ended an
  /// over you did not mean to end, is exactly what undo is for — those are the
  /// states a scorer most needs a way out of.
  bool get canUndo =>
      !isScoring.value && !isUndoing.value && _scoredBallIds.isNotEmpty;

  /// Set once the socket layer has reported *anything* — the join ack, a score
  /// update, or a connection failure. The openers prompt waits on this so a
  /// resumed match whose openers are already set doesn't flash the sheet before
  /// its `match:state` lands. A failure counts: the socket being down must not
  /// strand the scorer, since `start-innings` goes over REST regardless.
  final _serverStateArrived = false.obs;

  /// Armed delivery fault — [ExtraType.wide] / [ExtraType.noBall], or null for
  /// a legal delivery. Applied to the next run button tapped, then cleared.
  final selectedFault = Rxn<String>();

  /// Armed run attribution — [RunsFrom.bye] / [RunsFrom.legBye], or null for
  /// runs off the bat. Independent of [selectedFault] so "no-ball + byes" is
  /// reachable, which is the whole reason the contract splits the two.
  final selectedRunsFrom = Rxn<String>();

  void toggleFault(String fault) {
    selectedFault.value = selectedFault.value == fault ? null : fault;
    // Law 22: every run off a wide is a wide, so an attribution can't ride
    // along with one — the server rejects it. Clear it rather than let the
    // scorer arm a combination that will 400.
    if (selectedFault.value == ExtraType.wide) {
      selectedRunsFrom.value = null;
    }
  }

  void toggleRunsFrom(String value) {
    if (selectedFault.value == ExtraType.wide) return;
    selectedRunsFrom.value = selectedRunsFrom.value == value ? null : value;
  }

  bool get isRunsFromDisabled => selectedFault.value == ExtraType.wide;

  StreamSubscription<Either<LiveScoreRes, CricketFailure>>? _subscription;
  StreamSubscription<Either<OverCompleteRes, CricketFailure>>?
  _overCompleteSubscription;
  StreamSubscription<Either<MatchCompleteRes, CricketFailure>>?
  _matchCompleteSubscription;

  /// Guards [_navigateToResult] against firing twice — the REST ack and the
  /// socket event both report the same fact, and nothing stops both arriving.
  bool _navigatedToResult = false;

  static const _uuid = Uuid();

  @override
  void onInit() {
    super.onInit();
    match = Get.arguments as CreateMatchRes;

    _subscription = matchRepository
        .watchScoreUpdates(matchId: match.matchId)
        .listen((event) {
          if (event.isResult) {
            if (kDebugMode) {
              debugPrint(
                '[socket] received live score update: '
                '${event.result.totalRuns}/${event.result.wickets} '
                '(${event.result.overs} overs) '
                'striker=${event.result.strike?.strikerName}',
              );
            }
            totalRuns.value = event.result.totalRuns;
            wickets.value = event.result.wickets;
            overs.value = event.result.overs;
            extrasTotal.value = event.result.extras?.total ?? extrasTotal.value;
            target.value = event.result.target;
            _legalBalls = legalBallsFromOvers(event.result.overs);

            // Gate on the same sequence [_applyStrike] uses, captured before
            // it advances that watermark below: a wicket in a duplicate or
            // stale broadcast must not push a second checkpoint for a
            // dismissal already accounted for.
            final incomingSeq = event.result.lastBall?.absoluteBallSeq;
            final isNewBall = incomingSeq != null && incomingSeq > _lastAppliedSeq;

            if (!_partnershipInitialized) {
              // First payload this session — join ack or a fresh socket
              // connect. Nothing before this point is recoverable, so the
              // partnership starts counting from here. See
              // [PartnershipCheckpoint]'s doc comment.
              _partnership.start(
                runs: event.result.totalRuns,
                legalBalls: _legalBalls,
              );
              _partnershipInitialized = true;
            } else if (isNewBall && event.result.lastBall?.wicket != null) {
              _partnership.onWicket(
                totalRunsAfter: event.result.totalRuns,
                legalBallsAfter: _legalBalls,
              );
            }
            _recomputeRates();

            // `match:state` (the join ack) carries no `lastBall`: it is the
            // server's current state rather than a delivery, so it always
            // applies and never moves the guard. That is also what makes a
            // mid-match socket reconnect land correctly.
            _applyStrike(
              event.result.strike,
              seq: event.result.lastBall?.absoluteBallSeq,
            );

            // Also `match:state`-only. This is what makes resuming mid
            // over-break work: kill the app between overs, reopen it, and the
            // prompt is still there — recovered from server state, with nothing
            // remembered locally across the restart.
            _applyBowlerState(event.result);
          } else {
            CricketSnackbar.showErrorMessage(event.fallback.message);
          }
          _serverStateArrived.value = true;
        });

    // A recovery path, not the primary trigger — the REST ack already carries
    // `nextBowler`. This matters when that ack is lost on patchy signal, which
    // is the case the product exists for. `_lastOverPrompted` makes the two
    // sources idempotent with respect to each other.
    _overCompleteSubscription = matchRepository
        .watchOverComplete(matchId: match.matchId)
        .listen((event) {
          if (!event.isResult) return;
          final over = event.result;

          if (kDebugMode) {
            debugPrint(
              '[socket] over:complete over=${over.overNumber} '
              'bowler=${over.over.bowlerName} '
              'newBowlerRequired=${over.newBowlerRequired} '
              'inningsComplete=${over.inningsComplete}',
            );
          }

          overComplete.value = true;
          if (over.inningsComplete) isInningsComplete.value = true;

          _applyOverEnd(
            overNumber: over.overNumber,
            bowlerJustBowled: over.over.bowlerName,
            // The event carries no excluded bowler: the spectator room is
            // unauthenticated and has no picker to feed. The bowler who just
            // bowled *is* the one Law 17.6 excludes, so fall back to him.
            excludedName: over.over.bowlerName,
            newBowlerRequired: over.newBowlerRequired,
          );
        });

    // A recovery path, same reasoning as [_overCompleteSubscription]: the
    // REST ack already carries `matchComplete`, and this only matters when
    // that ack is lost on patchy signal.
    _matchCompleteSubscription = matchRepository
        .watchMatchComplete(matchId: match.matchId)
        .listen((event) {
          if (!event.isResult) return;
          if (kDebugMode) {
            debugPrint(
              '[socket] match:complete result=${event.result.result.winner}',
            );
          }
          _navigateToResult();
        });
  }

  /// The single place the console leaves this screen. Idempotent against
  /// [_navigateToResult] firing twice — from the REST ack and the socket both
  /// reporting the same completion — via [_navigatedToResult].
  void _navigateToResult() {
    if (_navigatedToResult) return;
    _navigatedToResult = true;
    isMatchComplete.value = true;
    unawaited(
      Get.offNamed<dynamic>(AppRoutes.matchResultPath(match.matchId)),
    );
  }

  @override
  void onReady() {
    super.onReady();
    ever<bool>(_serverStateArrived, (_) => unawaited(_promptIfNeeded()));
    ever<bool>(needsBowler, (_) => unawaited(_promptIfNeeded()));
    // Without this, nothing re-enters the loop when an innings ends via
    // overs_complete or a mid-over wicket — neither of those changes
    // `needsBowler` (no over boundary) or `_serverStateArrived` (already
    // true). `_score` sets [isInningsComplete] directly rather than through a
    // usecase call, so this listener is the only thing that turns that flag
    // flipping into the openers sheet reopening for innings 2.
    ever<bool>(isInningsComplete, (_) => unawaited(_promptIfNeeded()));
    unawaited(_promptIfNeeded());
  }

  /// The single place any blocking prompt is opened, and the single place they
  /// are ordered.
  ///
  /// Openers come first: an innings with nobody at the crease cannot also be
  /// owed a bowler, and only one sheet can be up at a time anyway. Because
  /// `start-innings` now names the opening bowler too, the two can never
  /// compete at the start of an innings — the bowler sheet only ever appears
  /// *between* overs.
  ///
  /// The loop is the point. A sheet closing can leave a *different* prompt
  /// outstanding — a wicket off the last ball of an over closes the batsman
  /// sheet with a bowler still owed — and a plain `Get.isBottomSheetOpen` guard
  /// would skip that second prompt and never retry, leaving the console locked
  /// with nothing on screen to unlock it. That is a hang, not a cosmetic bug.
  ///
  /// Everything here is driven by server state rather than by which screen the
  /// scorer arrived from, so resuming a half-set-up match prompts correctly.
  Future<void> _promptIfNeeded() async {
    if (_prompting) return;
    _prompting = true;

    try {
      while (true) {
        if (!_serverStateArrived.value) break;
        // Stop only once the MATCH has ended — not merely the current
        // innings. Blocking on [isInningsComplete] instead, as this used to,
        // is what left the console permanently locked after innings 1 with
        // no path to innings 2 at all.
        if (isMatchComplete.value) break;
        // Something else owns the screen (the wicket sheet). Whoever opened it
        // calls back here when it closes.
        if (Get.isBottomSheetOpen ?? false) break;

        // [isInningsComplete] is checked here too, not just [hasOpeners]: a
        // wicket-ending innings nulls the striker server-side (nobody is left
        // to replace the dismissed batsman), so `hasOpeners` alone happens to
        // catch that case — but an overs-complete or target-achieved ending
        // dismisses nobody, and the pair from the finished innings is still
        // sitting there non-null. Without this, the console stayed locked
        // forever on exactly those two endings, having correctly unlocked on
        // the third.
        if (!hasOpeners || isInningsComplete.value) {
          await OpenersBottomSheet.show(
            isSubmitting: isStartingInnings,
            onSubmit: (strikerName, nonStrikerName, bowlerName) => startInnings(
              strikerName: strikerName,
              nonStrikerName: nonStrikerName,
              bowlerName: bowlerName,
            ),
          );
        } else if (needsBowler.value) {
          await NextBowlerBottomSheet.show(
            excludedBowlerName: excludedBowler.value,
            knownBowlers: bowlersSeen.toList(),
            isSubmitting: isSelectingBowler,
            onSubmit: selectBowler,
            // The sheet is undismissable, so the console's own undo control is
            // unreachable behind it — a scorer who ended the over by accident
            // needs a way out from in here. Passed as a callback rather than a
            // bool because the sheet is built once and the stack can empty
            // while it is open.
            canUndo: () => canUndo,
            isUndoing: isUndoing,
            onUndo: undoLastBall,
          );
        } else {
          break;
        }
      }
    } finally {
      _prompting = false;
    }
  }

  /// Folds the bowler half of a `match:state` ack into console state.
  ///
  /// `score:update` does not carry this block, so a null here means "this
  /// payload has nothing to say about the bowler", not "there is no bowler".
  void _applyBowlerState(LiveScoreRes state) {
    final bowler = state.bowler;
    if (bowler == null) return;

    _rememberBowler(bowler.currentBowlerName);
    _rememberBowler(bowler.previousBowlerName);

    currentBowler.value = bowler.currentBowlerName;

    // An innings that has not started yet is the openers' problem, not the
    // bowler's — `start-innings` names the opening bowler in the same call.
    if (state.strike?.strikerName == null) return;

    // `excludedBowler` first: setting `needsBowler` fires the `ever` listener
    // that opens the picker synchronously (GetStream notifies listeners
    // inline, not on a microtask), so the picker would otherwise read the
    // exclusion before it was written and open unrestricted.
    excludedBowler.value = bowler.awaitingBowler
        ? bowler.previousBowlerName
        : null;
    needsBowler.value = bowler.awaitingBowler;
  }

  /// One place to record an over ending, shared by the REST ack and the socket
  /// event so the two cannot disagree.
  ///
  /// [overNumber] orders them: a duplicate event, or an idempotent replay
  /// reporting an older over, must not re-open a prompt the scorer has already
  /// answered.
  void _applyOverEnd({
    required int? overNumber,
    required String? bowlerJustBowled,
    required String? excludedName,
    required bool newBowlerRequired,
  }) {
    // Recorded before the ordering guard: a name is worth keeping for the
    // picker even from a payload that is otherwise stale.
    _rememberBowler(bowlerJustBowled);

    if (overNumber == null || overNumber <= _lastOverPrompted) return;
    _lastOverPrompted = overNumber;

    // The server cleared its pointer when the over ended; mirror that rather
    // than leaving the finished over's bowler on screen as if he were still on.
    currentBowler.value = null;

    if (!newBowlerRequired) return;

    // `excludedBowler` first — see the comment in `_applyBowlerState`, same
    // ordering hazard, same fix.
    excludedBowler.value = excludedName ?? bowlerJustBowled;
    needsBowler.value = true;
  }

  /// Case-insensitive, order-preserving. The picker shows these as chips; the
  /// scorer types anyone else.
  void _rememberBowler(String? name) {
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return;
    final lower = trimmed.toLowerCase();
    if (bowlersSeen.any((String n) => n.toLowerCase() == lower)) return;
    bowlersSeen.add(trimmed);
  }

  /// The single place [strike] is written. Drops any payload older than the
  /// last one applied; see [_lastAppliedSeq].
  void _applyStrike(Strike? incoming, {int? seq}) {
    if (seq != null) {
      if (seq <= _lastAppliedSeq) return;
      _lastAppliedSeq = seq;
    }
    strike.value = incoming;
  }

  /// Opens the innings with two named openers. Until this succeeds the server
  /// rejects every delivery with `INNINGS_NOT_STARTED`, so the console blocks
  /// scoring while [hasOpeners] is false.
  Future<bool> startInnings({
    required String strikerName,
    required String nonStrikerName,
    required String bowlerName,
  }) async {
    isStartingInnings.value = true;

    final response = await startInningsUseCase(
      params: StartInningsParams(
        matchId: match.matchId,
        startInningsReq: StartInningsReq(
          strikerName: strikerName,
          nonStrikerName: nonStrikerName,
          bowlerName: bowlerName,
        ),
      ),
    );

    isStartingInnings.value = false;

    if (!response.isResult) {
      CricketSnackbar.showAlertMessage(response.fallback.message);
      return false;
    }

    // No delivery behind this payload, so no sequence — it is the current
    // state and always applies.
    _applyStrike(response.result.data?.strike);

    // Over 1's bowler comes from here, which is why the console never prompts
    // for a bowler at the start of an innings.
    final openingBowler = response.result.data?.bowler?.bowlerName;
    currentBowler.value = openingBowler;
    _rememberBowler(openingBowler);
    needsBowler.value = false;
    excludedBowler.value = null;

    // Unlocks the console for innings 2: this call is re-reachable exactly
    // when the previous innings just ended, which is the one case
    // [isInningsComplete] is still true going in.
    isInningsComplete.value = false;

    // Resets the score display for innings 2. Without this, the totals stay
    // exactly what the previous innings ended on — score:update is the only
    // thing that ever writes them, and nothing re-emits one just because
    // start-innings was called, so the console would show the finished
    // innings' final score under a "Striker: ..." banner for a brand new one
    // until the first ball landed. "All zero" is not an assumption about this
    // response — it is the one thing InningsTotals is guaranteed to be here.
    final totals = response.result.data?.inningsTotals;
    totalRuns.value = totals?.totalRuns ?? 0;
    wickets.value = totals?.wickets ?? 0;
    overs.value = '0.0';
    extrasTotal.value = totals?.extras.total ?? 0;
    target.value = response.result.data?.target;
    _legalBalls = totals?.legalBalls ?? 0;

    // A fresh partnership for the new pair. Also marks the checkpoint
    // initialized so the socket listener's next arrival — which reports the
    // same fresh totals — does not re-run its own first-payload branch.
    _partnership.start(runs: totalRuns.value, legalBalls: _legalBalls);
    _partnershipInitialized = true;
    _recomputeRates();

    // Deliberately no success snackbar: `Get.showSnackbar` pushes a route, so
    // one here would sit on top of the sheet and swallow its `Get.back()`,
    // leaving the sheet up over an innings that had already started. The banner
    // filling in behind is the confirmation, and a better one.
    return true;
  }

  /// An ordinary delivery. Runs come from the grid; the armed fault and
  /// attribution ride along.
  Future<void> scoreRuns(int runs) => _score(runs: runs);

  /// A dismissal. The sheet supplies everything, including runs — for the five
  /// striker-only types that is always 0, which is why no path exists to send
  /// anything else. Returns true once the ball is accepted, so the sheet can
  /// close only on success.
  Future<bool> scoreWicket({
    required String wicketType,
    required String dismissedBatsman,
    required int runs,
    String? incomingBatsmanName,
  }) async {
    isScoringWicket.value = true;
    final scored = await _score(
      runs: runs,
      wicketType: wicketType,
      dismissedBatsman: dismissedBatsman,
      incomingBatsmanName: incomingBatsmanName,
    );
    isScoringWicket.value = false;
    return scored;
  }

  /// Names the bowler for the over about to start.
  ///
  /// The consecutive-over rule is the server's: this sends whatever the scorer
  /// picked and surfaces `BOWLER_CANNOT_BOWL_CONSECUTIVE_OVERS` verbatim if it
  /// comes back. The sheet greys the excluded name so that normally never
  /// happens — but the greying is an explanation, not the enforcement.
  Future<bool> selectBowler(String bowlerName) async {
    isSelectingBowler.value = true;

    final response = await selectBowlerUseCase(
      params: SelectBowlerParams(
        matchId: match.matchId,
        selectBowlerReq: SelectBowlerReq(bowlerName: bowlerName),
      ),
    );

    isSelectingBowler.value = false;

    if (!response.isResult) {
      CricketSnackbar.showAlertMessage(response.fallback.message);
      return false;
    }

    final data = response.result.data;
    currentBowler.value = data?.bowler.bowlerName;
    _rememberBowler(data?.bowler.bowlerName);
    _rememberBowler(data?.previousBowler?.bowlerName);

    needsBowler.value = false;
    excludedBowler.value = null;
    overComplete.value = false;

    // No success snackbar, for the same reason start-innings has none:
    // `Get.showSnackbar` pushes a route that would sit over the sheet and
    // swallow its `Get.back()`. The console unlocking behind is the better
    // confirmation.
    return true;
  }

  /// Opens the dismissal sheet. The console never builds a wicket request
  /// itself — the sheet collects every field and hands back a complete one.
  ///
  /// Awaited rather than fire-and-forget: a wicket off the last ball of an over
  /// leaves a bowler owed, and [_promptIfNeeded] skips while any sheet is open.
  /// Without this callback the console would sit locked behind a closed sheet.
  Future<void> promptForWicket() async {
    if (!hasOpeners) {
      CricketSnackbar.showAlertMessage(TranslationKeys.chooseOpeners.tr);
      return;
    }
    if (isInningsComplete.value) return;
    if (Get.isBottomSheetOpen ?? false) return;

    await WicketBottomSheet.show(
      strike: strike.value,
      extraType: selectedFault.value,
      // The next wicket is the last one, so nobody comes in. `wickets` lags
      // behind rather than ahead, so this can under-report but never
      // over-report — and under-reporting only means the sheet asks for a
      // name the server harmlessly ignores.
      isFinalWicket: wickets.value >= 9,
      isSubmitting: isScoringWicket,
      onSubmit: scoreWicket,
    );

    await _promptIfNeeded();
  }

  /// Removes the most recent delivery and re-renders from what the server
  /// sends back.
  ///
  /// **Nothing about the reversal is computed here.** The response is a
  /// complete state snapshot, and this method's whole job is to copy it over
  /// console state. Working out "a four was undone, so subtract four" would be
  /// wrong the first time a dismissal was involved — the pair at the crease
  /// after an undo is not derivable from the ball that was removed.
  ///
  /// Returns true once the server has accepted it, so the next-bowler sheet can
  /// close itself only on success.
  Future<bool> undoLastBall() async {
    if (isUndoing.value || isScoring.value) return false;
    if (_scoredBallIds.isEmpty) return false;

    final targetId = _scoredBallIds.last;
    isUndoing.value = true;

    final response = await undoBallUseCase(
      params: UndoBallParams(
        matchId: match.matchId,
        undoBallReq: UndoBallReq(ballEventId: targetId),
      ),
    );

    isUndoing.value = false;

    if (!response.isResult) {
      // A 400 means the server rejected *this id* — almost always
      // `BALL_NOT_LATEST`, which says a delivery landed that this console never
      // saw the ack for. The stack is fiction from that point on, so drop it
      // rather than leave a button that keeps failing on the same stale id.
      // Anything else (no connection, a 5xx) says nothing about the id, so the
      // stack survives and the scorer can simply try again.
      //
      // Branching on the status rather than on `BALL_NOT_LATEST` itself because
      // `CricketFailure` carries no error `code` — see the note in the repo's
      // CLAUDE.md about `code` being the machine-readable half. Widening that
      // model is worth doing, but not inside this slice.
      if (response.fallback.statusCode == 400) {
        _scoredBallIds.clear();
      }
      CricketSnackbar.showAlertMessage(response.fallback.message);
      return false;
    }

    final data = response.result.data;
    if (data == null) return false;

    if (kDebugMode) {
      debugPrint(
        'undoBall REST ack: alreadyUndone=${data.alreadyUndone} '
        'undone=${data.undone?.ballEventId} '
        'seq=${data.undone?.absoluteBallSeq} '
        'over=${data.undone?.overNumber} '
        'wicket=${data.undone?.wicket?.type} '
        'overReopened=${data.overReopened} '
        'overRemoved=${data.overRemoved} '
        'inningsReopened=${data.inningsReopened} '
        '-> ${data.inningsTotals.totalRuns}/${data.inningsTotals.wickets} '
        '(${data.overs}) striker=${data.strike?.strikerName} '
        'bowler=${data.bowler?.currentBowlerName}',
      );
    }

    // Popped whether or not the server actually removed anything: an
    // `alreadyUndone` answer means this id was gone before we asked, so it has
    // no business staying on the stack either.
    _scoredBallIds.remove(targetId);

    _applyUndo(data);
    return true;
  }

  /// Folds an undo response into console state.
  ///
  /// The two guard rewinds at the top are not bookkeeping — without them the
  /// console breaks in ways the score alone would not reveal.
  void _applyUndo(UndoBallRes state) {
    final undone = state.undone;

    if (undone != null) {
      // [_lastAppliedSeq] drops any strike payload not newer than the last one
      // applied. The restored pair belongs to the ball *before* the one just
      // removed — a lower sequence — so without this rewind the score would
      // roll back while the striker stayed exactly as the undone ball left it.
      _lastAppliedSeq = undone.absoluteBallSeq - 1;

      // [_lastOverPrompted] is the worse of the two. Undo the ball that ended
      // an over, score it again, and [_applyOverEnd] would treat that over as
      // already prompted and return early — leaving [needsBowler] false. The
      // console would stay *unlocked*, so the scorer taps a run and the server
      // refuses it with `BOWLER_NOT_SELECTED`, with no picker on screen and no
      // way to summon one. A refusal loop with no exit.
      _lastOverPrompted = undone.overNumber - 1;
    }

    totalRuns.value = state.inningsTotals.totalRuns;
    wickets.value = state.inningsTotals.wickets;
    extrasTotal.value = state.inningsTotals.extras.total;
    overs.value = state.overs;
    target.value = state.target;
    _legalBalls = state.inningsTotals.legalBalls;
    isInningsComplete.value = state.inningsComplete;

    // Exact, unlike the wickets-delta the spectator has to fall back on: this
    // response carries the undone ball's own wicket field directly.
    if (undone?.wicket != null) _partnership.onUndoneWicket();
    _recomputeRates();

    // No sequence: this is a state rather than a delivery, so it always applies
    // — and the rewind above is what makes the next real ball apply too.
    _applyStrike(state.strike);

    // Only meaningful if the ball removed was itself the dismissal being
    // acknowledged. An ordinary delivery leaves whatever wicket came before it
    // untouched, and this console has no way to recover that one.
    if (undone?.wicket != null) lastWicket.value = null;

    final bowler = state.bowler;
    if (bowler != null) {
      _rememberBowler(bowler.currentBowlerName);
      _rememberBowler(bowler.previousBowlerName);
      currentBowler.value = bowler.currentBowlerName;

      // Read from the payload rather than hardcoded to false, even though a
      // successful undo can never leave a bowler owed — the server refuses a
      // delivery without one, so the snapshot it restored from always had one.
      // Deriving it here would be the client deciding, which is the thing this
      // endpoint exists to avoid.
      //
      // `excludedBowler` first: see [_applyBowlerState] for the ordering.
      excludedBowler.value = bowler.awaitingBowler
          ? bowler.previousBowlerName
          : null;
      needsBowler.value = bowler.awaitingBowler;
      overComplete.value = bowler.awaitingBowler;
    }

    // The undone ball's modifiers are long gone; make sure the next tap starts
    // from a plain legal ball off the bat rather than from whatever was armed.
    selectedFault.value = null;
    selectedRunsFrom.value = null;
  }

  /// The single path to the server for any delivery. Wickets and ordinary balls
  /// share one idempotency key, one strike apply and one modifier clear, so the
  /// two cannot drift apart.
  Future<bool> _score({
    required int runs,
    String? wicketType,
    String? dismissedBatsman,
    String? incomingBatsmanName,
  }) async {
    if (isScoring.value) return false;
    if (!hasOpeners) {
      CricketSnackbar.showAlertMessage(TranslationKeys.chooseOpeners.tr);
      return false;
    }
    if (isInningsComplete.value) {
      CricketSnackbar.showAlertMessage(TranslationKeys.allOut.tr);
      return false;
    }
    isScoring.value = true;

    final fault = selectedFault.value;
    final runsFrom = fault == ExtraType.wide ? null : selectedRunsFrom.value;

    final response = await scoreBallUseCase(
      params: ScoreBallParams(
        matchId: match.matchId,
        scoreBallReq: ScoreBallReq(
          runs: runs,
          extraType: fault,
          runsFrom: runsFrom,
          wicketType: wicketType,
          dismissedBatsman: wicketType == null ? null : dismissedBatsman,
          incomingBatsmanName: incomingBatsmanName,
          idempotencyKey: _uuid.v4(),
        ),
      ),
    );

    isScoring.value = false;

    if (!response.isResult) {
      CricketSnackbar.showAlertMessage(response.fallback.message);
      return false;
    }

    final ball = response.result.data;

    if (kDebugMode) {
      debugPrint(
        'scoreBall REST ack: ${ball?.inningsTotals.totalRuns} runs, '
        'wkts=${ball?.inningsTotals.wickets} '
        'striker=${ball?.strike?.strikerName} '
        'rotated=${ball?.strike?.rotated} (${ball?.strike?.rotationReason}) '
        'overComplete=${ball?.overComplete} '
        'overBowler=${ball?.over?.bowlerName} '
        'excluded=${ball?.nextBowler?.excludedBowlerName} '
        'wicket=${ball?.wicket?.type} '
        'out=${ball?.wicket?.dismissedPlayerName} '
        'in=${ball?.wicket?.incomingBatsmanName} '
        'inningsComplete=${ball?.inningsComplete}',
      );
    }

    // Applied from the ack as well as the socket so the striker stays correct
    // when the socket lags or drops — the patchy-signal case this product
    // exists for. The sequence guard is what keeps the two sources ordered.
    if (ball != null) {
      // Pushed before anything is applied, so a ball that lands is undoable
      // even if something below throws.
      _scoredBallIds.add(ball.ballEventId);

      _applyStrike(ball.strike, seq: ball.absoluteBallSeq);
      overComplete.value = ball.overComplete;
      isInningsComplete.value = ball.inningsComplete;
      lastWicket.value = ball.wicket;

      // Primary trigger — see [_navigateToResult]. The over-completion
      // handling below still runs when a ball both ends an over and ends the
      // match; it is inert in that case, since the server never asks for a
      // bowler on the ball that ends the innings.
      if (ball.matchComplete) _navigateToResult();

      // `nextBowler` non-null IS the instruction to prompt — the server has
      // already folded in whether the innings ended on this ball, so there is
      // nothing to recombine here.
      if (ball.overComplete) {
        _applyOverEnd(
          overNumber: ball.over?.overNumber ?? ball.overNumber,
          bowlerJustBowled: ball.over?.bowlerName,
          excludedName: ball.nextBowler?.excludedBowlerName,
          newBowlerRequired: ball.nextBowler != null,
        );
      }
    }

    // Modifiers apply to a single delivery — clear them so the next tap
    // defaults back to a plain legal ball off the bat.
    selectedFault.value = null;
    selectedRunsFrom.value = null;
    return true;
  }

  @override
  void onClose() {
    unawaited(_subscription?.cancel());
    unawaited(_overCompleteSubscription?.cancel());
    unawaited(_matchCompleteSubscription?.cancel());
    super.onClose();
  }
}
