import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/select_bowler_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/undo_ball_req.dart';

/// One queued event's wire shape — exactly the matching single-event
/// endpoint's own body, plus a `type` discriminant. Hand-written rather than
/// `@JsonSerializable`: it's a closed, three-way union, and reusing
/// [ScoreBallReq]/[SelectBowlerReq]/[UndoBallReq]'s own `toJson()` is what
/// keeps this from ever drifting from the single-event bodies the server
/// already validates identically. Request-only — a batch is never decoded
/// back from JSON on this side.
sealed class SyncEvent {
  const SyncEvent();

  Map<String, dynamic> toJson();
}

class SyncBallEvent extends SyncEvent {
  final ScoreBallReq req;

  const SyncBallEvent(this.req);

  @override
  Map<String, dynamic> toJson() => {'type': 'ball', ...req.toJson()};
}

class SyncBowlerEvent extends SyncEvent {
  final SelectBowlerReq req;

  const SyncBowlerEvent(this.req);

  @override
  Map<String, dynamic> toJson() => {'type': 'bowler', ...req.toJson()};
}

class SyncUndoEvent extends SyncEvent {
  final UndoBallReq req;

  const SyncUndoEvent(this.req);

  @override
  Map<String, dynamic> toJson() => {'type': 'undo', ...req.toJson()};
}

/// `POST /:matchId/sync`'s request body. See docs/api.md — a batch is either
/// all [SyncUndoEvent]s or contains none at all, enforced before this is ever
/// built, by `OfflineSyncService._attemptSync`'s homogeneous-run grouping —
/// not here, and not at enqueue time either (the local queue itself can be
/// mixed; only what's actually sent in one call cannot be).
class SyncReq {
  final int inningsNumber;

  /// The highest `absoluteBallSeq` this client has confirmed for this
  /// innings — carried forward from the previous sync response's
  /// `absoluteBallSeq`, never recomputed locally.
  final int baseAbsoluteBallSeq;

  final List<SyncEvent> events;

  const SyncReq({
    required this.inningsNumber,
    required this.baseAbsoluteBallSeq,
    required this.events,
  });

  Map<String, dynamic> toJson() => {
    'inningsNumber': inningsNumber,
    'baseAbsoluteBallSeq': baseAbsoluteBallSeq,
    'events': events.map((event) => event.toJson()).toList(),
  };
}
