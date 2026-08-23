import 'dart:async';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/live_score_res.dart';
import 'package:cricket_scorer/features/scoring/data/scoring_constants.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/score_ball.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class ScoreBallController extends GetxController {
  final ScoreBallUseCase scoreBallUseCase;
  final MatchRepository matchRepository;

  ScoreBallController({
    required this.scoreBallUseCase,
    required this.matchRepository,
  });

  late final CreateMatchRes match;

  final totalRuns = 0.obs;
  final wickets = 0.obs;
  final overs = '0.0'.obs;
  final extrasTotal = 0.obs;
  final isScoring = false.obs;

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
                '(${event.result.overs} overs)',
              );
            }
            totalRuns.value = event.result.totalRuns;
            wickets.value = event.result.wickets;
            overs.value = event.result.overs;
            extrasTotal.value = event.result.extras?.total ?? extrasTotal.value;
          } else {
            CricketSnackbar.showErrorMessage(event.fallback.message);
          }
        });
  }

  Future<void> scoreRuns(int runs) async {
    if (isScoring.value) return;
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
          idempotencyKey: _uuid.v4(),
        ),
      ),
    );

    isScoring.value = false;

    if (kDebugMode && response.isResult) {
      debugPrint(
        'scoreBall REST ack: ${response.result.data?.inningsTotals.totalRuns} runs '
        '(live totals update arrives separately via score:update)',
      );
    }

    if (!response.isResult) {
      CricketSnackbar.showAlertMessage(response.fallback.message);
      return;
    }

    // Modifiers apply to a single delivery — clear them so the next tap
    // defaults back to a plain legal ball off the bat.
    selectedFault.value = null;
    selectedRunsFrom.value = null;
  }

  @override
  void onClose() {
    unawaited(_subscription?.cancel());
    super.onClose();
  }
}
