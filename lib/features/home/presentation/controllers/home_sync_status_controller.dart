import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// One queued offline event, reduced to what Home cares about.
typedef QueuedRow = ({String matchId, bool isBall});

/// What Home shows above its hero when scoring hasn't reached the server yet:
/// how many balls are still waiting in the local queue, whether the device is
/// offline, and which match to open to look into it.
///
/// Read-only — it observes the queue and connectivity, never flushes or
/// discards anything; that stays with `OfflineSyncService` and the scoring
/// console's own sync UI. Its sources are constructor arguments rather than
/// looked-up singletons so a test can drive it with plain streams (the
/// real ones need a database and a platform channel).
class HomeSyncStatusController extends GetxController {
  HomeSyncStatusController({
    required Stream<List<QueuedRow>> queue,
    required Stream<List<ConnectivityResult>> connectivity,
    required Future<List<ConnectivityResult>> Function() checkConnectivity,
  }) : _queue = queue,
       _connectivity = connectivity,
       _checkConnectivity = checkConnectivity;

  final Stream<List<QueuedRow>> _queue;
  final Stream<List<ConnectivityResult>> _connectivity;
  final Future<List<ConnectivityResult>> Function() _checkConnectivity;

  /// Queued `ball` rows — the number the strip quotes.
  final ballCount = 0.obs;

  /// Every queued row, balls or not. Non-zero with [ballCount] at zero means
  /// only bowler changes or undos are waiting.
  final pendingCount = 0.obs;

  /// The match with the most recently queued row — where "Details" goes.
  final pendingMatchId = Rxn<String>();

  final isOffline = false.obs;

  StreamSubscription<List<QueuedRow>>? _queueSub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  void onInit() {
    super.onInit();
    _queueSub = _queue.listen(_onQueue);
    _connectivitySub = _connectivity.listen(_onConnectivity);
    unawaited(_checkConnectivity().then(_onConnectivity));
  }

  @override
  void onClose() {
    unawaited(_queueSub?.cancel());
    unawaited(_connectivitySub?.cancel());
    super.onClose();
  }

  void _onQueue(List<QueuedRow> rows) {
    pendingCount.value = rows.length;
    ballCount.value = rows.where((row) => row.isBall).length;
    pendingMatchId.value = rows.isEmpty ? null : rows.last.matchId;
  }

  void _onConnectivity(List<ConnectivityResult> results) {
    isOffline.value =
        results.isEmpty || results.every((r) => r == ConnectivityResult.none);
  }
}
