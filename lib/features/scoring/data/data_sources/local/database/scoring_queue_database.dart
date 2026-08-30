import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'scoring_queue_database.g.dart';

/// The queued events waiting to reach `/v1/match/:matchId/sync`, plus one
/// row per innings holding the sync protocol's own bookkeeping
/// (`baseAbsoluteBallSeq`, `lastBallEventId`) across an app restart. See
/// `OfflineSyncService` for how these are used.
///
/// `QueuedSyncEvents` is deliberately one wide table rather than three
/// narrow ones: a row already branches on [eventType], so `payloadJson`
/// reusing `ScoreBallReq`/`SelectBowlerReq`'s own `toJson()` means this table
/// can never drift from the wire shape those DTOs already define — no
/// migration risk if either gains a field later.
enum SyncEventType { ball, bowler, undo }

@DataClassName('QueuedSyncEvent')
class QueuedSyncEvents extends Table {
  /// Autoincrement, so insertion order IS FIFO order — no separate sequence
  /// column needed to replay a batch in the order it was queued.
  IntColumn get id => integer().autoIncrement()();

  TextColumn get matchId => text()();

  /// A batch is innings-scoped and can never cross a boundary — this is what
  /// lets the DAO fetch/flush per innings and detect that boundary.
  IntColumn get inningsNumber => integer()();

  TextColumn get eventType => textEnum<SyncEventType>()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// `ball` rows only. Minted ONCE, at enqueue time, and reused verbatim on
  /// every sync attempt — never regenerated on retry. This is what makes a
  /// retried batch idempotent on the server: the same key means the same
  /// delivery, however many times it is resent.
  TextColumn get idempotencyKey => text().nullable()();

  /// `ball`/`bowler` rows: the request's own `toJson()` — `ScoreBallReq` or
  /// `SelectBowlerReq`, decoded back into the same type when building a
  /// batch.
  TextColumn get payloadJson => text().nullable()();

  /// `undo` rows only: the server id of an ALREADY-SYNCED ball being undone.
  /// A still-queued ball is never represented here at all — undoing it just
  /// deletes its row (see `OfflineSyncService.enqueueUndo`'s caller) — so
  /// this column existing on a row is itself proof the ball it targets was
  /// synced before the undo happened.
  TextColumn get ballEventId => text().nullable()();

  /// `ball`/`bowler` rows: [PreEventState.toJson] as it stood immediately
  /// BEFORE this event — the server's own append-only-snapshot pattern,
  /// mirrored here for two reasons: it lets a local-only undo of a still-
  /// queued ball roll the provisional tally back in O(1), no replay needed,
  /// and the OLDEST queued row's copy is what anchors a full replay after a
  /// cold app relaunch that happens while still offline (see
  /// `OfflineSyncService.currentProvisionalState`) — captured on a `bowler`
  /// row too, not just `ball`, so that anchor exists even when the first
  /// thing queued after going offline was a bowler selection.
  TextColumn get preEventStateJson => text().nullable()();
}

/// One row per (matchId, inningsNumber) — NOT a running-totals checkpoint.
/// `currentProvisionalState`'s replay anchor comes from the oldest queued
/// row's own `preEventStateJson` instead (see that column's doc comment);
/// once the queue is empty the controller's live in-memory state is already
/// correct and this table has nothing useful left to add. What genuinely
/// cannot be re-derived after an app restart is the sync protocol's own
/// bookkeeping: [baseAbsoluteBallSeq] (without it a fresh batch would look
/// like a huge, spurious gap and be flagged a conflict) and
/// [lastBallEventId] (what an undo of an already-synced ball targets).
/// Upserted only when a `/sync` response actually lands.
@DataClassName('SyncBaselineData')
class SyncBaseline extends Table {
  TextColumn get matchId => text()();
  IntColumn get inningsNumber => integer()();

  IntColumn get baseAbsoluteBallSeq => integer()();

  /// The most recently synced ball's server id, if any — what an undo of a
  /// batch-synced delivery targets. Null until at least one ball has synced
  /// for this innings.
  TextColumn get lastBallEventId => text().nullable()();

  @override
  Set<Column> get primaryKey => {matchId, inningsNumber};
}

/// Per-innings ball-by-ball pre-state ledger — a client-side mirror of the
/// server's own append-only `BallEvent.preEventState` history, needed so an
/// offline undo can keep going indefinitely (chained undos of already-synced
/// balls, not just the single most recent one) without a network round trip.
///
/// Deliberately its own table rather than folded into [QueuedSyncEvents]:
/// that table's whole contract is FIFO-and-delete-on-commit (a row's job
/// ends the moment it's flushed or removed), while a history row must
/// OUTLIVE sync and only dies at an innings boundary or a conflict-discard.
/// Mixing those two retention policies in one table risks a future
/// `clearQueue`-shaped call silently taking history down with it.
@DataClassName('BallHistoryEntry')
class BallHistory extends Table {
  /// Autoincrement, so insertion order IS ball order — the same FIFO trick
  /// [QueuedSyncEvents.id] uses, here read newest-first (a stack) since undo
  /// only ever targets the most recent entry.
  IntColumn get id => integer().autoIncrement()();

  TextColumn get matchId => text()();
  IntColumn get inningsNumber => integer()();

  /// The server id this ball can be targeted by, once known. Null until
  /// resolved — only the entry currently on TOP of the stack ever needs one,
  /// since undo is always most-recent-only; see `ScoreBallController`'s
  /// three-way `undoLastBall` branch for how a null here falls back to
  /// `SyncBaseline.lastBallEventId`.
  TextColumn get ballEventId => text().nullable()();

  /// [PreEventState.toJson] as it stood immediately BEFORE this ball —
  /// exactly what `QueuedSyncEvents.preEventStateJson` already captures for a
  /// still-queued row, just kept around after that row is deleted on flush
  /// instead of being thrown away with it.
  TextColumn get preEventStateJson => text()();
}

/// A local-only marker for opening the NEXT innings while offline. Never
/// transmitted to `/sync` — the wire protocol has no `start-innings` event
/// type (a batch can't cross an innings boundary) — this is purely what lets
/// the reconnect chain in `OfflineSyncService` know to call the real
/// `start-innings` endpoint, with these cached names, once connectivity
/// returns and the prior innings' tail has flushed.
@DataClassName('PendingStartInnings')
class PendingStartInningsTable extends Table {
  TextColumn get matchId => text()();
  IntColumn get inningsNumber => integer()();
  TextColumn get strikerName => text()();
  TextColumn get nonStrikerName => text()();
  TextColumn get bowlerName => text()();

  @override
  Set<Column> get primaryKey => {matchId, inningsNumber};
}

/// An innings' final totals, kept around past the point the console resets
/// its live fields to zero for the next innings. Nothing else remembers
/// this: `ScoreBallController`'s Rx fields are overwritten the moment
/// innings 2 starts, but the target for innings 2 (`runs + 1`) and the
/// eventual match-result margin both need innings 1's numbers to still be
/// readable at that point — including entirely offline, when there is no
/// server response to re-fetch them from.
@DataClassName('InningsSummary')
class InningsSummaries extends Table {
  TextColumn get matchId => text()();
  IntColumn get inningsNumber => integer()();
  TextColumn get battingTeam => text()();
  IntColumn get totalRuns => integer()();
  IntColumn get wickets => integer()();
  TextColumn get overs => text()();

  @override
  Set<Column> get primaryKey => {matchId, inningsNumber};
}

/// A locally-computed win/margin, held only until the real, server-confirmed
/// scorecard becomes fetchable. `ResultController` is a separate route with
/// no access to `ScoreBallController`'s in-memory state, and the app can be
/// killed while sitting on this screen offline — so this has to be
/// persisted, not passed as navigation arguments.
@DataClassName('ProvisionalMatchResult')
class ProvisionalMatchResults extends Table {
  TextColumn get matchId => text()();
  TextColumn get winner => text()();
  TextColumn get marginType => text().nullable()();
  IntColumn get margin => integer().nullable()();

  @override
  Set<Column> get primaryKey => {matchId};
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'scoring_queue.db'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(
  tables: [
    QueuedSyncEvents,
    SyncBaseline,
    BallHistory,
    PendingStartInningsTable,
    InningsSummaries,
    ProvisionalMatchResults,
  ],
)
class ScoringQueueDatabase extends _$ScoringQueueDatabase {
  ScoringQueueDatabase() : super(_openConnection());

  /// Test-only seam: the default constructor hardcodes a real on-disk file
  /// via `path_provider`, which isn't available outside a running app. Tests
  /// pass an in-memory [QueryExecutor] instead.
  @visibleForTesting
  ScoringQueueDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(ballHistory);
        await m.createTable(pendingStartInningsTable);
        await m.createTable(inningsSummaries);
        await m.createTable(provisionalMatchResults);
      }
    },
  );
}
