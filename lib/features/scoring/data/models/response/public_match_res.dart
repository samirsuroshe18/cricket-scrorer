import 'package:cricket_scorer/features/scoring/data/models/response/bowler_state.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_result_info.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/strike.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_match_res.g.dart';

/// A team's name, and only its name — the unauthenticated view of a Team.
/// Never the full `TeamRef` the scorer's own `create` response carries: a
/// spectator has no use for a team id, and there is no public endpoint that
/// would resolve one anyway.
@JsonSerializable()
class PublicTeamRef {
  final String? name;

  PublicTeamRef({this.name});

  factory PublicTeamRef.fromJson(Map<String, dynamic> json) =>
      _$PublicTeamRefFromJson(json);

  Map<String, dynamic> toJson() => _$PublicTeamRefToJson(this);
}

/// The fixture half of `GET /v1/match/public/:code` — everything that does
/// not change ball to ball. Deliberately has no `createdBy`: that field
/// never leaves the server on this route.
@JsonSerializable(explicitToJson: true)
class PublicMatchInfo {
  final String matchId;
  final String? joinCode;
  final String? title;
  final PublicTeamRef teamA;
  final PublicTeamRef teamB;
  final int totalOvers;

  /// Both null when the toss was skipped. `teamA` / `teamB`.
  final String? tossWinner;

  /// `bat` / `bowl`.
  final String? tossDecision;

  final String status;
  final String? matchType;
  final String? venue;
  final int currentInnings;

  /// Null until `status` is `completed`. The backend has sent this since the
  /// spectator contract shipped — `getPublicMatch` picks it unconditionally —
  /// it just had nothing to set it until match completion existed, and
  /// nothing here parsed it until now.
  final MatchResultInfo? result;

  PublicMatchInfo({
    required this.matchId,
    this.joinCode,
    this.title,
    required this.teamA,
    required this.teamB,
    required this.totalOvers,
    this.tossWinner,
    this.tossDecision,
    required this.status,
    this.matchType,
    this.venue,
    required this.currentInnings,
    this.result,
  });

  factory PublicMatchInfo.fromJson(Map<String, dynamic> json) =>
      _$PublicMatchInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PublicMatchInfoToJson(this);
}

/// The live half — byte-for-byte the same shape the socket's `match:state`
/// and `score:update` emit. That equivalence is the point: the spectator
/// controller parses this once on the initial fetch and then folds socket
/// payloads into the exact same fields, with no second model to keep in sync.
@JsonSerializable(explicitToJson: true)
class PublicInningsState {
  final String? matchId;
  final int? inningsNumber;
  final int totalRuns;
  final int wickets;
  final String overs;

  /// Null in innings 1 — see [ScoreBallRes.target] for why this rides on the
  /// live state rather than a one-off fetch.
  final int? target;
  final ExtrasBreakdown extras;
  final Strike? strike;

  /// See `LiveScoreRes.partnershipRuns`/`.partnershipBalls` — the same
  /// server-computed field, present here for the same reason: this is one of
  /// the two payloads (the other being `match:state`) a client has no local
  /// ball history to seed a resumed partnership from on its own.
  final int? partnershipRuns;
  final int? partnershipBalls;

  final BowlerState? bowler;

  PublicInningsState({
    this.matchId,
    this.inningsNumber,
    required this.totalRuns,
    required this.wickets,
    required this.overs,
    this.target,
    required this.extras,
    this.strike,
    this.partnershipRuns,
    this.partnershipBalls,
    this.bowler,
  });

  factory PublicInningsState.fromJson(Map<String, dynamic> json) =>
      _$PublicInningsStateFromJson(json);

  Map<String, dynamic> toJson() => _$PublicInningsStateToJson(this);
}

/// `GET /v1/match/public/:code` in full.
///
/// [innings] is null until `start-innings` runs — a spectator who opens the
/// link early sees the fixture and an empty scoreboard, not an error. The
/// controller is what decides how to render that; this model just carries
/// the null through faithfully.
@JsonSerializable(explicitToJson: true)
class PublicMatchRes {
  final PublicMatchInfo match;
  final PublicInningsState? innings;

  PublicMatchRes({required this.match, this.innings});

  factory PublicMatchRes.fromJson(Map<String, dynamic> json) =>
      _$PublicMatchResFromJson(json);

  Map<String, dynamic> toJson() => _$PublicMatchResToJson(this);
}
