import 'dart:async';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/socket_client_service.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/live_score_res.dart';

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
      await controller.close();
    };

    return controller.stream;
  }
}
