// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scoring_queue_dao.dart';

// ignore_for_file: type=lint
mixin _$ScoringQueueDaoMixin on DatabaseAccessor<ScoringQueueDatabase> {
  $QueuedSyncEventsTable get queuedSyncEvents =>
      attachedDatabase.queuedSyncEvents;
  $SyncBaselineTable get syncBaseline => attachedDatabase.syncBaseline;
  ScoringQueueDaoManager get managers => ScoringQueueDaoManager(this);
}

class ScoringQueueDaoManager {
  final _$ScoringQueueDaoMixin _db;
  ScoringQueueDaoManager(this._db);
  $$QueuedSyncEventsTableTableManager get queuedSyncEvents =>
      $$QueuedSyncEventsTableTableManager(
        _db.attachedDatabase,
        _db.queuedSyncEvents,
      );
  $$SyncBaselineTableTableManager get syncBaseline =>
      $$SyncBaselineTableTableManager(_db.attachedDatabase, _db.syncBaseline);
}
