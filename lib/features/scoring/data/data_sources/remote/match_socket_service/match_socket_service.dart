import 'dart:async';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/socket_client_service.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/live_score_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_abandoned_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/over_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_undo_res.dart';

class MatchSocketService {
  final SocketClientService socketClientService;

  MatchSocketService({required this.socketClientService});

  Stream<Either<LiveScoreRes, CricketFailure>> watchScore(String matchId) {
    final socket = socketClientService.socket;
    final controller = StreamController<Either<LiveScoreRes, CricketFailure>>();

    void onState(dynamic data) {
      controller.add(
        Either.result(
          LiveScoreRes.fromJson(Map<String, dynamic>.from(data as Map)),
        ),
      );
    }

    void onUpdate(dynamic data) {
      controller.add(
        Either.result(
          LiveScoreRes.fromJson(Map<String, dynamic>.from(data as Map)),
        ),
      );
    }

    void onDisconnect(dynamic _) {
      controller.add(Either.fallback(CricketSocketDisconnectedFailure()));
    }

    void onConnectError(dynamic _) {
      controller.add(Either.fallback(CricketSocketDisconnectedFailure()));
    }

    socket.on('match:state', onState);
    socket.on('score:update', onUpdate);
    socket.on('disconnect', onDisconnect);
    socket.on('connect_error', onConnectError);

    socket.emit('match:join', {'matchId': matchId});

    controller.onCancel = () async {
      socket.off('match:state', onState);
      socket.off('score:update', onUpdate);
      socket.off('disconnect', onDisconnect);
      socket.off('connect_error', onConnectError);
      // The inverse of match:join above, on the same shared, app-wide socket
      // this stream never owns exclusively — without this, navigating from
      // one match to another (spectating A, then B, in one continuous
      // session) left the connection sitting in every room it had ever
      // joined, for the rest of the process. See match.socket.js's own
      // match:leave handler: read-only, no DB access, safe to send even if
      // this room was already left or never joined.
      socket.emit('match:leave', {'matchId': matchId});
      await controller.close();
    };

    return controller.stream;
  }

  /// The `over:complete` event, on its own stream.
  ///
  /// Kept separate from [watchScore] rather than multiplexed into it because
  /// the payload is a different shape — one model describing both would be
  /// nullable almost everywhere. No `match:join` is emitted here: [watchScore]
  /// already joins the room, and joining twice would double every score update.
  Stream<Either<OverCompleteRes, CricketFailure>> watchOverComplete(
    String matchId,
  ) {
    final socket = socketClientService.socket;
    final controller =
        StreamController<Either<OverCompleteRes, CricketFailure>>();

    void onOverComplete(dynamic data) {
      controller.add(
        Either.result(
          OverCompleteRes.fromJson(Map<String, dynamic>.from(data as Map)),
        ),
      );
    }

    socket.on('over:complete', onOverComplete);

    controller.onCancel = () async {
      socket.off('over:complete', onOverComplete);
      await controller.close();
    };

    return controller.stream;
  }

  /// The `score:undo` event. Never emitted for an `alreadyUndone` no-op — see
  /// docs/api.md — so this stream simply stays quiet on a retried undo, the
  /// same as the room does.
  ///
  /// The scorer's own console does not need this: it already gets a complete
  /// state snapshot back from the `undo-ball` REST call. A spectator has no
  /// such ack — the socket is the only channel it has — which is why this
  /// exists at all.
  Stream<Either<ScoreUndoRes, CricketFailure>> watchScoreUndo(String matchId) {
    final socket = socketClientService.socket;
    final controller = StreamController<Either<ScoreUndoRes, CricketFailure>>();

    void onScoreUndo(dynamic data) {
      controller.add(
        Either.result(
          ScoreUndoRes.fromJson(Map<String, dynamic>.from(data as Map)),
        ),
      );
    }

    socket.on('score:undo', onScoreUndo);

    controller.onCancel = () async {
      socket.off('score:undo', onScoreUndo);
      await controller.close();
    };

    return controller.stream;
  }

  /// The `match:complete` event. Deliberately thin — see [MatchCompleteRes] —
  /// so this exists to trigger navigation to the result screen, not to feed
  /// it; the result screen itself always loads from `GET .../scorecard`.
  ///
  /// For the scorer's own console this is a recovery path, not the primary
  /// trigger: [ScoreBallRes.matchComplete] on the score-ball ack already
  /// carries the same fact. It matters when that ack is lost on patchy
  /// signal — the same reasoning as [watchOverComplete].
  Stream<Either<MatchCompleteRes, CricketFailure>> watchMatchComplete(
    String matchId,
  ) {
    final socket = socketClientService.socket;
    final controller =
        StreamController<Either<MatchCompleteRes, CricketFailure>>();

    void onMatchComplete(dynamic data) {
      controller.add(
        Either.result(
          MatchCompleteRes.fromJson(Map<String, dynamic>.from(data as Map)),
        ),
      );
    }

    socket.on('match:complete', onMatchComplete);

    controller.onCancel = () async {
      socket.off('match:complete', onMatchComplete);
      await controller.close();
    };

    return controller.stream;
  }

  /// The `match:abandoned` event — a live/innings-break match called off
  /// (rain, a no-show) rather than finished. Only the spectator screen
  /// subscribes to this: the scorer's own console already gets the same fact
  /// from `POST .../abandon`'s REST ack, the same asymmetry as
  /// [watchScoreUndo].
  Stream<Either<MatchAbandonedRes, CricketFailure>> watchMatchAbandoned(
    String matchId,
  ) {
    final socket = socketClientService.socket;
    final controller =
        StreamController<Either<MatchAbandonedRes, CricketFailure>>();

    void onMatchAbandoned(dynamic data) {
      controller.add(
        Either.result(
          MatchAbandonedRes.fromJson(Map<String, dynamic>.from(data as Map)),
        ),
      );
    }

    socket.on('match:abandoned', onMatchAbandoned);

    controller.onCancel = () async {
      socket.off('match:abandoned', onMatchAbandoned);
      await controller.close();
    };

    return controller.stream;
  }
}
