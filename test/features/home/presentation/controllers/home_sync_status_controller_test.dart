import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_sync_status_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late StreamController<List<QueuedRow>> queue;
  late StreamController<List<ConnectivityResult>> connectivity;
  late HomeSyncStatusController controller;

  Future<void> boot({
    List<ConnectivityResult> initial = const [ConnectivityResult.wifi],
  }) async {
    queue = StreamController<List<QueuedRow>>.broadcast();
    connectivity = StreamController<List<ConnectivityResult>>.broadcast();
    controller = HomeSyncStatusController(
      queue: queue.stream,
      connectivity: connectivity.stream,
      checkConnectivity: () async => initial,
    )..onInit();
    await Future<void>.delayed(Duration.zero);
  }

  tearDown(() async {
    controller.onClose();
    await queue.close();
    await connectivity.close();
  });

  test('counts only ball rows as balls, but every row as pending', () async {
    await boot();

    queue.add([
      (matchId: 'm1', isBall: true),
      (matchId: 'm1', isBall: true),
      (matchId: 'm1', isBall: false),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(controller.ballCount.value, 2);
    expect(controller.pendingCount.value, 3);
  });

  test('points at the match with the most recently queued row', () async {
    await boot();

    queue.add([(matchId: 'old', isBall: true), (matchId: 'new', isBall: true)]);
    await Future<void>.delayed(Duration.zero);

    expect(controller.pendingMatchId.value, 'new');
  });

  test('clears everything once the queue drains', () async {
    await boot();
    queue.add([(matchId: 'm1', isBall: true)]);
    await Future<void>.delayed(Duration.zero);

    queue.add([]);
    await Future<void>.delayed(Duration.zero);

    expect(controller.pendingCount.value, 0);
    expect(controller.ballCount.value, 0);
    expect(controller.pendingMatchId.value, isNull);
  });

  test('starts offline when the first connectivity check says so', () async {
    await boot(initial: const [ConnectivityResult.none]);

    expect(controller.isOffline.value, isTrue);
  });

  test('follows connectivity changes both ways', () async {
    await boot();
    expect(controller.isOffline.value, isFalse);

    connectivity.add([ConnectivityResult.none]);
    await Future<void>.delayed(Duration.zero);
    expect(controller.isOffline.value, isTrue);

    connectivity.add([ConnectivityResult.mobile]);
    await Future<void>.delayed(Duration.zero);
    expect(controller.isOffline.value, isFalse);
  });
}
