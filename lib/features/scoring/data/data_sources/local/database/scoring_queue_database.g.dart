// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scoring_queue_database.dart';

// ignore_for_file: type=lint
class $QueuedSyncEventsTable extends QueuedSyncEvents
    with TableInfo<$QueuedSyncEventsTable, QueuedSyncEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueuedSyncEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
    'match_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inningsNumberMeta = const VerificationMeta(
    'inningsNumber',
  );
  @override
  late final GeneratedColumn<int> inningsNumber = GeneratedColumn<int>(
    'innings_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncEventType, String> eventType =
      GeneratedColumn<String>(
        'event_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SyncEventType>(
        $QueuedSyncEventsTable.$convertereventType,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ballEventIdMeta = const VerificationMeta(
    'ballEventId',
  );
  @override
  late final GeneratedColumn<String> ballEventId = GeneratedColumn<String>(
    'ball_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preEventStateJsonMeta = const VerificationMeta(
    'preEventStateJson',
  );
  @override
  late final GeneratedColumn<String> preEventStateJson =
      GeneratedColumn<String>(
        'pre_event_state_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    matchId,
    inningsNumber,
    eventType,
    createdAt,
    idempotencyKey,
    payloadJson,
    ballEventId,
    preEventStateJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queued_sync_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueuedSyncEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('innings_number')) {
      context.handle(
        _inningsNumberMeta,
        inningsNumber.isAcceptableOrUnknown(
          data['innings_number']!,
          _inningsNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inningsNumberMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('ball_event_id')) {
      context.handle(
        _ballEventIdMeta,
        ballEventId.isAcceptableOrUnknown(
          data['ball_event_id']!,
          _ballEventIdMeta,
        ),
      );
    }
    if (data.containsKey('pre_event_state_json')) {
      context.handle(
        _preEventStateJsonMeta,
        preEventStateJson.isAcceptableOrUnknown(
          data['pre_event_state_json']!,
          _preEventStateJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueuedSyncEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueuedSyncEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_id'],
      )!,
      inningsNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}innings_number'],
      )!,
      eventType: $QueuedSyncEventsTable.$convertereventType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}event_type'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      ),
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      ),
      ballEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ball_event_id'],
      ),
      preEventStateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pre_event_state_json'],
      ),
    );
  }

  @override
  $QueuedSyncEventsTable createAlias(String alias) {
    return $QueuedSyncEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncEventType, String, String> $convertereventType =
      const EnumNameConverter<SyncEventType>(SyncEventType.values);
}

class QueuedSyncEvent extends DataClass implements Insertable<QueuedSyncEvent> {
  /// Autoincrement, so insertion order IS FIFO order — no separate sequence
  /// column needed to replay a batch in the order it was queued.
  final int id;
  final String matchId;

  /// A batch is innings-scoped and can never cross a boundary — this is what
  /// lets the DAO fetch/flush per innings and detect that boundary.
  final int inningsNumber;
  final SyncEventType eventType;
  final DateTime createdAt;

  /// `ball` rows only. Minted ONCE, at enqueue time, and reused verbatim on
  /// every sync attempt — never regenerated on retry. This is what makes a
  /// retried batch idempotent on the server: the same key means the same
  /// delivery, however many times it is resent.
  final String? idempotencyKey;

  /// `ball`/`bowler` rows: the request's own `toJson()` — `ScoreBallReq` or
  /// `SelectBowlerReq`, decoded back into the same type when building a
  /// batch.
  final String? payloadJson;

  /// `undo` rows only: the server id of an ALREADY-SYNCED ball being undone.
  /// A still-queued ball is never represented here at all — undoing it just
  /// deletes its row (see `OfflineSyncService.enqueueUndo`'s caller) — so
  /// this column existing on a row is itself proof the ball it targets was
  /// synced before the undo happened.
  final String? ballEventId;

  /// `ball`/`bowler` rows: [PreEventState.toJson] as it stood immediately
  /// BEFORE this event — the server's own append-only-snapshot pattern,
  /// mirrored here for two reasons: it lets a local-only undo of a still-
  /// queued ball roll the provisional tally back in O(1), no replay needed,
  /// and the OLDEST queued row's copy is what anchors a full replay after a
  /// cold app relaunch that happens while still offline (see
  /// `OfflineSyncService.currentProvisionalState`) — captured on a `bowler`
  /// row too, not just `ball`, so that anchor exists even when the first
  /// thing queued after going offline was a bowler selection.
  final String? preEventStateJson;
  const QueuedSyncEvent({
    required this.id,
    required this.matchId,
    required this.inningsNumber,
    required this.eventType,
    required this.createdAt,
    this.idempotencyKey,
    this.payloadJson,
    this.ballEventId,
    this.preEventStateJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['match_id'] = Variable<String>(matchId);
    map['innings_number'] = Variable<int>(inningsNumber);
    {
      map['event_type'] = Variable<String>(
        $QueuedSyncEventsTable.$convertereventType.toSql(eventType),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || idempotencyKey != null) {
      map['idempotency_key'] = Variable<String>(idempotencyKey);
    }
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    if (!nullToAbsent || ballEventId != null) {
      map['ball_event_id'] = Variable<String>(ballEventId);
    }
    if (!nullToAbsent || preEventStateJson != null) {
      map['pre_event_state_json'] = Variable<String>(preEventStateJson);
    }
    return map;
  }

  QueuedSyncEventsCompanion toCompanion(bool nullToAbsent) {
    return QueuedSyncEventsCompanion(
      id: Value(id),
      matchId: Value(matchId),
      inningsNumber: Value(inningsNumber),
      eventType: Value(eventType),
      createdAt: Value(createdAt),
      idempotencyKey: idempotencyKey == null && nullToAbsent
          ? const Value.absent()
          : Value(idempotencyKey),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
      ballEventId: ballEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(ballEventId),
      preEventStateJson: preEventStateJson == null && nullToAbsent
          ? const Value.absent()
          : Value(preEventStateJson),
    );
  }

  factory QueuedSyncEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueuedSyncEvent(
      id: serializer.fromJson<int>(json['id']),
      matchId: serializer.fromJson<String>(json['matchId']),
      inningsNumber: serializer.fromJson<int>(json['inningsNumber']),
      eventType: $QueuedSyncEventsTable.$convertereventType.fromJson(
        serializer.fromJson<String>(json['eventType']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      idempotencyKey: serializer.fromJson<String?>(json['idempotencyKey']),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
      ballEventId: serializer.fromJson<String?>(json['ballEventId']),
      preEventStateJson: serializer.fromJson<String?>(
        json['preEventStateJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'matchId': serializer.toJson<String>(matchId),
      'inningsNumber': serializer.toJson<int>(inningsNumber),
      'eventType': serializer.toJson<String>(
        $QueuedSyncEventsTable.$convertereventType.toJson(eventType),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'idempotencyKey': serializer.toJson<String?>(idempotencyKey),
      'payloadJson': serializer.toJson<String?>(payloadJson),
      'ballEventId': serializer.toJson<String?>(ballEventId),
      'preEventStateJson': serializer.toJson<String?>(preEventStateJson),
    };
  }

  QueuedSyncEvent copyWith({
    int? id,
    String? matchId,
    int? inningsNumber,
    SyncEventType? eventType,
    DateTime? createdAt,
    Value<String?> idempotencyKey = const Value.absent(),
    Value<String?> payloadJson = const Value.absent(),
    Value<String?> ballEventId = const Value.absent(),
    Value<String?> preEventStateJson = const Value.absent(),
  }) => QueuedSyncEvent(
    id: id ?? this.id,
    matchId: matchId ?? this.matchId,
    inningsNumber: inningsNumber ?? this.inningsNumber,
    eventType: eventType ?? this.eventType,
    createdAt: createdAt ?? this.createdAt,
    idempotencyKey: idempotencyKey.present
        ? idempotencyKey.value
        : this.idempotencyKey,
    payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
    ballEventId: ballEventId.present ? ballEventId.value : this.ballEventId,
    preEventStateJson: preEventStateJson.present
        ? preEventStateJson.value
        : this.preEventStateJson,
  );
  QueuedSyncEvent copyWithCompanion(QueuedSyncEventsCompanion data) {
    return QueuedSyncEvent(
      id: data.id.present ? data.id.value : this.id,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      inningsNumber: data.inningsNumber.present
          ? data.inningsNumber.value
          : this.inningsNumber,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      ballEventId: data.ballEventId.present
          ? data.ballEventId.value
          : this.ballEventId,
      preEventStateJson: data.preEventStateJson.present
          ? data.preEventStateJson.value
          : this.preEventStateJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueuedSyncEvent(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('inningsNumber: $inningsNumber, ')
          ..write('eventType: $eventType, ')
          ..write('createdAt: $createdAt, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('ballEventId: $ballEventId, ')
          ..write('preEventStateJson: $preEventStateJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    matchId,
    inningsNumber,
    eventType,
    createdAt,
    idempotencyKey,
    payloadJson,
    ballEventId,
    preEventStateJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueuedSyncEvent &&
          other.id == this.id &&
          other.matchId == this.matchId &&
          other.inningsNumber == this.inningsNumber &&
          other.eventType == this.eventType &&
          other.createdAt == this.createdAt &&
          other.idempotencyKey == this.idempotencyKey &&
          other.payloadJson == this.payloadJson &&
          other.ballEventId == this.ballEventId &&
          other.preEventStateJson == this.preEventStateJson);
}

class QueuedSyncEventsCompanion extends UpdateCompanion<QueuedSyncEvent> {
  final Value<int> id;
  final Value<String> matchId;
  final Value<int> inningsNumber;
  final Value<SyncEventType> eventType;
  final Value<DateTime> createdAt;
  final Value<String?> idempotencyKey;
  final Value<String?> payloadJson;
  final Value<String?> ballEventId;
  final Value<String?> preEventStateJson;
  const QueuedSyncEventsCompanion({
    this.id = const Value.absent(),
    this.matchId = const Value.absent(),
    this.inningsNumber = const Value.absent(),
    this.eventType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.ballEventId = const Value.absent(),
    this.preEventStateJson = const Value.absent(),
  });
  QueuedSyncEventsCompanion.insert({
    this.id = const Value.absent(),
    required String matchId,
    required int inningsNumber,
    required SyncEventType eventType,
    this.createdAt = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.ballEventId = const Value.absent(),
    this.preEventStateJson = const Value.absent(),
  }) : matchId = Value(matchId),
       inningsNumber = Value(inningsNumber),
       eventType = Value(eventType);
  static Insertable<QueuedSyncEvent> custom({
    Expression<int>? id,
    Expression<String>? matchId,
    Expression<int>? inningsNumber,
    Expression<String>? eventType,
    Expression<DateTime>? createdAt,
    Expression<String>? idempotencyKey,
    Expression<String>? payloadJson,
    Expression<String>? ballEventId,
    Expression<String>? preEventStateJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (matchId != null) 'match_id': matchId,
      if (inningsNumber != null) 'innings_number': inningsNumber,
      if (eventType != null) 'event_type': eventType,
      if (createdAt != null) 'created_at': createdAt,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (ballEventId != null) 'ball_event_id': ballEventId,
      if (preEventStateJson != null) 'pre_event_state_json': preEventStateJson,
    });
  }

  QueuedSyncEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? matchId,
    Value<int>? inningsNumber,
    Value<SyncEventType>? eventType,
    Value<DateTime>? createdAt,
    Value<String?>? idempotencyKey,
    Value<String?>? payloadJson,
    Value<String?>? ballEventId,
    Value<String?>? preEventStateJson,
  }) {
    return QueuedSyncEventsCompanion(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      inningsNumber: inningsNumber ?? this.inningsNumber,
      eventType: eventType ?? this.eventType,
      createdAt: createdAt ?? this.createdAt,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      payloadJson: payloadJson ?? this.payloadJson,
      ballEventId: ballEventId ?? this.ballEventId,
      preEventStateJson: preEventStateJson ?? this.preEventStateJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (inningsNumber.present) {
      map['innings_number'] = Variable<int>(inningsNumber.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(
        $QueuedSyncEventsTable.$convertereventType.toSql(eventType.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (ballEventId.present) {
      map['ball_event_id'] = Variable<String>(ballEventId.value);
    }
    if (preEventStateJson.present) {
      map['pre_event_state_json'] = Variable<String>(preEventStateJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueuedSyncEventsCompanion(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('inningsNumber: $inningsNumber, ')
          ..write('eventType: $eventType, ')
          ..write('createdAt: $createdAt, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('ballEventId: $ballEventId, ')
          ..write('preEventStateJson: $preEventStateJson')
          ..write(')'))
        .toString();
  }
}

class $SyncBaselineTable extends SyncBaseline
    with TableInfo<$SyncBaselineTable, SyncBaselineData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncBaselineTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
    'match_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inningsNumberMeta = const VerificationMeta(
    'inningsNumber',
  );
  @override
  late final GeneratedColumn<int> inningsNumber = GeneratedColumn<int>(
    'innings_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseAbsoluteBallSeqMeta =
      const VerificationMeta('baseAbsoluteBallSeq');
  @override
  late final GeneratedColumn<int> baseAbsoluteBallSeq = GeneratedColumn<int>(
    'base_absolute_ball_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastBallEventIdMeta = const VerificationMeta(
    'lastBallEventId',
  );
  @override
  late final GeneratedColumn<String> lastBallEventId = GeneratedColumn<String>(
    'last_ball_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    matchId,
    inningsNumber,
    baseAbsoluteBallSeq,
    lastBallEventId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_baseline';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncBaselineData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('innings_number')) {
      context.handle(
        _inningsNumberMeta,
        inningsNumber.isAcceptableOrUnknown(
          data['innings_number']!,
          _inningsNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inningsNumberMeta);
    }
    if (data.containsKey('base_absolute_ball_seq')) {
      context.handle(
        _baseAbsoluteBallSeqMeta,
        baseAbsoluteBallSeq.isAcceptableOrUnknown(
          data['base_absolute_ball_seq']!,
          _baseAbsoluteBallSeqMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseAbsoluteBallSeqMeta);
    }
    if (data.containsKey('last_ball_event_id')) {
      context.handle(
        _lastBallEventIdMeta,
        lastBallEventId.isAcceptableOrUnknown(
          data['last_ball_event_id']!,
          _lastBallEventIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {matchId, inningsNumber};
  @override
  SyncBaselineData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncBaselineData(
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_id'],
      )!,
      inningsNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}innings_number'],
      )!,
      baseAbsoluteBallSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_absolute_ball_seq'],
      )!,
      lastBallEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_ball_event_id'],
      ),
    );
  }

  @override
  $SyncBaselineTable createAlias(String alias) {
    return $SyncBaselineTable(attachedDatabase, alias);
  }
}

class SyncBaselineData extends DataClass
    implements Insertable<SyncBaselineData> {
  final String matchId;
  final int inningsNumber;
  final int baseAbsoluteBallSeq;

  /// The most recently synced ball's server id, if any — what an undo of a
  /// batch-synced delivery targets. Null until at least one ball has synced
  /// for this innings.
  final String? lastBallEventId;
  const SyncBaselineData({
    required this.matchId,
    required this.inningsNumber,
    required this.baseAbsoluteBallSeq,
    this.lastBallEventId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['match_id'] = Variable<String>(matchId);
    map['innings_number'] = Variable<int>(inningsNumber);
    map['base_absolute_ball_seq'] = Variable<int>(baseAbsoluteBallSeq);
    if (!nullToAbsent || lastBallEventId != null) {
      map['last_ball_event_id'] = Variable<String>(lastBallEventId);
    }
    return map;
  }

  SyncBaselineCompanion toCompanion(bool nullToAbsent) {
    return SyncBaselineCompanion(
      matchId: Value(matchId),
      inningsNumber: Value(inningsNumber),
      baseAbsoluteBallSeq: Value(baseAbsoluteBallSeq),
      lastBallEventId: lastBallEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBallEventId),
    );
  }

  factory SyncBaselineData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncBaselineData(
      matchId: serializer.fromJson<String>(json['matchId']),
      inningsNumber: serializer.fromJson<int>(json['inningsNumber']),
      baseAbsoluteBallSeq: serializer.fromJson<int>(
        json['baseAbsoluteBallSeq'],
      ),
      lastBallEventId: serializer.fromJson<String?>(json['lastBallEventId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'matchId': serializer.toJson<String>(matchId),
      'inningsNumber': serializer.toJson<int>(inningsNumber),
      'baseAbsoluteBallSeq': serializer.toJson<int>(baseAbsoluteBallSeq),
      'lastBallEventId': serializer.toJson<String?>(lastBallEventId),
    };
  }

  SyncBaselineData copyWith({
    String? matchId,
    int? inningsNumber,
    int? baseAbsoluteBallSeq,
    Value<String?> lastBallEventId = const Value.absent(),
  }) => SyncBaselineData(
    matchId: matchId ?? this.matchId,
    inningsNumber: inningsNumber ?? this.inningsNumber,
    baseAbsoluteBallSeq: baseAbsoluteBallSeq ?? this.baseAbsoluteBallSeq,
    lastBallEventId: lastBallEventId.present
        ? lastBallEventId.value
        : this.lastBallEventId,
  );
  SyncBaselineData copyWithCompanion(SyncBaselineCompanion data) {
    return SyncBaselineData(
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      inningsNumber: data.inningsNumber.present
          ? data.inningsNumber.value
          : this.inningsNumber,
      baseAbsoluteBallSeq: data.baseAbsoluteBallSeq.present
          ? data.baseAbsoluteBallSeq.value
          : this.baseAbsoluteBallSeq,
      lastBallEventId: data.lastBallEventId.present
          ? data.lastBallEventId.value
          : this.lastBallEventId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncBaselineData(')
          ..write('matchId: $matchId, ')
          ..write('inningsNumber: $inningsNumber, ')
          ..write('baseAbsoluteBallSeq: $baseAbsoluteBallSeq, ')
          ..write('lastBallEventId: $lastBallEventId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(matchId, inningsNumber, baseAbsoluteBallSeq, lastBallEventId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncBaselineData &&
          other.matchId == this.matchId &&
          other.inningsNumber == this.inningsNumber &&
          other.baseAbsoluteBallSeq == this.baseAbsoluteBallSeq &&
          other.lastBallEventId == this.lastBallEventId);
}

class SyncBaselineCompanion extends UpdateCompanion<SyncBaselineData> {
  final Value<String> matchId;
  final Value<int> inningsNumber;
  final Value<int> baseAbsoluteBallSeq;
  final Value<String?> lastBallEventId;
  final Value<int> rowid;
  const SyncBaselineCompanion({
    this.matchId = const Value.absent(),
    this.inningsNumber = const Value.absent(),
    this.baseAbsoluteBallSeq = const Value.absent(),
    this.lastBallEventId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncBaselineCompanion.insert({
    required String matchId,
    required int inningsNumber,
    required int baseAbsoluteBallSeq,
    this.lastBallEventId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : matchId = Value(matchId),
       inningsNumber = Value(inningsNumber),
       baseAbsoluteBallSeq = Value(baseAbsoluteBallSeq);
  static Insertable<SyncBaselineData> custom({
    Expression<String>? matchId,
    Expression<int>? inningsNumber,
    Expression<int>? baseAbsoluteBallSeq,
    Expression<String>? lastBallEventId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (matchId != null) 'match_id': matchId,
      if (inningsNumber != null) 'innings_number': inningsNumber,
      if (baseAbsoluteBallSeq != null)
        'base_absolute_ball_seq': baseAbsoluteBallSeq,
      if (lastBallEventId != null) 'last_ball_event_id': lastBallEventId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncBaselineCompanion copyWith({
    Value<String>? matchId,
    Value<int>? inningsNumber,
    Value<int>? baseAbsoluteBallSeq,
    Value<String?>? lastBallEventId,
    Value<int>? rowid,
  }) {
    return SyncBaselineCompanion(
      matchId: matchId ?? this.matchId,
      inningsNumber: inningsNumber ?? this.inningsNumber,
      baseAbsoluteBallSeq: baseAbsoluteBallSeq ?? this.baseAbsoluteBallSeq,
      lastBallEventId: lastBallEventId ?? this.lastBallEventId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (inningsNumber.present) {
      map['innings_number'] = Variable<int>(inningsNumber.value);
    }
    if (baseAbsoluteBallSeq.present) {
      map['base_absolute_ball_seq'] = Variable<int>(baseAbsoluteBallSeq.value);
    }
    if (lastBallEventId.present) {
      map['last_ball_event_id'] = Variable<String>(lastBallEventId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncBaselineCompanion(')
          ..write('matchId: $matchId, ')
          ..write('inningsNumber: $inningsNumber, ')
          ..write('baseAbsoluteBallSeq: $baseAbsoluteBallSeq, ')
          ..write('lastBallEventId: $lastBallEventId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ScoringQueueDatabase extends GeneratedDatabase {
  _$ScoringQueueDatabase(QueryExecutor e) : super(e);
  $ScoringQueueDatabaseManager get managers =>
      $ScoringQueueDatabaseManager(this);
  late final $QueuedSyncEventsTable queuedSyncEvents = $QueuedSyncEventsTable(
    this,
  );
  late final $SyncBaselineTable syncBaseline = $SyncBaselineTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    queuedSyncEvents,
    syncBaseline,
  ];
}

typedef $$QueuedSyncEventsTableCreateCompanionBuilder =
    QueuedSyncEventsCompanion Function({
      Value<int> id,
      required String matchId,
      required int inningsNumber,
      required SyncEventType eventType,
      Value<DateTime> createdAt,
      Value<String?> idempotencyKey,
      Value<String?> payloadJson,
      Value<String?> ballEventId,
      Value<String?> preEventStateJson,
    });
typedef $$QueuedSyncEventsTableUpdateCompanionBuilder =
    QueuedSyncEventsCompanion Function({
      Value<int> id,
      Value<String> matchId,
      Value<int> inningsNumber,
      Value<SyncEventType> eventType,
      Value<DateTime> createdAt,
      Value<String?> idempotencyKey,
      Value<String?> payloadJson,
      Value<String?> ballEventId,
      Value<String?> preEventStateJson,
    });

class $$QueuedSyncEventsTableFilterComposer
    extends Composer<_$ScoringQueueDatabase, $QueuedSyncEventsTable> {
  $$QueuedSyncEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchId => $composableBuilder(
    column: $table.matchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inningsNumber => $composableBuilder(
    column: $table.inningsNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncEventType, SyncEventType, String>
  get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ballEventId => $composableBuilder(
    column: $table.ballEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preEventStateJson => $composableBuilder(
    column: $table.preEventStateJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QueuedSyncEventsTableOrderingComposer
    extends Composer<_$ScoringQueueDatabase, $QueuedSyncEventsTable> {
  $$QueuedSyncEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchId => $composableBuilder(
    column: $table.matchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inningsNumber => $composableBuilder(
    column: $table.inningsNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ballEventId => $composableBuilder(
    column: $table.ballEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preEventStateJson => $composableBuilder(
    column: $table.preEventStateJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QueuedSyncEventsTableAnnotationComposer
    extends Composer<_$ScoringQueueDatabase, $QueuedSyncEventsTable> {
  $$QueuedSyncEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get matchId =>
      $composableBuilder(column: $table.matchId, builder: (column) => column);

  GeneratedColumn<int> get inningsNumber => $composableBuilder(
    column: $table.inningsNumber,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncEventType, String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ballEventId => $composableBuilder(
    column: $table.ballEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preEventStateJson => $composableBuilder(
    column: $table.preEventStateJson,
    builder: (column) => column,
  );
}

class $$QueuedSyncEventsTableTableManager
    extends
        RootTableManager<
          _$ScoringQueueDatabase,
          $QueuedSyncEventsTable,
          QueuedSyncEvent,
          $$QueuedSyncEventsTableFilterComposer,
          $$QueuedSyncEventsTableOrderingComposer,
          $$QueuedSyncEventsTableAnnotationComposer,
          $$QueuedSyncEventsTableCreateCompanionBuilder,
          $$QueuedSyncEventsTableUpdateCompanionBuilder,
          (
            QueuedSyncEvent,
            BaseReferences<
              _$ScoringQueueDatabase,
              $QueuedSyncEventsTable,
              QueuedSyncEvent
            >,
          ),
          QueuedSyncEvent,
          PrefetchHooks Function()
        > {
  $$QueuedSyncEventsTableTableManager(
    _$ScoringQueueDatabase db,
    $QueuedSyncEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueuedSyncEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueuedSyncEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueuedSyncEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> matchId = const Value.absent(),
                Value<int> inningsNumber = const Value.absent(),
                Value<SyncEventType> eventType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> idempotencyKey = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<String?> ballEventId = const Value.absent(),
                Value<String?> preEventStateJson = const Value.absent(),
              }) => QueuedSyncEventsCompanion(
                id: id,
                matchId: matchId,
                inningsNumber: inningsNumber,
                eventType: eventType,
                createdAt: createdAt,
                idempotencyKey: idempotencyKey,
                payloadJson: payloadJson,
                ballEventId: ballEventId,
                preEventStateJson: preEventStateJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String matchId,
                required int inningsNumber,
                required SyncEventType eventType,
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> idempotencyKey = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<String?> ballEventId = const Value.absent(),
                Value<String?> preEventStateJson = const Value.absent(),
              }) => QueuedSyncEventsCompanion.insert(
                id: id,
                matchId: matchId,
                inningsNumber: inningsNumber,
                eventType: eventType,
                createdAt: createdAt,
                idempotencyKey: idempotencyKey,
                payloadJson: payloadJson,
                ballEventId: ballEventId,
                preEventStateJson: preEventStateJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QueuedSyncEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$ScoringQueueDatabase,
      $QueuedSyncEventsTable,
      QueuedSyncEvent,
      $$QueuedSyncEventsTableFilterComposer,
      $$QueuedSyncEventsTableOrderingComposer,
      $$QueuedSyncEventsTableAnnotationComposer,
      $$QueuedSyncEventsTableCreateCompanionBuilder,
      $$QueuedSyncEventsTableUpdateCompanionBuilder,
      (
        QueuedSyncEvent,
        BaseReferences<
          _$ScoringQueueDatabase,
          $QueuedSyncEventsTable,
          QueuedSyncEvent
        >,
      ),
      QueuedSyncEvent,
      PrefetchHooks Function()
    >;
typedef $$SyncBaselineTableCreateCompanionBuilder =
    SyncBaselineCompanion Function({
      required String matchId,
      required int inningsNumber,
      required int baseAbsoluteBallSeq,
      Value<String?> lastBallEventId,
      Value<int> rowid,
    });
typedef $$SyncBaselineTableUpdateCompanionBuilder =
    SyncBaselineCompanion Function({
      Value<String> matchId,
      Value<int> inningsNumber,
      Value<int> baseAbsoluteBallSeq,
      Value<String?> lastBallEventId,
      Value<int> rowid,
    });

class $$SyncBaselineTableFilterComposer
    extends Composer<_$ScoringQueueDatabase, $SyncBaselineTable> {
  $$SyncBaselineTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get matchId => $composableBuilder(
    column: $table.matchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inningsNumber => $composableBuilder(
    column: $table.inningsNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseAbsoluteBallSeq => $composableBuilder(
    column: $table.baseAbsoluteBallSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastBallEventId => $composableBuilder(
    column: $table.lastBallEventId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncBaselineTableOrderingComposer
    extends Composer<_$ScoringQueueDatabase, $SyncBaselineTable> {
  $$SyncBaselineTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get matchId => $composableBuilder(
    column: $table.matchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inningsNumber => $composableBuilder(
    column: $table.inningsNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseAbsoluteBallSeq => $composableBuilder(
    column: $table.baseAbsoluteBallSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastBallEventId => $composableBuilder(
    column: $table.lastBallEventId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncBaselineTableAnnotationComposer
    extends Composer<_$ScoringQueueDatabase, $SyncBaselineTable> {
  $$SyncBaselineTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get matchId =>
      $composableBuilder(column: $table.matchId, builder: (column) => column);

  GeneratedColumn<int> get inningsNumber => $composableBuilder(
    column: $table.inningsNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseAbsoluteBallSeq => $composableBuilder(
    column: $table.baseAbsoluteBallSeq,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastBallEventId => $composableBuilder(
    column: $table.lastBallEventId,
    builder: (column) => column,
  );
}

class $$SyncBaselineTableTableManager
    extends
        RootTableManager<
          _$ScoringQueueDatabase,
          $SyncBaselineTable,
          SyncBaselineData,
          $$SyncBaselineTableFilterComposer,
          $$SyncBaselineTableOrderingComposer,
          $$SyncBaselineTableAnnotationComposer,
          $$SyncBaselineTableCreateCompanionBuilder,
          $$SyncBaselineTableUpdateCompanionBuilder,
          (
            SyncBaselineData,
            BaseReferences<
              _$ScoringQueueDatabase,
              $SyncBaselineTable,
              SyncBaselineData
            >,
          ),
          SyncBaselineData,
          PrefetchHooks Function()
        > {
  $$SyncBaselineTableTableManager(
    _$ScoringQueueDatabase db,
    $SyncBaselineTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncBaselineTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncBaselineTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncBaselineTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> matchId = const Value.absent(),
                Value<int> inningsNumber = const Value.absent(),
                Value<int> baseAbsoluteBallSeq = const Value.absent(),
                Value<String?> lastBallEventId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncBaselineCompanion(
                matchId: matchId,
                inningsNumber: inningsNumber,
                baseAbsoluteBallSeq: baseAbsoluteBallSeq,
                lastBallEventId: lastBallEventId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String matchId,
                required int inningsNumber,
                required int baseAbsoluteBallSeq,
                Value<String?> lastBallEventId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncBaselineCompanion.insert(
                matchId: matchId,
                inningsNumber: inningsNumber,
                baseAbsoluteBallSeq: baseAbsoluteBallSeq,
                lastBallEventId: lastBallEventId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncBaselineTableProcessedTableManager =
    ProcessedTableManager<
      _$ScoringQueueDatabase,
      $SyncBaselineTable,
      SyncBaselineData,
      $$SyncBaselineTableFilterComposer,
      $$SyncBaselineTableOrderingComposer,
      $$SyncBaselineTableAnnotationComposer,
      $$SyncBaselineTableCreateCompanionBuilder,
      $$SyncBaselineTableUpdateCompanionBuilder,
      (
        SyncBaselineData,
        BaseReferences<
          _$ScoringQueueDatabase,
          $SyncBaselineTable,
          SyncBaselineData
        >,
      ),
      SyncBaselineData,
      PrefetchHooks Function()
    >;

class $ScoringQueueDatabaseManager {
  final _$ScoringQueueDatabase _db;
  $ScoringQueueDatabaseManager(this._db);
  $$QueuedSyncEventsTableTableManager get queuedSyncEvents =>
      $$QueuedSyncEventsTableTableManager(_db, _db.queuedSyncEvents);
  $$SyncBaselineTableTableManager get syncBaseline =>
      $$SyncBaselineTableTableManager(_db, _db.syncBaseline);
}
