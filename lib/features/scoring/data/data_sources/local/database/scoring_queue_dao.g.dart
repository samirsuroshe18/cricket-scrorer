// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scoring_queue_dao.dart';

// ignore_for_file: type=lint
mixin _$ScoringQueueDaoMixin on DatabaseAccessor<ScoringQueueDatabase> {
  $QueuedSyncEventsTable get queuedSyncEvents =>
      attachedDatabase.queuedSyncEvents;
  $SyncBaselineTable get syncBaseline => attachedDatabase.syncBaseline;
  $BallHistoryTable get ballHistory => attachedDatabase.ballHistory;
  $PendingStartInningsTableTable get pendingStartInningsTable =>
      attachedDatabase.pendingStartInningsTable;
  $InningsSummariesTable get inningsSummaries =>
      attachedDatabase.inningsSummaries;
  $ProvisionalMatchResultsTable get provisionalMatchResults =>
      attachedDatabase.provisionalMatchResults;
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
  $$BallHistoryTableTableManager get ballHistory =>
      $$BallHistoryTableTableManager(_db.attachedDatabase, _db.ballHistory);
  $$PendingStartInningsTableTableTableManager get pendingStartInningsTable =>
      $$PendingStartInningsTableTableTableManager(
        _db.attachedDatabase,
        _db.pendingStartInningsTable,
      );
  $$InningsSummariesTableTableManager get inningsSummaries =>
      $$InningsSummariesTableTableManager(
        _db.attachedDatabase,
        _db.inningsSummaries,
      );
  $$ProvisionalMatchResultsTableTableManager get provisionalMatchResults =>
      $$ProvisionalMatchResultsTableTableManager(
        _db.attachedDatabase,
        _db.provisionalMatchResults,
      );
}
