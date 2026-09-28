import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Where tapping a match card should land.
enum MatchDestination { squad, scoring, result }

/// Matches acknowledged since the list they appear in was last fetched.
///
/// The server is the source of truth (`squadAcknowledged` on each history
/// item), but a Skip made offline never reaches it, and a list on screen does
/// not refetch when the scorer comes back from the console. Remembering here,
/// in memory, means "don't show this again" holds immediately for the rest of
/// the session either way; a fresh fetch (or a restart) then defers to the
/// server.
class SquadAcknowledgements {
  static final Set<String> _matchIds = {};

  static void remember(String matchId) => _matchIds.add(matchId);

  static bool contains(String matchId) => _matchIds.contains(matchId);

  @visibleForTesting
  static void reset() => _matchIds.clear();
}

const _scorableStatuses = {'upcoming', 'live', 'innings_break'};

/// An `upcoming` match whose Squad screen has not been dealt with opens that
/// screen — every time, until the scorer taps Skip or Save & continue. Other
/// still-live states reopen the scoring console (which resumes from server
/// state); terminal ones open the result.
MatchDestination destinationFor(MatchHistoryItem item) {
  if (!_scorableStatuses.contains(item.status)) return MatchDestination.result;
  final needsSquad =
      item.status == 'upcoming' &&
      !item.squadAcknowledged &&
      !SquadAcknowledgements.contains(item.matchId);
  return needsSquad ? MatchDestination.squad : MatchDestination.scoring;
}

/// A history row in the shape the scoring console and Squad screen take.
CreateMatchRes toCreateMatchRes(MatchHistoryItem item) => CreateMatchRes(
  matchId: item.matchId,
  joinCode: item.joinCode,
  teamA: item.teamA,
  teamB: item.teamB,
  totalOvers: item.totalOvers,
  tossWinner: item.tossWinner,
  tossDecision: item.tossDecision,
  status: item.status,
  syncStatus: 'synced',
  createdAt: item.createdAt,
);

/// What every match card does when tapped — one rule, so the Home and Team
/// Profile lists can never disagree about it.
void openMatchFromHistory(MatchHistoryItem item) {
  switch (destinationFor(item)) {
    case MatchDestination.squad:
      unawaited(
        Get.toNamed<dynamic>(
          AppRoutes.squad,
          arguments: toCreateMatchRes(item),
        ),
      );
    case MatchDestination.scoring:
      unawaited(
        Get.toNamed<dynamic>(
          AppRoutes.scoreBall,
          arguments: toCreateMatchRes(item),
        ),
      );
    case MatchDestination.result:
      unawaited(Get.toNamed<dynamic>(AppRoutes.matchResultPath(item.matchId)));
  }
}
