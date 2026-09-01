import 'dart:async';
import 'dart:convert';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/database/scoring_queue_database.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/offline_sync_service.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/select_bowler_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/start_innings_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/undo_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/bowler_state.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/live_score_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/over_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/strike.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/sync_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/undo_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/wicket.dart';
import 'package:cricket_scorer/features/scoring/data/scoring_constants.dart';
import 'package:cricket_scorer/features/scoring/domain/bowler_ref.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/ball_outcome_preview.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/pre_event_state.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/resolve_match_result.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/run_rate.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/abandon_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/score_ball.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/select_bowler.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/start_innings.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/undo_ball.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/next_bowler_bottom_sheet.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/openers_bottom_sheet.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/sync_blocked_bottom_sheet.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/sync_conflict_bottom_sheet.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/wicket_bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show ModalRoute;
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class ScoreBallController extends GetxController {
  final ScoreBallUseCase scoreBallUseCase;
  final StartInningsUseCase startInningsUseCase;
  final SelectBowlerUseCase selectBowlerUseCase;
  final UndoBallUseCase undoBallUseCase;
  final AbandonMatchUseCase abandonMatchUseCase;
  final MatchRepository matchRepository;
  final OfflineSyncService offlineSyncService;

  ScoreBallController({
    required this.scoreBallUseCase,
    required this.startInningsUseCase,
    required this.selectBowlerUseCase,
    required this.undoBallUseCase,
    required this.abandonMatchUseCase,
    required this.matchRepository,
    required this.offlineSyncService,
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
  ///
  /// [BowlerRef.id] may be null — a name recorded from an offline queue entry
  /// (never yet acknowledged by the server) has no real id to attach. Picking
  /// such a chip still sends a bare name, exactly as typing it would.
  final bowlersSeen = <BowlerRef>[].obs;

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

  /// `match.currentInnings` as last reported by the server (the join ack or
  /// `start-innings`'s own response) — the offline queue is innings-scoped,
  /// so every DAO call needs this. Defaults to 1, the same default the
  /// backend's own `Match.currentInnings` schema field has, and is corrected
  /// either by [_initializeOfflineQueueState] (a cold restart with a
  /// non-empty local queue) or the moment the first real payload arrives.
  int _currentInningsNumber = 1;

  /// `'teamA'` / `'teamB'`, whoever is batting the current innings — from
  /// `start-innings`'s own response, or computed (the other team from last
  /// innings) when that call had to happen offline. Nothing else remembers
  /// this: the live Rx totals get zeroed the moment the next innings starts,
  /// but the eventual match result (and, for an offline-started innings 2,
  /// its own target) both need to know who was batting when an innings
  /// ended, including one that ended entirely offline.
  String? _currentBattingTeam;

  /// Whether the local queue has anything at all. Backed by
  /// [OfflineSyncService.pendingCount] rather than a locally-mirrored id list
  /// on purpose: the service deletes rows out from under the controller the
  /// moment a flush lands, and a copy here would drift stale the instant that
  /// happens.
  bool get _hasQueuedBalls => offlineSyncService.pendingCount.value > 0;

  /// The provisional innings snapshot offline preview builds on top of.
  /// Null whenever nothing is queued right now — in that state the live Rx
  /// fields below are already correct on their own, seeded either by a real
  /// server payload or, after a cold app relaunch that happens to still be
  /// offline, by [OfflineSyncService.currentProvisionalState].
  PreEventState? _offlinePre;

  /// True while [strike]/[totalRuns]/etc reflect [_offlinePre]'s provisional
  /// preview rather than a real server ack. Deliberately never interacts
  /// with [_lastAppliedSeq] — a provisional ball has no server-assigned
  /// `absoluteBallSeq` — and any real ack, online or synced, hard-replaces
  /// every field unconditionally and clears this, never merges with it.
  final isProvisional = false.obs;

  bool get hasOpeners => strike.value?.strikerName != null;

  /// Everything the console can act on is gated on the same three facts, so a
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
  ///
  /// [OfflineSyncService.queuedBallCount] (a still-queued ball, undone
  /// locally) and [OfflineSyncService.historyCount] (an already-synced ball,
  /// undone via the local ledger — see [undoLastBall]) — never
  /// [_hasQueuedBalls]: a pending `undo` row is a correction already made,
  /// not something further to undo, and counting it here would leave this
  /// true forever once one is queued offline, however empty the ledger and
  /// queue of undoable balls actually are. Both counts are DB-backed rather
  /// than in-memory, so this survives a cold app relaunch, not just the
  /// current session.
  bool get canUndo =>
      !isScoring.value &&
      !isUndoing.value &&
      (offlineSyncService.historyCount.value > 0 ||
          offlineSyncService.queuedBallCount.value > 0);

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

    // Best-effort seed for [_currentBattingTeam] on a resumed session — the
    // one where `startInnings()` itself won't run again this session to set
    // it directly, since the innings is already open. Genuinely best-effort:
    // toss is commonly skipped entirely (see `TossLine`'s own comment), and
    // when it is, a resumed session simply has no source for this at all
    // until either a real `start-innings`/sync response supplies it, or the
    // match completes and the server's own result settles the question. This
    // mirrors this controller's other documented resume-time approximations
    // (e.g. the excluded-bowler note on [_applyPreEventStateAsCurrent]).
    final tossWinner = match.tossWinner;
    final tossDecision = match.tossDecision;
    if (tossWinner != null && tossDecision != null) {
      _currentBattingTeam = tossDecision == 'bat'
          ? tossWinner
          : (tossWinner == 'teamA' ? 'teamB' : 'teamA');
    }

    // Resolves [_currentInningsNumber] against the local queue before
    // [OfflineSyncService.watch] and [_seedProvisionalStateIfQueued] both key
    // off it — see [_initializeOfflineQueueState]'s own doc comment.
    unawaited(_initializeOfflineQueueState());

    _subscription = matchRepository
        .watchScoreUpdates(matchId: match.matchId)
        .listen((event) {
          if (event.isResult) {
            _currentInningsNumber = event.result.inningsNumber;

            // A queue is pending for this innings — this payload reflects
            // server state from BEFORE it, or another scorer's concurrent
            // write. Applying it here would visibly regress the provisional
            // display, then have the eventual sync flush jump it forward
            // again. Trust the provisional preview instead; the explicit
            // apply that follows a successful flush is what refreshes real
            // state once it actually exists.
            if (_offlinePre != null) {
              _serverStateArrived.value = true;
              return;
            }

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
            final isNewBall =
                incomingSeq != null && incomingSeq > _lastAppliedSeq;

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
            _applyBowlerState(
              bowler: event.result.bowler,
              strikerName: event.result.strike?.strikerName,
            );
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
            bowlerJustBowledId: over.over.bowlerId,
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
    // Home is never popped by anything else on the way here — reopening a
    // live match pushes this console with `Get.toNamed`, and creating one
    // pushes create-match then this console the same way — so it's still
    // alive underneath with the stale (pre-completion) list `onInit` fetched
    // once. Refresh it directly rather than relying on a pop to trigger a
    // refetch.
    if (Get.isRegistered<HomeController>()) {
      unawaited(Get.find<HomeController>().loadHistory());
    }
    // `Get.offNamedUntil` rather than `Get.offNamed`: the latter only
    // replaces this console, leaving whatever pushed it (create-match, for a
    // freshly created match) sitting underneath the result screen — so its
    // back button would land there instead of Home. Popping back to Home
    // first puts the result screen directly on top of it for every path in.
    // `arguments: match` is what lets `ResultController` resolve team names
    // and watch the right innings' queue offline, before any scorecard has
    // ever loaded — see that controller's own doc comment on `_match`.
    unawaited(
      Get.offNamedUntil<dynamic>(
        AppRoutes.matchResultPath(match.matchId),
        ModalRoute.withName(AppRoutes.home),
        arguments: match,
      ),
    );
  }

  final isAbandoning = false.obs;

  /// The console's own "call this match off" action — rain, a no-show,
  /// anything short of playing it out. Online-only on purpose: the offline
  /// queue has no representation for "abandon", so this is refused the same
  /// way any other network call the queue can't stand in for would be.
  /// Lands on the result screen exactly like a normal completion does,
  /// where [ResultScreen] renders the [AbandonedMatchBanner] variant once it
  /// sees a null `result`.
  Future<void> abandonMatch() async {
    isAbandoning.value = true;
    final response = await abandonMatchUseCase(params: match.matchId);
    isAbandoning.value = false;

    if (response.isResult) {
      _navigateToResult();
    } else {
      CricketSnackbar.showErrorMessage(response.fallback.message);
    }
  }

  /// Every `ever()` worker registered below, disposed explicitly in
  /// [onClose]. `ever()` is not tied to a GetxController's lifecycle the way
  /// a `StreamSubscription` field discipline makes obvious it should be —
  /// left uncaptured, a worker keeps its closure (and everything it
  /// closes over, including this whole controller) alive for as long as
  /// whatever `Rx` it listens to lives. Two of these listen on
  /// [OfflineSyncService.phase]/[OfflineSyncService.lastAppliedState] — a
  /// `fenix`-registered singleton that outlives every route — so without
  /// this, every match ever opened in a session would leave one more dead
  /// controller permanently wired to fire `_promptIfNeeded()`/
  /// [_reconcileFromSyncedState] on the next match's sync activity, from
  /// whatever screen the user has since navigated to.
  final List<Worker> _workers = [];

  @override
  void onReady() {
    super.onReady();
    _workers.add(
      ever<bool>(_serverStateArrived, (_) => unawaited(_promptIfNeeded())),
    );
    _workers.add(
      ever<bool>(needsBowler, (_) => unawaited(_promptIfNeeded())),
    );
    // Without this, nothing re-enters the loop when an innings ends via
    // overs_complete or a mid-over wicket — neither of those changes
    // `needsBowler` (no over boundary) or `_serverStateArrived` (already
    // true). `_score` sets [isInningsComplete] directly rather than through a
    // usecase call, so this listener is the only thing that turns that flag
    // flipping into the openers sheet reopening for innings 2.
    _workers.add(
      ever<bool>(isInningsComplete, (_) => unawaited(_promptIfNeeded())),
    );

    // A batch was refused whole. Routed through `_promptIfNeeded`'s own loop
    // (see its top-priority branch) rather than opened directly from here —
    // opening it here would check `Get.isBottomSheetOpen` independently and
    // could silently miss a conflict that lands while the wicket sheet (a
    // separate flow this listener knows nothing about) is already up. The
    // loop's own re-entry after that sheet closes is what catches it instead.
    _workers.add(
      ever<SyncPhase>(
        offlineSyncService.phase,
        (_) => unawaited(_promptIfNeeded()),
      ),
    );

    // A flush actually landed — reconcile the provisional preview back to
    // real server truth. See [_reconcileFromSyncedState].
    _workers.add(
      ever<SyncState?>(offlineSyncService.lastAppliedState, (state) {
        if (state != null) _reconcileFromSyncedState(state);
      }),
    );

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

        // Highest priority of all: a batch was refused whole, and nothing
        // else on this screen should proceed until the scorer has seen that.
        // See [SyncPhase.conflict]'s own doc comment for why this is never
        // auto-resolved.
        if (offlineSyncService.phase.value == SyncPhase.conflict) {
          final discard = await SyncConflictBottomSheet.show();
          if (discard != true) {
            // "Review later" — leave `phase` at conflict so the banner stays
            // visible and tappable, but stop here. Looping straight back
            // would reopen the exact same sheet immediately, since nothing
            // about the conflict has changed.
            break;
          }
          await offlineSyncService.discardQueueAndReload(
            matchId: match.matchId,
            inningsNumber: _currentInningsNumber,
          );
          _offlinePre = null;
          isProvisional.value = false;
          // The socket's `match:state` ack only ever fires once, on the
          // initial join — nothing else repaints this console until another
          // delivery happens to be broadcast. A discarded queue needs fresh
          // truth immediately, not "whenever the next ball lands", so pull it
          // directly rather than waiting on the socket.
          await _reloadFromServerTruth();
          continue;
        }

        // A queued delivery failed a genuine rule check offline (e.g. a
        // stale bowler exclusion) — [SyncPhase.blockedOnRule] will fail
        // identically on retry, so the only resolution is undoing back
        // through it. Same non-auto-resolving treatment as `conflict`
        // above, and for the same reason.
        if (offlineSyncService.phase.value == SyncPhase.blockedOnRule) {
          final undo = await SyncBlockedBottomSheet.show();
          if (undo != true) {
            break;
          }
          await undoBackToBlockedBall();
          continue;
        }

        // [isInningsComplete] is checked here too, not just [hasOpeners]: a
        // wicket-ending innings nulls the striker server-side (nobody is left
        // to replace the dismissed batsman), so `hasOpeners` alone happens to
        // catch that case — but an overs-complete or target-achieved ending
        // dismisses nobody, and the pair from the finished innings is still
        // sitting there non-null. Without this, the console stayed locked
        // forever on exactly those two endings, having correctly unlocked on
        // the third.
        if (!hasOpeners || isInningsComplete.value) {
          // [isInningsComplete] is exactly the innings-1-to-2 transition
          // case (a fresh match's first-ever openers prompt reaches this
          // branch via `!hasOpeners` instead, with nothing yet to summarize
          // or undo back into) — so it doubles as the signal for whether
          // there is a previous innings to show and an escape hatch to
          // offer. `totalRuns`/`wickets`/`overs` still hold innings 1's
          // final figures here: nothing resets them until this form actually
          // submits.
          final justFinishedInnings = isInningsComplete.value;
          await OpenersBottomSheet.show(
            isSubmitting: isStartingInnings,
            onSubmit: (strikerName, nonStrikerName, bowlerName) => startInnings(
              strikerName: strikerName,
              nonStrikerName: nonStrikerName,
              bowlerName: bowlerName,
            ),
            previousInningsRuns: justFinishedInnings ? totalRuns.value : null,
            previousInningsWickets: justFinishedInnings ? wickets.value : null,
            previousInningsOvers: justFinishedInnings ? overs.value : null,
            // Same reasoning as the next-bowler sheet's identical wiring
            // below: undismissable, so this is the only way out of a
            // mis-tapped final ball of innings 1 once the sheet is up.
            canUndo: () => canUndo,
            isUndoing: isUndoing,
            onUndo: undoLastBall,
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

  /// Folds the bowler half of a `match:state` ack (or an equivalent full
  /// state snapshot, such as [_reloadFromServerTruth]'s) into console state.
  ///
  /// `score:update` does not carry this block, so a null [bowler] means "this
  /// payload has nothing to say about the bowler", not "there is no bowler".
  void _applyBowlerState({
    required BowlerState? bowler,
    required String? strikerName,
  }) {
    if (bowler == null) return;

    _rememberBowler(bowler.currentBowlerId, bowler.currentBowlerName);
    _rememberBowler(bowler.previousBowlerId, bowler.previousBowlerName);

    currentBowler.value = bowler.currentBowlerName;

    // An innings that has not started yet is the openers' problem, not the
    // bowler's — `start-innings` names the opening bowler in the same call.
    if (strikerName == null) return;

    // `excludedBowler` first: setting `needsBowler` fires the `ever` listener
    // that opens the picker synchronously (GetStream notifies listeners
    // inline, not on a microtask), so the picker would otherwise read the
    // exclusion before it was written and open unrestricted.
    excludedBowler.value = bowler.awaitingBowler
        ? bowler.previousBowlerName
        : null;
    _setNeedsBowler(bowler.awaitingBowler);
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
    String? bowlerJustBowledId,
    required String? excludedName,
    required bool newBowlerRequired,
  }) {
    // Recorded before the ordering guard: a name is worth keeping for the
    // picker even from a payload that is otherwise stale.
    _rememberBowler(bowlerJustBowledId, bowlerJustBowled);

    if (overNumber == null || overNumber <= _lastOverPrompted) return;
    _lastOverPrompted = overNumber;

    // The server cleared its pointer when the over ended; mirror that rather
    // than leaving the finished over's bowler on screen as if he were still on.
    currentBowler.value = null;

    if (!newBowlerRequired) return;

    // `excludedBowler` first — see the comment in `_applyBowlerState`, same
    // ordering hazard, same fix.
    excludedBowler.value = excludedName ?? bowlerJustBowled;
    _setNeedsBowler(true);
  }

  /// Case-insensitive, order-preserving. The picker shows these as chips; the
  /// scorer types anyone else.
  ///
  /// [id] is nullable because some payloads that name a bowler don't carry
  /// one (an offline preview, or an over-complete event with only a name) —
  /// see [BowlerRef]. An existing name-only entry is upgraded in place the
  /// first time a real id shows up for it, never the reverse: a later payload
  /// with no id is never taken to mean the bowler stopped having one.
  void _rememberBowler(String? id, String? name) {
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return;

    final index = bowlersSeen.indexWhere((b) => b.sameName(trimmed));
    if (index == -1) {
      bowlersSeen.add(BowlerRef(id: id, name: trimmed));
      return;
    }

    if (id != null && bowlersSeen[index].id == null) {
      bowlersSeen[index] = BowlerRef(id: id, name: trimmed);
    }
  }

  /// The single place [strike] is written. Drops any payload older than the
  /// last one applied; see [_lastAppliedSeq].
  void _applyStrike(Strike? incoming, {int? seq}) {
    if (seq != null) {
      if (seq <= _lastAppliedSeq) return;
      _lastAppliedSeq = seq;
    }

    // _ModifierRow (Wide/No-ball/Bye/Leg-bye) is armable even while
    // [hasOpeners] is false, matching pre-redesign behaviour — see that
    // widget's own doc comment. An arm made in that window has no visible
    // consequence yet, and if it survived to the next tap once openers
    // finally arrived it would silently apply to a delivery the scorer
    // never meant to mark as anything but plain. Cleared exactly on this
    // null-name -> named transition — the moment openers actually become
    // known — not on every strike update, which would also wipe a
    // legitimately mid-innings arm between one ball and the next.
    final justGainedOpeners =
        strike.value?.strikerName == null && incoming?.strikerName != null;

    strike.value = incoming;

    if (justGainedOpeners) {
      selectedFault.value = null;
      selectedRunsFrom.value = null;
    }
  }

  /// The single place [needsBowler] is written. Same reasoning as
  /// [_applyStrike]'s identical clear: _ModifierRow is armable while this is
  /// true too (the console's other locked state), and an arm made during
  /// that wait must not silently ride along to the first delivery once a
  /// bowler is finally picked. Clears exactly on the true -> false
  /// transition, so a modifier armed mid-over (this already false
  /// throughout) is never touched.
  void _setNeedsBowler(bool value) {
    final wasNeeded = needsBowler.value;
    needsBowler.value = value;
    if (wasNeeded && !value) {
      selectedFault.value = null;
      selectedRunsFrom.value = null;
    }
  }

  // ---------------------------------------------------------------------
  // Offline queue: seeding, provisional preview, and reconciliation.
  //
  // The server remains the sole authority the instant it can be reached —
  // everything below is a best-effort preview shown only while nothing
  // better exists, and every real ack (online or synced) hard-replaces it
  // outright. See lib/features/scoring/domain/offline/ for the ported rules
  // this builds on.
  // ---------------------------------------------------------------------

  /// Called once from [onInit], before anything else touches the offline
  /// queue.
  ///
  /// The first [OfflineSyncService.watch] call below is deliberately
  /// synchronous — it runs before this method's first `await`, so it
  /// executes inline within [onInit] exactly as it always did. Callers rely
  /// on that: [OfflineSyncService.pendingCount]/`queuedBallCount` (and so
  /// `canUndo`) must be reactively wired up the instant the controller
  /// initializes, not one microtask later. Only if the async lookup then
  /// finds a *different* innings — the cold-restart case — is [watch]
  /// re-pointed, exactly as [_applyInningsStarted] already re-points it on
  /// every live innings transition.
  ///
  /// [_currentInningsNumber] itself still needs correcting before
  /// [_seedProvisionalStateIfQueued] reads it: a cold restart mid-innings-2
  /// with balls still queued would otherwise seed from innings 1's queue by
  /// the field's stale default — nothing else corrects it until the
  /// socket's first payload arrives, asynchronously, well after a seed
  /// would already have run.
  Future<void> _initializeOfflineQueueState() async {
    offlineSyncService.watch(
      matchId: match.matchId,
      inningsNumber: _currentInningsNumber,
    );

    final pendingInnings = await offlineSyncService
        .latestInningsWithPendingEvents(matchId: match.matchId);
    if (pendingInnings != null && pendingInnings != _currentInningsNumber) {
      _currentInningsNumber = pendingInnings;
      offlineSyncService.watch(
        matchId: match.matchId,
        inningsNumber: _currentInningsNumber,
      );
    }

    await _seedProvisionalStateIfQueued();
  }

  /// Called once from [_initializeOfflineQueueState]. A non-null result
  /// means the app was killed and relaunched while still offline with a
  /// non-empty queue — the only case nothing else supplies a seed for. An
  /// empty queue means the ordinary server payloads about to arrive are
  /// already enough, so this deliberately does nothing further in that case.
  Future<void> _seedProvisionalStateIfQueued() async {
    final pre = await offlineSyncService.currentProvisionalState(
      matchId: match.matchId,
      inningsNumber: _currentInningsNumber,
      totalOvers: match.totalOvers,
      target: target.value,
    );
    if (pre == null) return;

    // Re-read immediately before applying, rather than trusting the read
    // above: nothing orders that read (a real DB round trip, slower on a
    // large local DB or under scheduler pressure) against the socket's own
    // first event, or against [OfflineSyncService]'s independent
    // auto-sync-on-resume — either can leave this exact queue flushed by the
    // time the read above finally resolves, in which case `pre` describes a
    // queue that no longer exists. Applying it anyway would repaint the
    // console with a stale snapshot right over server truth that already
    // arrived, regressing the display until the next ball or sync event
    // corrects it again.
    //
    // Deliberately a second one-shot query rather than
    // [OfflineSyncService.pendingCount]/[_hasQueuedBalls]: that field is
    // only as current as its own Drift *stream*'s last emission, which reacts
    // to a write asynchronously and is not guaranteed to have caught up by
    // the instant this method's own (unrelated) query resolves — so it can
    // itself still read the pre-flush count for a moment. A fresh one-shot
    // read against the same table has no such lag; it reflects whatever is
    // actually committed at the moment it runs, which — with no `await`
    // between it and the writes below — is effectively the moment of
    // application.
    final current = await offlineSyncService.currentProvisionalState(
      matchId: match.matchId,
      inningsNumber: _currentInningsNumber,
      totalOvers: match.totalOvers,
      target: target.value,
    );
    if (current == null) return;

    _offlinePre = current;
    isProvisional.value = true;
    _applyPreEventStateAsCurrent(current);
  }

  /// Seeds a [PreEventState] from the controller's own live Rx fields — used
  /// only for the FIRST offline ball since the last real ack, when
  /// [_offlinePre] is still null. [PreEventState.totalBalls] and the extras
  /// bucket breakdown are approximated: this controller does not track them
  /// at that granularity, and nothing downstream reads them for display —
  /// only their sums, which this preserves exactly. Every field that
  /// actually reaches the screen is exact.
  PreEventState _currentPreEventStateFromLive() {
    final oversCompleted = int.tryParse(overs.value.split('.').first) ?? 0;
    return PreEventState(
      totalRuns: totalRuns.value,
      wickets: wickets.value,
      legalBalls: _legalBalls,
      totalBalls: _legalBalls,
      oversCompleted: oversCompleted,
      striker: BatsmanFigures(
        name: strike.value?.strikerName,
        runs: strike.value?.strikerRuns ?? 0,
        balls: strike.value?.strikerBalls ?? 0,
      ),
      nonStriker: BatsmanFigures(
        name: strike.value?.nonStrikerName,
        runs: strike.value?.nonStrikerRuns ?? 0,
        balls: strike.value?.nonStrikerBalls ?? 0,
      ),
      currentBowlerName: currentBowler.value,
      overTotalRuns: 0,
      overLegalDeliveries: _legalBalls - (oversCompleted * 6),
      extrasSnapshot: ExtrasSnapshot(wides: extrasTotal.value),
      overExtrasSnapshot: const ExtrasSnapshot(),
    );
  }

  /// Renders a [PreEventState] directly as current console state — used to
  /// seed the screen from a cold-restart replay and to restore state after
  /// undoing a still-queued ball. Unlike [_applyBallOutcome] this is not
  /// reacting to one delivery; it is painting a snapshot, so there is no
  /// rotation/over-completion logic here, only a direct copy.
  ///
  /// [excludedBowler] is deliberately left untouched: a [PreEventState]
  /// snapshot does not carry who bowled the over immediately before it, only
  /// who is bowling now — so the exact Law 17.6 exclusion cannot always be
  /// known from this alone. Harmless: the server still enforces the rule the
  /// moment a bowler selection actually syncs.
  void _applyPreEventStateAsCurrent(PreEventState pre) {
    totalRuns.value = pre.totalRuns;
    wickets.value = pre.wickets;
    overs.value =
        '${pre.oversCompleted}.${pre.legalBalls - pre.oversCompleted * 6}';
    extrasTotal.value = pre.extrasSnapshot.total;
    _legalBalls = pre.legalBalls;
    currentBowler.value = pre.currentBowlerName;
    _setNeedsBowler(pre.currentBowlerName == null);
    overComplete.value = pre.currentBowlerName == null;
    strike.value = Strike(
      strikerName: pre.striker.name,
      strikerRuns: pre.striker.runs,
      strikerBalls: pre.striker.balls,
      nonStrikerName: pre.nonStriker.name,
      nonStrikerRuns: pre.nonStriker.runs,
      nonStrikerBalls: pre.nonStriker.balls,
    );
    _recomputeRates();
  }

  /// Applies a scored ball's outcome to console state — shared verbatim by a
  /// real REST ack and a provisional preview, so the two can never apply
  /// differently. [absoluteBallSeq] is the one parameter that tells them
  /// apart: null for a preview, which is what keeps a provisional ball from
  /// ever touching [_lastAppliedSeq] — that watermark exists only for
  /// server-numbered deliveries.
  void _applyBallOutcome({
    required Strike? strike,
    int? absoluteBallSeq,
    required bool overJustCompleted,
    required bool inningsComplete,
    bool matchComplete = false,
    Wicket? wicket,
    int? overNumber,
    String? bowlerJustBowled,
    String? bowlerJustBowledId,
    bool newBowlerRequired = false,
    String? excludedBowlerName,
  }) {
    _applyStrike(strike, seq: absoluteBallSeq);
    overComplete.value = overJustCompleted;
    isInningsComplete.value = inningsComplete;
    lastWicket.value = wicket;

    if (matchComplete) _navigateToResult();

    if (overJustCompleted) {
      _applyOverEnd(
        overNumber: overNumber,
        bowlerJustBowled: bowlerJustBowled,
        bowlerJustBowledId: bowlerJustBowledId,
        excludedName: excludedBowlerName,
        newBowlerRequired: newBowlerRequired,
      );
    }
  }

  /// Queues one delivery locally and previews its effect. Called only after
  /// [_score] has already tried the network and hit a connectivity-shaped
  /// failure, or found a queue already pending — see that method for why a
  /// pending queue skips the network attempt entirely.
  Future<bool> _queueBallOffline(ScoreBallReq req) async {
    final pre = _offlinePre ?? _currentPreEventStateFromLive();

    await offlineSyncService.enqueueBall(
      matchId: match.matchId,
      inningsNumber: _currentInningsNumber,
      req: req,
      pre: pre,
    );
    // Same snapshot, same instant — the queue row and the ledger row both
    // describe "state immediately before this ball". `ballEventId` starts
    // null: this ball hasn't synced yet, so there is no server id for it
    // until `OfflineSyncService._attemptSync` backfills one on flush.
    await offlineSyncService.recordBallHistory(
      matchId: match.matchId,
      inningsNumber: _currentInningsNumber,
      pre: pre,
    );

    final preview = offlineSyncService.previewNextBall(
      pre: pre,
      req: req,
      totalOvers: match.totalOvers,
      inningsNumber: _currentInningsNumber,
      target: target.value,
    );

    _offlinePre = preview.nextPreEventState;
    isProvisional.value = true;

    // A queued ball's own preview totals — the socket will not update these
    // while offline, so this path owns them directly rather than relying on
    // the online path's convention of waiting for `score:update`.
    final totals = preview.inningsTotals;
    totalRuns.value = totals.totalRuns;
    wickets.value = totals.wickets;
    overs.value =
        '${totals.oversCompleted}.${totals.legalBalls - totals.oversCompleted * 6}';
    extrasTotal.value = totals.extras.total;
    _legalBalls = totals.legalBalls;
    _recomputeRates();

    // The just-finished innings' final numbers, captured now because nothing
    // else will remember them past the next `startInnings()` call zeroing
    // these same fields — needed offline for innings 2's own target, and
    // (whichever innings this was) for the eventual match result.
    if (preview.inningsComplete) {
      unawaited(
        offlineSyncService.recordInningsSummary(
          matchId: match.matchId,
          inningsNumber: _currentInningsNumber,
          battingTeam: _currentBattingTeam ?? '',
          totalRuns: totals.totalRuns,
          wickets: totals.wickets,
          overs: overs.value,
        ),
      );

      // Innings 2 ending IS match completion — unlike innings 1 ending, this
      // is previewable: `resolveMatchResultPreview` needs only both innings'
      // final `battingTeam`/`totalRuns` and innings 2's wickets, all of which
      // this device already has (innings 1's from the summary just like the
      // one above, written when IT completed). Persisted rather than just
      // held in memory, since `ResultScreen` is a separate route that can
      // outlive this controller, including across an app relaunch.
      if (_currentInningsNumber == 2) {
        unawaited(_saveProvisionalMatchResult(preview: preview));
        _navigateToResult();
      }
    }

    _applyBallOutcome(
      strike: preview.strike,
      overJustCompleted: preview.overComplete,
      inningsComplete: preview.inningsComplete,
      wicket: preview.wicket,
      overNumber: preview.overComplete
          ? preview.nextPreEventState.oversCompleted
          : null,
      bowlerJustBowled: preview.bowlerJustBowled,
      newBowlerRequired: preview.newBowlerRequired,
      excludedBowlerName: preview.bowlerJustBowled,
    );

    return true;
  }

  /// Computes and persists a provisional win/margin for the terminal ball of
  /// innings 2, queued offline. A no-op if innings 1's own summary somehow
  /// isn't there — it always should be by this point, since nothing reaches
  /// innings 2 without innings 1 having completed first, online or off.
  Future<void> _saveProvisionalMatchResult({
    required BallOutcomePreview preview,
  }) async {
    final innings1 = await offlineSyncService.inningsSummaryFor(
      matchId: match.matchId,
      inningsNumber: 1,
    );
    if (innings1 == null) return;

    final result = resolveMatchResultPreview(
      completionReason: preview.completionReason,
      battingTeam1: innings1.battingTeam,
      battingTeam2: _currentBattingTeam ?? '',
      runs1: innings1.totalRuns,
      runs2: preview.inningsTotals.totalRuns,
      wickets2: preview.inningsTotals.wickets,
    );

    await offlineSyncService.saveProvisionalResult(
      matchId: match.matchId,
      winner: result.winner,
      marginType: result.marginType,
      margin: result.margin,
    );
  }

  /// Undoes the most recently queued (never-synced) ball — the local half of
  /// [undoLastBall]. Rolls back to that row's own stored pre-ball snapshot in
  /// O(1): no replay, no network.
  Future<bool> _undoQueuedBall() async {
    final row = await offlineSyncService.lastQueuedBall(
      matchId: match.matchId,
      inningsNumber: _currentInningsNumber,
    );
    final snapshot = row?.preEventStateJson;
    if (row == null || snapshot == null) return false;

    isUndoing.value = true;
    await offlineSyncService.deleteQueuedEvent(row.id);

    // The [BallHistory] row inserted alongside this one when it was queued
    // (see [_queueBallOffline]) must go with it — a ball/bowler queue row
    // and its ledger row are always inserted together, in the same order,
    // so the ledger's current top entry IS this ball's. Left behind, it
    // would sit there as a stale, un-synced "ghost" that a later
    // already-synced undo could wrongly target next, restoring to a state
    // that belongs to a ball this device never actually sent anywhere.
    final ledgerEntry = await offlineSyncService.latestBallHistory(
      matchId: match.matchId,
      inningsNumber: _currentInningsNumber,
    );
    if (ledgerEntry != null) {
      await offlineSyncService.deleteBallHistoryEntry(ledgerEntry.id);
    }

    final restored = PreEventState.fromJson(
      jsonDecode(snapshot) as Map<String, dynamic>,
    );

    final stillQueued = await offlineSyncService.lastQueuedBall(
      matchId: match.matchId,
      inningsNumber: _currentInningsNumber,
    );

    _offlinePre = stillQueued == null ? null : restored;
    isProvisional.value = stillQueued != null;

    // Same rewind [_applyUndo] does for the online path, and for the same
    // reason: if the undone ball completed an over, `_applyOverEnd`'s guard
    // (`overNumber <= _lastOverPrompted`) would otherwise treat that over as
    // already prompted and silently no-op the next time it completes —
    // leaving `needsBowler` false and the stale bowler on screen with no
    // local warning, all the way through to a `BOWLER_NOT_SELECTED` on sync.
    // `restored.oversCompleted` is exactly `undone.overNumber - 1` would be
    // server-side: how many overs existed before the ball just undone.
    _lastOverPrompted = restored.oversCompleted;

    // A ball cannot have been queued against a completed innings — scoring
    // refuses that offline exactly like it does online — so undoing one
    // always reopens it. Without this, undoing the queued ball that just
    // completed innings 1 left this flag true, and the openers sheet
    // (blocking on it, per `_promptIfNeeded`) would reopen itself the
    // instant this undo closed it.
    isInningsComplete.value = false;

    _applyPreEventStateAsCurrent(restored);
    isUndoing.value = false;
    return true;
  }

  /// [SyncBlockedBottomSheet]'s "Undo back to here" action. Undoes every
  /// queued ball, tail first via repeated [_undoQueuedBall] calls, back
  /// through — and including — the one [OfflineSyncService.phase] reported
  /// as [SyncPhase.blockedOnRule]: since that ball always sits at the head
  /// of the queue (deliveries sync oldest-first, and nothing after it can
  /// have been applied while it blocks the front), draining the queue
  /// entirely is exactly "undo back through the stuck one".
  ///
  /// Nothing else clears `phase`/`lastError` once a queue empties this way
  /// — [OfflineSyncService.deleteQueuedEvent] doesn't touch either — so this
  /// is the one place that resets them, mirroring what
  /// [OfflineSyncService.discardQueueAndReload] does for a `conflict`.
  Future<void> undoBackToBlockedBall() async {
    while (offlineSyncService.pendingCount.value > 0) {
      final undone = await _undoQueuedBall();
      if (!undone) break;
    }
    offlineSyncService.phase.value = SyncPhase.idle;
    offlineSyncService.lastError.value = null;
  }

  /// Reconciles the console back to real server truth once a flush actually
  /// lands — a hard replace, never a merge, of everything a provisional
  /// preview stood in for. Fires even on a partial apply (see
  /// [OfflineSyncService.lastAppliedState]'s own doc comment): what committed
  /// is real and belongs on screen even though the rest of the queue is
  /// still stuck.
  void _reconcileFromSyncedState(SyncState state) {
    _applyStrike(state.strike);
    target.value = state.target;
    final totals = state.inningsTotals;
    totalRuns.value = totals.totalRuns;
    wickets.value = totals.wickets;
    extrasTotal.value = totals.extras.total;
    overs.value = state.overs;
    _legalBalls = totals.legalBalls;
    isInningsComplete.value = state.inningsComplete;
    _recomputeRates();

    // A sync response has no `matchComplete` field — only `inningsComplete`
    // (the backend's `buildStateSnapshot` never computes it, unlike
    // score-ball's own ack). Without this, a batch that finishes innings 2
    // while offline left [isInningsComplete] true with [isMatchComplete]
    // never set, and the openers-sheet branch below has no other way to
    // tell "innings ended" from "match ended" — it would reopen Opening
    // Players for an innings 3 that will never exist.
    if (state.inningsComplete && _currentInningsNumber == 2) {
      _navigateToResult();
    }

    final bowler = state.bowler;
    if (bowler != null) {
      _rememberBowler(bowler.currentBowlerId, bowler.currentBowlerName);
      _rememberBowler(bowler.previousBowlerId, bowler.previousBowlerName);
      currentBowler.value = bowler.currentBowlerName;
      excludedBowler.value = bowler.awaitingBowler
          ? bowler.previousBowlerName
          : null;
      _setNeedsBowler(bowler.awaitingBowler);
    }

    // Still queued (a partial apply) → still provisional, previewing on top
    // of whatever just became real. Nothing left → back to normal.
    if (_hasQueuedBalls) {
      _offlinePre = _currentPreEventStateFromLive();
    } else {
      _offlinePre = null;
      isProvisional.value = false;
    }
  }

  /// Pulls fresh authoritative state directly from the public match read —
  /// needed after [OfflineSyncService.discardQueueAndReload]: the socket's
  /// `match:state` ack only ever fires once, on the initial join, so nothing
  /// else would repaint this console until another delivery happens to be
  /// broadcast. The public endpoint needs no auth and answers immediately on
  /// the network that just came back, whether or not the socket itself has
  /// reconnected yet.
  Future<void> _reloadFromServerTruth() async {
    final response = await matchRepository.getPublicMatch(code: match.matchId);
    if (!response.isResult) return;

    final innings = response.result.data?.innings;
    if (innings == null) return;

    totalRuns.value = innings.totalRuns;
    wickets.value = innings.wickets;
    overs.value = innings.overs;
    extrasTotal.value = innings.extras.total;
    target.value = innings.target;
    _legalBalls = legalBallsFromOvers(innings.overs);
    _recomputeRates();
    _applyStrike(innings.strike);
    _applyBowlerState(
      bowler: innings.bowler,
      strikerName: innings.strike?.strikerName,
    );
  }

  /// Manual retry entry point for the sync-status banner.
  Future<void> retrySync() => offlineSyncService.retryNow(
    matchId: match.matchId,
    inningsNumber: _currentInningsNumber,
  );

  /// The banner's single tap handler, for either of its two meanings: an
  /// actual retry most of the time, or — when [OfflineSyncService.phase] is
  /// already [SyncPhase.conflict] or [SyncPhase.blockedOnRule] — reopening
  /// the relevant alert sheet instead. [retrySync] alone would not do that:
  /// neither state can be fixed by another sync attempt (a conflict needs
  /// the scorer's own decision; a rule-blocked delivery would just fail
  /// identically again), and only `_promptIfNeeded`'s own loop knows how to
  /// open either sheet without risking it stacking on top of another one.
  Future<void> handleSyncBannerTap() {
    if (offlineSyncService.phase.value == SyncPhase.conflict ||
        offlineSyncService.phase.value == SyncPhase.blockedOnRule) {
      return _promptIfNeeded();
    }
    return retrySync();
  }

  /// Opens the innings with two named openers. Until this succeeds the server
  /// rejects every delivery with `INNINGS_NOT_STARTED`, so the console blocks
  /// scoring while [hasOpeners] is false.
  Future<bool> startInnings({
    required String strikerName,
    required String nonStrikerName,
    required String bowlerName,
  }) async {
    final previousInningsNumber = _currentInningsNumber;
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
      // `/sync` can never carry `start-innings` (see docs/api.md) — a batch
      // cannot bootstrap an innings whose Inning document doesn't exist yet
      // server-side — so there is nothing to enqueue here, only something to
      // do differently: a genuine innings TRANSITION (a prior innings has
      // already completed, online or offline) can still open the next one
      // entirely locally and let the real call catch up once signal
      // returns; the very first `start-innings` of the match — nothing to
      // transition FROM — still has no offline path, matching "match
      // creation requires connectivity" from the product's own design.
      if (response.fallback is CricketNoInternetFailure) {
        final previousSummary = await offlineSyncService.inningsSummaryFor(
          matchId: match.matchId,
          inningsNumber: previousInningsNumber,
        );
        if (previousSummary != null) {
          return _startInningsOffline(
            previousInningsNumber: previousInningsNumber,
            previousSummary: previousSummary,
            strikerName: strikerName,
            nonStrikerName: nonStrikerName,
            bowlerName: bowlerName,
          );
        }
      }
      CricketSnackbar.showAlertMessage(response.fallback.message);
      return false;
    }

    final data = response.result.data;
    _applyInningsStarted(
      previousInningsNumber: previousInningsNumber,
      inningsNumber: data?.inningsNumber ?? _currentInningsNumber,
      battingTeam: data?.battingTeam,
      strike: data?.strike,
      bowlerName: data?.bowler?.bowlerName,
      bowlerId: data?.bowler?.bowlerId,
      target: data?.target,
      totals: data?.inningsTotals,
    );

    // Deliberately no success snackbar: `Get.showSnackbar` pushes a route, so
    // one here would sit on top of the sheet and swallow its `Get.back()`,
    // leaving the sheet up over an innings that had already started. The banner
    // filling in behind is the confirmation, and a better one.
    return true;
  }

  /// Opens the next innings entirely locally, when `start-innings` itself
  /// couldn't be reached — the offline half of [startInnings]. Everything
  /// here is computable from data this device already has: [previousSummary]
  /// (written the moment the prior innings was detected complete, online or
  /// off — see `_queueBallOffline`/`_score`) gives the batting side to flip
  /// and the total that becomes this innings' target, and the entered names
  /// are exactly what a real response would otherwise have supplied.
  ///
  /// The real call is not abandoned, only deferred: [PendingStartInnings]
  /// records exactly what it needs, and `OfflineSyncService`'s reconnect
  /// chain makes it for real — with these same names — the moment signal
  /// returns, ahead of flushing anything queued for this new innings.
  Future<bool> _startInningsOffline({
    required int previousInningsNumber,
    required InningsSummary previousSummary,
    required String strikerName,
    required String nonStrikerName,
    required String bowlerName,
  }) async {
    final inningsNumber = previousInningsNumber + 1;
    final battingTeam = previousSummary.battingTeam == 'teamA'
        ? 'teamB'
        : 'teamA';

    await offlineSyncService.savePendingStartInnings(
      matchId: match.matchId,
      inningsNumber: inningsNumber,
      strikerName: strikerName,
      nonStrikerName: nonStrikerName,
      bowlerName: bowlerName,
    );

    _applyInningsStarted(
      previousInningsNumber: previousInningsNumber,
      inningsNumber: inningsNumber,
      battingTeam: battingTeam,
      strike: Strike(strikerName: strikerName, nonStrikerName: nonStrikerName),
      bowlerName: bowlerName,
      // Innings 1 only — a target only ever exists for innings 2, and this
      // branch is only ever reached transitioning INTO an innings that has
      // one, per the offline scope this feature targets.
      target: previousSummary.totalRuns + 1,
      totals: null,
    );

    return true;
  }

  /// Everything a freshly-opened innings needs applied to console state —
  /// shared by [startInnings]'s online success and [_startInningsOffline],
  /// so the two can never drift: an offline-started innings 2 looks, feels,
  /// and previews exactly like an online one until the moment it actually
  /// syncs. [battingTeam] is nullable only because `StartInningsRes` could
  /// theoretically omit it; [_currentBattingTeam] simply stays whatever it
  /// was rather than guessing.
  void _applyInningsStarted({
    required int previousInningsNumber,
    required int inningsNumber,
    required String? battingTeam,
    required Strike? strike,
    required String? bowlerName,
    String? bowlerId,
    required int? target,
    required InningsTotals? totals,
  }) {
    // The offline queue is innings-scoped; re-point the service at whichever
    // innings just opened, and start the new innings with a clean slate —
    // any provisional state belonged to the innings that just ended.
    _currentInningsNumber = inningsNumber;
    _currentBattingTeam = battingTeam ?? _currentBattingTeam;
    offlineSyncService.watch(
      matchId: match.matchId,
      inningsNumber: _currentInningsNumber,
    );
    _offlinePre = null;
    isProvisional.value = false;

    // The just-finished innings' undo history has no business surviving
    // into the new one — the server's own Inning documents are separate,
    // and a stale entry here would let a later undo tap restore to a
    // snapshot that belongs to an innings which no longer accepts writes.
    unawaited(
      offlineSyncService.clearBallHistory(
        matchId: match.matchId,
        inningsNumber: previousInningsNumber,
      ),
    );

    // No delivery behind this payload, so no sequence — it is the current
    // state and always applies.
    _applyStrike(strike);

    // Over 1's bowler comes from here, which is why the console never prompts
    // for a bowler at the start of an innings.
    currentBowler.value = bowlerName;
    _rememberBowler(bowlerId, bowlerName);
    _setNeedsBowler(false);
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
    totalRuns.value = totals?.totalRuns ?? 0;
    wickets.value = totals?.wickets ?? 0;
    overs.value = '0.0';
    extrasTotal.value = totals?.extras.total ?? 0;
    this.target.value = target;
    _legalBalls = totals?.legalBalls ?? 0;

    // A fresh partnership for the new pair. Also marks the checkpoint
    // initialized so the socket listener's next arrival — which reports the
    // same fresh totals — does not re-run its own first-payload branch.
    _partnership.start(runs: totalRuns.value, legalBalls: _legalBalls);
    _partnershipInitialized = true;

    // `absoluteBallSeq` is innings-scoped (resets to 1 each innings), but
    // this watermark is not — left unreset here, innings 2's ball 1 (seq 1)
    // would read as older than whatever innings 1 last reached and the
    // strike guard in [_applyStrike] would silently drop every update for
    // the rest of the match, on both the REST ack and the socket.
    _lastAppliedSeq = 0;

    // Same hazard as [_lastAppliedSeq] just above, for the SAME reason:
    // `overNumber` is innings-scoped (over 1 of innings 2 reports 1, same as
    // over 1 of innings 1 did), but this watermark is not. Left unreset, the
    // very first over of innings 2 to complete would read as
    // `overNumber <= _lastOverPrompted` — "already prompted, a stale/
    // duplicate replay" — and [_applyOverEnd] would return before even
    // clearing [currentBowler] or setting [needsBowler], for every over
    // boundary until [_lastOverPrompted] is naturally exceeded again. On any
    // match longer than one over per innings (i.e. essentially all of them),
    // this silently lets the scorer keep bowling the same bowler across an
    // over boundary in innings 2 with no prompt and no queued `bowler` sync
    // event — a delivery the real server rejects outright
    // (`BOWLER_NOT_SELECTED`) the moment that stretch of the queue is synced.
    _lastOverPrompted = 0;
    _recomputeRates();
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
  /// happens — but the greying is an explanation, not the enforcement. Not
  /// checked at all in the offline preview — see `_currentPreEventStateFromLive`
  /// and `PreEventState`'s own notes on what a provisional preview cannot
  /// know; the server still enforces it the moment this syncs.
  ///
  /// Same network-first, queue-on-`CricketNoInternetFailure` shape as
  /// [_score], including skipping the network attempt outright when a queue
  /// already exists — see that method's own comment on why.
  ///
  /// [bowlerId] is what the picker sends when the scorer tapped a known
  /// bowler's chip rather than typing a name — see [BowlerRef] and
  /// docs/api.md's "Identity: bowlerId vs a bare name". Omitted, it names a
  /// new player; passed, it names this exact one, no matter what other
  /// `Player` on the team might share the typed name.
  Future<bool> selectBowler(String bowlerName, {String? bowlerId}) async {
    final req = SelectBowlerReq(bowlerName: bowlerName, bowlerId: bowlerId);

    if (_hasQueuedBalls) {
      return _queueBowlerOffline(req);
    }

    isSelectingBowler.value = true;

    final response = await selectBowlerUseCase(
      params: SelectBowlerParams(matchId: match.matchId, selectBowlerReq: req),
    );

    isSelectingBowler.value = false;

    if (!response.isResult) {
      if (response.fallback is CricketNoInternetFailure) {
        return _queueBowlerOffline(req);
      }
      CricketSnackbar.showAlertMessage(response.fallback.message);
      return false;
    }

    final data = response.result.data;
    currentBowler.value = data?.bowler.bowlerName;
    _rememberBowler(data?.bowler.bowlerId, data?.bowler.bowlerName);
    _rememberBowler(
      data?.previousBowler?.bowlerId,
      data?.previousBowler?.bowlerName,
    );

    _setNeedsBowler(false);
    excludedBowler.value = null;
    overComplete.value = false;

    // No success snackbar, for the same reason start-innings has none:
    // `Get.showSnackbar` pushes a route that would sit over the sheet and
    // swallow its `Get.back()`. The console unlocking behind is the better
    // confirmation.
    return true;
  }

  /// Queues a bowler selection locally. No rule-checking on this side — see
  /// [selectBowler]'s own comment; a rule rejection can only ever come back
  /// later, via `failedCode` on the eventual sync response. No [BallHistory]
  /// row for this: only a delivery is ever an undo target, and a ball's own
  /// snapshot already carries who was bowling at that point, so a
  /// bowler-selection event needs no ledger entry of its own.
  Future<bool> _queueBowlerOffline(SelectBowlerReq req) async {
    final pre = _offlinePre ?? _currentPreEventStateFromLive();

    await offlineSyncService.enqueueBowler(
      matchId: match.matchId,
      inningsNumber: _currentInningsNumber,
      req: req,
      pre: pre,
    );

    _offlinePre = PreEventState(
      totalRuns: pre.totalRuns,
      wickets: pre.wickets,
      legalBalls: pre.legalBalls,
      totalBalls: pre.totalBalls,
      oversCompleted: pre.oversCompleted,
      striker: pre.striker,
      nonStriker: pre.nonStriker,
      currentBowlerName: req.bowlerName,
      overTotalRuns: pre.overTotalRuns,
      overLegalDeliveries: pre.overLegalDeliveries,
      extrasSnapshot: pre.extrasSnapshot,
      overExtrasSnapshot: pre.overExtrasSnapshot,
    );
    isProvisional.value = true;

    currentBowler.value = req.bowlerName;
    // `req.bowlerId` is only ever non-null here if the scorer picked an
    // already-known chip whose id this device learned before going offline
    // — a genuinely new offline name never has one yet, since ids are only
    // ever assigned server-side, on sync.
    _rememberBowler(req.bowlerId, req.bowlerName);
    _setNeedsBowler(false);
    excludedBowler.value = null;
    overComplete.value = false;

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
  ///
  /// Three-way branch, in priority order:
  /// 1. A still-queued (never-synced) ball — undone locally, via
  ///    [_undoQueuedBall], deleted from the queue directly, never sent as an
  ///    `undo` sync event. See docs/api.md: replaying that ball's
  ///    `idempotencyKey` after undo would silently re-score the delivery
  ///    just removed.
  /// 2. An already-synced ball with an entry in the local [BallHistory]
  ///    ledger — targeted below. The ledger, not an in-memory stack, is what
  ///    lets this chain arbitrarily far back through already-synced balls
  ///    while offline, not just the single most recent one.
  /// 3. Nothing left in either place — nothing to undo.
  Future<bool> undoLastBall() async {
    if (isUndoing.value || isScoring.value) return false;

    final queuedBall = await offlineSyncService.lastQueuedBall(
      matchId: match.matchId,
      inningsNumber: _currentInningsNumber,
    );
    if (queuedBall != null) return _undoQueuedBall();

    final entry = await offlineSyncService.latestBallHistory(
      matchId: match.matchId,
      inningsNumber: _currentInningsNumber,
    );
    if (entry == null) return false;

    final targetId = await _resolveUndoTargetId(entry);
    if (targetId == null) return false;

    isUndoing.value = true;

    final response = await undoBallUseCase(
      params: UndoBallParams(
        matchId: match.matchId,
        undoBallReq: UndoBallReq(ballEventId: targetId),
      ),
    );

    isUndoing.value = false;

    if (!response.isResult) {
      // Already-synced ball, currently offline: queue the undo instead of
      // showing an error — see docs/api.md on why this becomes its own
      // all-undo batch.
      if (response.fallback is CricketNoInternetFailure) {
        await offlineSyncService.enqueueUndo(
          matchId: match.matchId,
          inningsNumber: _currentInningsNumber,
          ballEventId: targetId,
        );
        await offlineSyncService.deleteBallHistoryEntry(entry.id);

        // The ledger row being undone stores exactly the state from
        // immediately BEFORE it — precisely what the console should show now
        // that it's gone. No network round trip needed to know this, unlike
        // before the ledger existed.
        //
        // Deliberately logged and guarded, unlike every other step above:
        // this is the one place a malformed or unexpected snapshot could
        // silently leave the console showing pre-undo numbers while the
        // undo itself has already gone out to the queue (visible via the
        // sync banner) — a rejected write that only logs is the same
        // failure as a silent overwrite. If this throws, the undo has still
        // genuinely queued; only the local preview failed to update, so the
        // scorer needs an explicit signal rather than a quietly stale screen.
        if (kDebugMode) {
          debugPrint(
            'offline undo of already-synced ball $targetId: '
            'restoring from ${entry.preEventStateJson}',
          );
        }

        final PreEventState restored;
        try {
          restored = PreEventState.fromJson(
            jsonDecode(entry.preEventStateJson) as Map<String, dynamic>,
          );
        } catch (e, stack) {
          if (kDebugMode) {
            debugPrint(
              'offline undo: failed to restore local state: $e\n$stack',
            );
          }
          CricketSnackbar.showErrorMessage(
            TranslationKeys.somethingWentWrong.tr,
          );
          return true;
        }

        _offlinePre = restored;
        isProvisional.value = true;
        // Same rewind [_undoQueuedBall] does, and for the same reason — see
        // that method's own comment.
        _lastOverPrompted = restored.oversCompleted;

        // This ball DID advance [_lastAppliedSeq] when it first scored
        // online (`_score`'s success path passes its real `absoluteBallSeq`
        // through `_applyStrike`) — unlike a queued ball's own offline
        // preview, which never touches that watermark at all. Left stale,
        // the very next real ack — once connectivity returns and a new ball
        // replaces this one at the same sequence number — would arrive with
        // `seq <= _lastAppliedSeq` and get silently dropped by
        // [_applyStrike]'s guard: totals update (they bypass that guard
        // entirely), but the striker/non-striker freeze on whatever this
        // undo just restored, forever, since nothing ever exceeds the stale
        // watermark again. `restored.totalBalls` is exactly right for this:
        // the server assigns `absoluteBallSeq: inning.totalBalls + 1`, so
        // the ball count immediately before the one just undone IS that
        // ball's `absoluteBallSeq - 1` — the same rewind [_applyUndo] does
        // online via `undone.absoluteBallSeq - 1`, expressed in the terms
        // this offline path actually has on hand.
        _lastAppliedSeq = restored.totalBalls;

        // Same reopening [_undoQueuedBall] does, and for the same reason:
        // this ball cannot have completed the innings and still have
        // something after it to undo offline — undoing it always reopens.
        isInningsComplete.value = false;

        _applyPreEventStateAsCurrent(restored);

        // Matches [_applyUndo]'s own cleanup: the undone ball's modifiers
        // are gone, so the next tap must not silently inherit whatever was
        // still armed from before the undo.
        selectedFault.value = null;
        selectedRunsFrom.value = null;

        return true;
      }

      // `BALL_NOT_LATEST` means a delivery landed that this console never saw
      // the ack for — the whole ledger is fiction from that point on
      // (everything in it was captured assuming a history that turned out to
      // be wrong), so drop it rather than leave a button that keeps failing
      // on the same stale id. Anything else says nothing about the id, so
      // the ledger survives and the scorer can simply try again.
      if (response.fallback.code == 'BALL_NOT_LATEST') {
        await offlineSyncService.clearBallHistory(
          matchId: match.matchId,
          inningsNumber: _currentInningsNumber,
        );
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
    // no business staying in the ledger either.
    await offlineSyncService.deleteBallHistoryEntry(entry.id);

    _applyUndo(data);
    return true;
  }

  /// The server id a [BallHistoryEntry] should be undone by. Its own
  /// `ballEventId` is set the moment its ball's own flush resolves one (see
  /// `OfflineSyncService._attemptSync`'s backfill), which — because ball
  /// events are flushed one at a time specifically so this always resolves —
  /// should already cover every entry that has ever reached the top of the
  /// stack. `SyncBaseline.lastBallEventId` is kept only as a defensive
  /// fallback for anything that slips through that expectation; null from
  /// both means there is genuinely nothing to target.
  Future<String?> _resolveUndoTargetId(BallHistoryEntry entry) async {
    if (entry.ballEventId != null) return entry.ballEventId;
    final baseline = await offlineSyncService.baselineFor(
      matchId: match.matchId,
      inningsNumber: _currentInningsNumber,
    );
    return baseline?.lastBallEventId;
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
      _rememberBowler(bowler.currentBowlerId, bowler.currentBowlerName);
      _rememberBowler(bowler.previousBowlerId, bowler.previousBowlerName);
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
      _setNeedsBowler(bowler.awaitingBowler);
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
  ///
  /// Tries the network first; falls back to the offline queue only on a
  /// connectivity-shaped failure (`CricketNoInternetFailure` — now correctly
  /// covering a timeout as well as an outright drop, see
  /// `api_client_service.dart`). If a queue already exists for this innings,
  /// this skips the network attempt entirely and queues straight away: a
  /// direct online call here would score against server state that does not
  /// yet reflect the still-pending queue, and could silently apply out of
  /// order ahead of it.
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

    // Captured here, before anything is even sent, not after the ack comes
    // back: a live socket broadcast for this SAME ball can arrive and mutate
    // these exact fields while the REST call is in flight — the app also
    // listens to `score:update` for the "ack lost on patchy signal" case,
    // and that listener does not know this call is already in flight. A
    // capture taken after awaiting the response would then be reading this
    // ball's own POST-state as if it were its pre-state, which is exactly
    // what happened here: nothing could possibly have reported this ball
    // yet at this point, socket included, since it has not been sent.
    final pre = _currentPreEventStateFromLive();

    final fault = selectedFault.value;
    final runsFrom = fault == ExtraType.wide ? null : selectedRunsFrom.value;
    // Generated once, here, before anything is attempted — reused verbatim
    // if this falls through to the queue, so even a first attempt whose
    // outcome is genuinely unknown (a timeout) is safe to retry under the
    // same key rather than risk scoring the same delivery twice.
    final req = ScoreBallReq(
      runs: runs,
      extraType: fault,
      runsFrom: runsFrom,
      wicketType: wicketType,
      dismissedBatsman: wicketType == null ? null : dismissedBatsman,
      incomingBatsmanName: incomingBatsmanName,
      idempotencyKey: _uuid.v4(),
    );

    if (_hasQueuedBalls) {
      final queued = await _queueBallOffline(req);
      isScoring.value = false;
      selectedFault.value = null;
      selectedRunsFrom.value = null;
      return queued;
    }

    final response = await scoreBallUseCase(
      params: ScoreBallParams(matchId: match.matchId, scoreBallReq: req),
    );

    isScoring.value = false;

    if (!response.isResult) {
      if (response.fallback is CricketNoInternetFailure) {
        final queued = await _queueBallOffline(req);
        selectedFault.value = null;
        selectedRunsFrom.value = null;
        return queued;
      }
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
      // [pre] — captured before the request was even sent, not here — is
      // exactly the "state immediately before this ball" a [BallHistory]
      // row needs. Recorded now, rather than earlier, so a ball that lands
      // is undoable even if something below throws; the real `ballEventId`
      // is already known (no batch involved), unlike a queued ball's row,
      // which starts null and is backfilled on flush.
      unawaited(
        offlineSyncService.recordBallHistory(
          matchId: match.matchId,
          inningsNumber: _currentInningsNumber,
          pre: pre,
          ballEventId: ball.ballEventId,
        ),
      );

      // `nextBowler` non-null IS the instruction to prompt — the server has
      // already folded in whether the innings ended on this ball, so there is
      // nothing to recombine here.
      _applyBallOutcome(
        strike: ball.strike,
        absoluteBallSeq: ball.absoluteBallSeq,
        overJustCompleted: ball.overComplete,
        inningsComplete: ball.inningsComplete,
        matchComplete: ball.matchComplete,
        wicket: ball.wicket,
        overNumber: ball.over?.overNumber ?? ball.overNumber,
        bowlerJustBowled: ball.over?.bowlerName,
        bowlerJustBowledId: ball.over?.bowlerId,
        newBowlerRequired: ball.nextBowler != null,
        excludedBowlerName: ball.nextBowler?.excludedBowlerName,
      );

      // Same reasoning as the strike apply above, extended to cover totals:
      // `score:update` was the only thing that ever wrote these, so a
      // dropped or delayed socket broadcast (patchy signal, or a reconnect
      // still in flight right after the app was offline) left the score
      // frozen even though the ball had genuinely landed — the ack already
      // carries everything needed, so there is no reason to wait on the
      // socket for it.
      final totals = ball.inningsTotals;
      totalRuns.value = totals.totalRuns;
      wickets.value = totals.wickets;
      overs.value =
          '${totals.oversCompleted}.${totals.legalBalls - totals.oversCompleted * 6}';
      extrasTotal.value = totals.extras.total;
      target.value = ball.target;
      _legalBalls = totals.legalBalls;
      _recomputeRates();

      // Same capture `_queueBallOffline` does for a queued terminal ball —
      // see that method's own comment on why this can't be reconstructed
      // later from anywhere else.
      if (ball.inningsComplete) {
        unawaited(
          offlineSyncService.recordInningsSummary(
            matchId: match.matchId,
            inningsNumber: _currentInningsNumber,
            battingTeam: _currentBattingTeam ?? '',
            totalRuns: totals.totalRuns,
            wickets: totals.wickets,
            overs: overs.value,
          ),
        );
      }

      // Keeps the sync protocol's own bookkeeping fresh even on a purely
      // online stretch — see [OfflineSyncService.recordAck]'s own comment on
      // why this matters the first time offline scoring is actually needed.
      unawaited(
        offlineSyncService.recordAck(
          matchId: match.matchId,
          inningsNumber: _currentInningsNumber,
          totalBalls: ball.inningsTotals.totalBalls,
          lastBallEventId: ball.ballEventId,
        ),
      );
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
    // Not optional cleanup: two of these are registered on
    // offlineSyncService's own Rx fields (a singleton this controller does
    // not own), so leaving them undisposed keeps this entire controller
    // alive and firing on every future match's sync activity — see
    // [_workers]'s own doc comment.
    for (final worker in _workers) {
      worker.dispose();
    }
    // Does NOT stop a flush already in flight, or future ones — the service
    // is `fenix`-registered and outlives this controller/route on purpose,
    // so a queue keeps trying to drain even after the scorer navigates away.
    offlineSyncService.unwatch();
    super.onClose();
  }
}
