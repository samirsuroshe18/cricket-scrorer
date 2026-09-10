import 'dart:async';

import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/socket_client_service.dart';
import 'package:cricket_scorer/core/services/secure_storages_service.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_event_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_state_res.dart';
import 'package:get/get.dart';

/// The auction room's real-time half — sibling to `MatchSocketService`,
/// built the same way: reuses the app-wide [SocketClientService] singleton,
/// one broadcast [Stream] per server event, join-on-subscribe /
/// leave-on-cancel for the one stream that owns room membership
/// ([watchState]) — every other stream here assumes it's already joined.
///
/// Unlike match sockets, every outbound event carries the caller's own
/// access token — `auction:join`/`auction:bid` are the one authenticated
/// write path in the whole socket layer (see the backend's
/// `verifySocketAuth`) — read fresh from [SecureStorageService] on every
/// call rather than cached, the same freshness reasoning `AuthInterceptor`
/// already uses for REST.
class AuctionSocketService {
  final SocketClientService socketClientService;

  AuctionSocketService({required this.socketClientService});

  Future<String?> _accessToken() =>
      SecureStorageService.secure.get(SharedPrefKey.accessToken);

  Stream<Either<AuctionStateRes, CricketFailure>> watchState(String tournamentId) {
    final socket = socketClientService.socket;
    final controller = StreamController<Either<AuctionStateRes, CricketFailure>>();

    Future<void> join() async {
      final token = await _accessToken();
      socket.emit('auction:join', {
        'tournamentId': tournamentId,
        'accessToken': token,
        'locale': Get.locale?.languageCode ?? 'en',
      });
    }

    void onState(dynamic data) {
      controller.add(Either.result(AuctionStateRes.fromJson(Map<String, dynamic>.from(data as Map))));
    }

    void onDisconnect(dynamic _) => controller.add(Either.fallback(CricketSocketDisconnectedFailure()));
    void onConnectError(dynamic _) => controller.add(Either.fallback(CricketSocketDisconnectedFailure()));
    void onConnect(dynamic _) => join();

    socket.on('auction:state', onState);
    socket.on('disconnect', onDisconnect);
    socket.on('connect_error', onConnectError);
    socket.on('connect', onConnect);

    join();

    controller.onCancel = () async {
      socket.off('auction:state', onState);
      socket.off('disconnect', onDisconnect);
      socket.off('connect_error', onConnectError);
      socket.off('connect', onConnect);
      socket.emit('auction:leave', {'tournamentId': tournamentId});
      await controller.close();
    };

    return controller.stream;
  }

  /// The one event that tells a socket which joined the room *before* the
  /// organizer started the auction that it's no longer sitting on a null,
  /// not-started session — `auction:lotOnBlock` never carries session
  /// status, only the lot, so without this the room stayed silent forever
  /// for an already-joined viewer.
  Stream<void> watchSessionStarted(String tournamentId) {
    final socket = socketClientService.socket;
    final controller = StreamController<void>();
    void onSessionStarted(dynamic _) => controller.add(null);
    socket.on('auction:sessionStarted', onSessionStarted);
    controller.onCancel = () async {
      socket.off('auction:sessionStarted', onSessionStarted);
      await controller.close();
    };
    return controller.stream;
  }

  Stream<AuctionLotRes> watchLotOnBlock(String tournamentId) {
    final socket = socketClientService.socket;
    final controller = StreamController<AuctionLotRes>();
    void onLotOnBlock(dynamic data) =>
        controller.add(AuctionLotRes.fromJson(Map<String, dynamic>.from(data as Map)));
    socket.on('auction:lotOnBlock', onLotOnBlock);
    controller.onCancel = () async {
      socket.off('auction:lotOnBlock', onLotOnBlock);
      await controller.close();
    };
    return controller.stream;
  }

  Stream<AuctionBidAcceptedRes> watchBidAccepted(String tournamentId) {
    final socket = socketClientService.socket;
    final controller = StreamController<AuctionBidAcceptedRes>();
    void onBidAccepted(dynamic data) =>
        controller.add(AuctionBidAcceptedRes.fromJson(Map<String, dynamic>.from(data as Map)));
    socket.on('auction:bidAccepted', onBidAccepted);
    controller.onCancel = () async {
      socket.off('auction:bidAccepted', onBidAccepted);
      await controller.close();
    };
    return controller.stream;
  }

  /// Rejections are never broadcast — the backend acks only the requesting
  /// socket — so every device's stream here only ever sees its own.
  Stream<AuctionBidRejectedRes> watchBidRejected(String tournamentId) {
    final socket = socketClientService.socket;
    final controller = StreamController<AuctionBidRejectedRes>();
    void onBidRejected(dynamic data) =>
        controller.add(AuctionBidRejectedRes.fromJson(Map<String, dynamic>.from(data as Map)));
    socket.on('auction:bidRejected', onBidRejected);
    controller.onCancel = () async {
      socket.off('auction:bidRejected', onBidRejected);
      await controller.close();
    };
    return controller.stream;
  }

  Stream<AuctionLotResolvedRes> watchLotResolved(String tournamentId) {
    final socket = socketClientService.socket;
    final controller = StreamController<AuctionLotResolvedRes>();
    void onLotResolved(dynamic data) =>
        controller.add(AuctionLotResolvedRes.fromJson(Map<String, dynamic>.from(data as Map)));
    socket.on('auction:lotResolved', onLotResolved);
    controller.onCancel = () async {
      socket.off('auction:lotResolved', onLotResolved);
      await controller.close();
    };
    return controller.stream;
  }

  Stream<void> watchPaused(String tournamentId) {
    final socket = socketClientService.socket;
    final controller = StreamController<void>();
    void onPaused(dynamic _) => controller.add(null);
    socket.on('auction:paused', onPaused);
    controller.onCancel = () async {
      socket.off('auction:paused', onPaused);
      await controller.close();
    };
    return controller.stream;
  }

  Stream<DateTime?> watchResumed(String tournamentId) {
    final socket = socketClientService.socket;
    final controller = StreamController<DateTime?>();
    void onResumed(dynamic data) {
      final res = AuctionResumedRes.fromJson(Map<String, dynamic>.from(data as Map));
      controller.add(res.currentLotEndsAt);
    }
    socket.on('auction:resumed', onResumed);
    controller.onCancel = () async {
      socket.off('auction:resumed', onResumed);
      await controller.close();
    };
    return controller.stream;
  }

  Stream<void> watchSessionCompleted(String tournamentId) {
    final socket = socketClientService.socket;
    final controller = StreamController<void>();
    void onCompleted(dynamic _) => controller.add(null);
    socket.on('auction:sessionCompleted', onCompleted);
    controller.onCancel = () async {
      socket.off('auction:sessionCompleted', onCompleted);
      await controller.close();
    };
    return controller.stream;
  }

  /// Fire-and-forget: the outcome arrives asynchronously via
  /// [watchBidAccepted] or [watchBidRejected], never as a direct return
  /// value here — the server never acks `auction:bid` with anything but
  /// one of those two events.
  Future<void> bid({required String tournamentId, required String lotId}) async {
    final token = await _accessToken();
    socketClientService.socket.emit('auction:bid', {
      'tournamentId': tournamentId,
      'lotId': lotId,
      'accessToken': token,
    });
  }
}
