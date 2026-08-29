import 'package:cricket_scorer/features/scoring/data/models/response/bowler_state.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/strike.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sync_res.g.dart';

/// The same complete-state snapshot `undo-ball` returns — see
/// [UndoBallRes]'s own doc comment for why this is a snapshot, never a diff:
/// after a batch, the console re-renders from these fields rather than
/// folding the events it just sent.
@JsonSerializable(explicitToJson: true)
class SyncState {
  final Strike? strike;
  final BowlerState? bowler;

  /// Null in innings 1. See [ScoreBallRes.target].
  final int? target;

  final InningsTotals inningsTotals;

  /// Formatted `<completedOvers>.<legalBallsInCurrentOver>`.
  final String overs;

  final bool inningsComplete;
  final bool canUndo;

  SyncState({
    this.strike,
    this.bowler,
    this.target,
    required this.inningsTotals,
    required this.overs,
    this.inningsComplete = false,
    this.canUndo = false,
  });

  factory SyncState.fromJson(Map<String, dynamic> json) =>
      _$SyncStateFromJson(json);

  Map<String, dynamic> toJson() => _$SyncStateToJson(this);
}

/// `POST /:matchId/sync`'s response. See docs/api.md's sync section for the
/// full contract this mirrors.
@JsonSerializable(explicitToJson: true)
class SyncRes {
  final String matchId;
  final String inningsId;
  final int inningsNumber;

  /// `local` / `syncing` / `synced` / `conflict` — this endpoint is the only
  /// writer of `Match.syncStatus`.
  final String syncStatus;

  final int baseAbsoluteBallSeq;

  /// Where the innings now stands — carried forward as the client's NEXT
  /// `baseAbsoluteBallSeq`, never recomputed locally.
  final int absoluteBallSeq;

  /// Events recognised as already applied on this attempt (the resume path
  /// after a lost response). `0` on a clean sync.
  final int appliedCount;
  final int skippedCount;

  /// Null when the whole batch applied. Otherwise the 0-based index of the
  /// event that stopped the batch — everything before it still committed.
  final int? failedAt;

  /// The usual single-event error code (`BOWLER_NOT_SELECTED`,
  /// `INNINGS_COMPLETED`, …) that stopped the batch at [failedAt].
  final String? failedCode;

  /// The Mongo id of the last successfully-applied `ball` event in this
  /// batch — null if the batch applied zero ball events (a bowler-only or
  /// fully-skipped batch). Undo only ever targets the single most recent
  /// ball, so this is exactly what an undo of a batch-synced delivery needs
  /// to target; there is no per-event id list, deliberately, since nothing
  /// but the latest one is ever addressable anyway.
  final String? lastBallEventId;

  final SyncState state;

  SyncRes({
    required this.matchId,
    required this.inningsId,
    required this.inningsNumber,
    required this.syncStatus,
    required this.baseAbsoluteBallSeq,
    required this.absoluteBallSeq,
    this.appliedCount = 0,
    this.skippedCount = 0,
    this.failedAt,
    this.failedCode,
    this.lastBallEventId,
    required this.state,
  });

  factory SyncRes.fromJson(Map<String, dynamic> json) =>
      _$SyncResFromJson(json);

  Map<String, dynamic> toJson() => _$SyncResToJson(this);
}
