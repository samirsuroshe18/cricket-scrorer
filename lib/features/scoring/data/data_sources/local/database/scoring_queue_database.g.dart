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

class $BallHistoryTable extends BallHistory
    with TableInfo<$BallHistoryTable, BallHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BallHistoryTable(this.attachedDatabase, [this._alias]);
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
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    matchId,
    inningsNumber,
    ballEventId,
    preEventStateJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ball_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<BallHistoryEntry> instance, {
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
    } else if (isInserting) {
      context.missing(_preEventStateJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BallHistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BallHistoryEntry(
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
      ballEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ball_event_id'],
      ),
      preEventStateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pre_event_state_json'],
      )!,
    );
  }

  @override
  $BallHistoryTable createAlias(String alias) {
    return $BallHistoryTable(attachedDatabase, alias);
  }
}

class BallHistoryEntry extends DataClass
    implements Insertable<BallHistoryEntry> {
  /// Autoincrement, so insertion order IS ball order — the same FIFO trick
  /// [QueuedSyncEvents.id] uses, here read newest-first (a stack) since undo
  /// only ever targets the most recent entry.
  final int id;
  final String matchId;
  final int inningsNumber;

  /// The server id this ball can be targeted by, once known. Null until
  /// resolved — only the entry currently on TOP of the stack ever needs one,
  /// since undo is always most-recent-only; see `ScoreBallController`'s
  /// three-way `undoLastBall` branch for how a null here falls back to
  /// `SyncBaseline.lastBallEventId`.
  final String? ballEventId;

  /// [PreEventState.toJson] as it stood immediately BEFORE this ball —
  /// exactly what `QueuedSyncEvents.preEventStateJson` already captures for a
  /// still-queued row, just kept around after that row is deleted on flush
  /// instead of being thrown away with it.
  final String preEventStateJson;
  const BallHistoryEntry({
    required this.id,
    required this.matchId,
    required this.inningsNumber,
    this.ballEventId,
    required this.preEventStateJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['match_id'] = Variable<String>(matchId);
    map['innings_number'] = Variable<int>(inningsNumber);
    if (!nullToAbsent || ballEventId != null) {
      map['ball_event_id'] = Variable<String>(ballEventId);
    }
    map['pre_event_state_json'] = Variable<String>(preEventStateJson);
    return map;
  }

  BallHistoryCompanion toCompanion(bool nullToAbsent) {
    return BallHistoryCompanion(
      id: Value(id),
      matchId: Value(matchId),
      inningsNumber: Value(inningsNumber),
      ballEventId: ballEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(ballEventId),
      preEventStateJson: Value(preEventStateJson),
    );
  }

  factory BallHistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BallHistoryEntry(
      id: serializer.fromJson<int>(json['id']),
      matchId: serializer.fromJson<String>(json['matchId']),
      inningsNumber: serializer.fromJson<int>(json['inningsNumber']),
      ballEventId: serializer.fromJson<String?>(json['ballEventId']),
      preEventStateJson: serializer.fromJson<String>(json['preEventStateJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'matchId': serializer.toJson<String>(matchId),
      'inningsNumber': serializer.toJson<int>(inningsNumber),
      'ballEventId': serializer.toJson<String?>(ballEventId),
      'preEventStateJson': serializer.toJson<String>(preEventStateJson),
    };
  }

  BallHistoryEntry copyWith({
    int? id,
    String? matchId,
    int? inningsNumber,
    Value<String?> ballEventId = const Value.absent(),
    String? preEventStateJson,
  }) => BallHistoryEntry(
    id: id ?? this.id,
    matchId: matchId ?? this.matchId,
    inningsNumber: inningsNumber ?? this.inningsNumber,
    ballEventId: ballEventId.present ? ballEventId.value : this.ballEventId,
    preEventStateJson: preEventStateJson ?? this.preEventStateJson,
  );
  BallHistoryEntry copyWithCompanion(BallHistoryCompanion data) {
    return BallHistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      inningsNumber: data.inningsNumber.present
          ? data.inningsNumber.value
          : this.inningsNumber,
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
    return (StringBuffer('BallHistoryEntry(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('inningsNumber: $inningsNumber, ')
          ..write('ballEventId: $ballEventId, ')
          ..write('preEventStateJson: $preEventStateJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, matchId, inningsNumber, ballEventId, preEventStateJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BallHistoryEntry &&
          other.id == this.id &&
          other.matchId == this.matchId &&
          other.inningsNumber == this.inningsNumber &&
          other.ballEventId == this.ballEventId &&
          other.preEventStateJson == this.preEventStateJson);
}

class BallHistoryCompanion extends UpdateCompanion<BallHistoryEntry> {
  final Value<int> id;
  final Value<String> matchId;
  final Value<int> inningsNumber;
  final Value<String?> ballEventId;
  final Value<String> preEventStateJson;
  const BallHistoryCompanion({
    this.id = const Value.absent(),
    this.matchId = const Value.absent(),
    this.inningsNumber = const Value.absent(),
    this.ballEventId = const Value.absent(),
    this.preEventStateJson = const Value.absent(),
  });
  BallHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String matchId,
    required int inningsNumber,
    this.ballEventId = const Value.absent(),
    required String preEventStateJson,
  }) : matchId = Value(matchId),
       inningsNumber = Value(inningsNumber),
       preEventStateJson = Value(preEventStateJson);
  static Insertable<BallHistoryEntry> custom({
    Expression<int>? id,
    Expression<String>? matchId,
    Expression<int>? inningsNumber,
    Expression<String>? ballEventId,
    Expression<String>? preEventStateJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (matchId != null) 'match_id': matchId,
      if (inningsNumber != null) 'innings_number': inningsNumber,
      if (ballEventId != null) 'ball_event_id': ballEventId,
      if (preEventStateJson != null) 'pre_event_state_json': preEventStateJson,
    });
  }

  BallHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? matchId,
    Value<int>? inningsNumber,
    Value<String?>? ballEventId,
    Value<String>? preEventStateJson,
  }) {
    return BallHistoryCompanion(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      inningsNumber: inningsNumber ?? this.inningsNumber,
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
    return (StringBuffer('BallHistoryCompanion(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('inningsNumber: $inningsNumber, ')
          ..write('ballEventId: $ballEventId, ')
          ..write('preEventStateJson: $preEventStateJson')
          ..write(')'))
        .toString();
  }
}

class $PendingStartInningsTableTable extends PendingStartInningsTable
    with TableInfo<$PendingStartInningsTableTable, PendingStartInnings> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingStartInningsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _strikerNameMeta = const VerificationMeta(
    'strikerName',
  );
  @override
  late final GeneratedColumn<String> strikerName = GeneratedColumn<String>(
    'striker_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nonStrikerNameMeta = const VerificationMeta(
    'nonStrikerName',
  );
  @override
  late final GeneratedColumn<String> nonStrikerName = GeneratedColumn<String>(
    'non_striker_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bowlerNameMeta = const VerificationMeta(
    'bowlerName',
  );
  @override
  late final GeneratedColumn<String> bowlerName = GeneratedColumn<String>(
    'bowler_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    matchId,
    inningsNumber,
    strikerName,
    nonStrikerName,
    bowlerName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_start_innings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingStartInnings> instance, {
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
    if (data.containsKey('striker_name')) {
      context.handle(
        _strikerNameMeta,
        strikerName.isAcceptableOrUnknown(
          data['striker_name']!,
          _strikerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_strikerNameMeta);
    }
    if (data.containsKey('non_striker_name')) {
      context.handle(
        _nonStrikerNameMeta,
        nonStrikerName.isAcceptableOrUnknown(
          data['non_striker_name']!,
          _nonStrikerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nonStrikerNameMeta);
    }
    if (data.containsKey('bowler_name')) {
      context.handle(
        _bowlerNameMeta,
        bowlerName.isAcceptableOrUnknown(data['bowler_name']!, _bowlerNameMeta),
      );
    } else if (isInserting) {
      context.missing(_bowlerNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {matchId, inningsNumber};
  @override
  PendingStartInnings map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingStartInnings(
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_id'],
      )!,
      inningsNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}innings_number'],
      )!,
      strikerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}striker_name'],
      )!,
      nonStrikerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}non_striker_name'],
      )!,
      bowlerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bowler_name'],
      )!,
    );
  }

  @override
  $PendingStartInningsTableTable createAlias(String alias) {
    return $PendingStartInningsTableTable(attachedDatabase, alias);
  }
}

class PendingStartInnings extends DataClass
    implements Insertable<PendingStartInnings> {
  final String matchId;
  final int inningsNumber;
  final String strikerName;
  final String nonStrikerName;
  final String bowlerName;
  const PendingStartInnings({
    required this.matchId,
    required this.inningsNumber,
    required this.strikerName,
    required this.nonStrikerName,
    required this.bowlerName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['match_id'] = Variable<String>(matchId);
    map['innings_number'] = Variable<int>(inningsNumber);
    map['striker_name'] = Variable<String>(strikerName);
    map['non_striker_name'] = Variable<String>(nonStrikerName);
    map['bowler_name'] = Variable<String>(bowlerName);
    return map;
  }

  PendingStartInningsTableCompanion toCompanion(bool nullToAbsent) {
    return PendingStartInningsTableCompanion(
      matchId: Value(matchId),
      inningsNumber: Value(inningsNumber),
      strikerName: Value(strikerName),
      nonStrikerName: Value(nonStrikerName),
      bowlerName: Value(bowlerName),
    );
  }

  factory PendingStartInnings.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingStartInnings(
      matchId: serializer.fromJson<String>(json['matchId']),
      inningsNumber: serializer.fromJson<int>(json['inningsNumber']),
      strikerName: serializer.fromJson<String>(json['strikerName']),
      nonStrikerName: serializer.fromJson<String>(json['nonStrikerName']),
      bowlerName: serializer.fromJson<String>(json['bowlerName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'matchId': serializer.toJson<String>(matchId),
      'inningsNumber': serializer.toJson<int>(inningsNumber),
      'strikerName': serializer.toJson<String>(strikerName),
      'nonStrikerName': serializer.toJson<String>(nonStrikerName),
      'bowlerName': serializer.toJson<String>(bowlerName),
    };
  }

  PendingStartInnings copyWith({
    String? matchId,
    int? inningsNumber,
    String? strikerName,
    String? nonStrikerName,
    String? bowlerName,
  }) => PendingStartInnings(
    matchId: matchId ?? this.matchId,
    inningsNumber: inningsNumber ?? this.inningsNumber,
    strikerName: strikerName ?? this.strikerName,
    nonStrikerName: nonStrikerName ?? this.nonStrikerName,
    bowlerName: bowlerName ?? this.bowlerName,
  );
  PendingStartInnings copyWithCompanion(
    PendingStartInningsTableCompanion data,
  ) {
    return PendingStartInnings(
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      inningsNumber: data.inningsNumber.present
          ? data.inningsNumber.value
          : this.inningsNumber,
      strikerName: data.strikerName.present
          ? data.strikerName.value
          : this.strikerName,
      nonStrikerName: data.nonStrikerName.present
          ? data.nonStrikerName.value
          : this.nonStrikerName,
      bowlerName: data.bowlerName.present
          ? data.bowlerName.value
          : this.bowlerName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingStartInnings(')
          ..write('matchId: $matchId, ')
          ..write('inningsNumber: $inningsNumber, ')
          ..write('strikerName: $strikerName, ')
          ..write('nonStrikerName: $nonStrikerName, ')
          ..write('bowlerName: $bowlerName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    matchId,
    inningsNumber,
    strikerName,
    nonStrikerName,
    bowlerName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingStartInnings &&
          other.matchId == this.matchId &&
          other.inningsNumber == this.inningsNumber &&
          other.strikerName == this.strikerName &&
          other.nonStrikerName == this.nonStrikerName &&
          other.bowlerName == this.bowlerName);
}

class PendingStartInningsTableCompanion
    extends UpdateCompanion<PendingStartInnings> {
  final Value<String> matchId;
  final Value<int> inningsNumber;
  final Value<String> strikerName;
  final Value<String> nonStrikerName;
  final Value<String> bowlerName;
  final Value<int> rowid;
  const PendingStartInningsTableCompanion({
    this.matchId = const Value.absent(),
    this.inningsNumber = const Value.absent(),
    this.strikerName = const Value.absent(),
    this.nonStrikerName = const Value.absent(),
    this.bowlerName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingStartInningsTableCompanion.insert({
    required String matchId,
    required int inningsNumber,
    required String strikerName,
    required String nonStrikerName,
    required String bowlerName,
    this.rowid = const Value.absent(),
  }) : matchId = Value(matchId),
       inningsNumber = Value(inningsNumber),
       strikerName = Value(strikerName),
       nonStrikerName = Value(nonStrikerName),
       bowlerName = Value(bowlerName);
  static Insertable<PendingStartInnings> custom({
    Expression<String>? matchId,
    Expression<int>? inningsNumber,
    Expression<String>? strikerName,
    Expression<String>? nonStrikerName,
    Expression<String>? bowlerName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (matchId != null) 'match_id': matchId,
      if (inningsNumber != null) 'innings_number': inningsNumber,
      if (strikerName != null) 'striker_name': strikerName,
      if (nonStrikerName != null) 'non_striker_name': nonStrikerName,
      if (bowlerName != null) 'bowler_name': bowlerName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingStartInningsTableCompanion copyWith({
    Value<String>? matchId,
    Value<int>? inningsNumber,
    Value<String>? strikerName,
    Value<String>? nonStrikerName,
    Value<String>? bowlerName,
    Value<int>? rowid,
  }) {
    return PendingStartInningsTableCompanion(
      matchId: matchId ?? this.matchId,
      inningsNumber: inningsNumber ?? this.inningsNumber,
      strikerName: strikerName ?? this.strikerName,
      nonStrikerName: nonStrikerName ?? this.nonStrikerName,
      bowlerName: bowlerName ?? this.bowlerName,
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
    if (strikerName.present) {
      map['striker_name'] = Variable<String>(strikerName.value);
    }
    if (nonStrikerName.present) {
      map['non_striker_name'] = Variable<String>(nonStrikerName.value);
    }
    if (bowlerName.present) {
      map['bowler_name'] = Variable<String>(bowlerName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingStartInningsTableCompanion(')
          ..write('matchId: $matchId, ')
          ..write('inningsNumber: $inningsNumber, ')
          ..write('strikerName: $strikerName, ')
          ..write('nonStrikerName: $nonStrikerName, ')
          ..write('bowlerName: $bowlerName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InningsSummariesTable extends InningsSummaries
    with TableInfo<$InningsSummariesTable, InningsSummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InningsSummariesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _battingTeamMeta = const VerificationMeta(
    'battingTeam',
  );
  @override
  late final GeneratedColumn<String> battingTeam = GeneratedColumn<String>(
    'batting_team',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalRunsMeta = const VerificationMeta(
    'totalRuns',
  );
  @override
  late final GeneratedColumn<int> totalRuns = GeneratedColumn<int>(
    'total_runs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wicketsMeta = const VerificationMeta(
    'wickets',
  );
  @override
  late final GeneratedColumn<int> wickets = GeneratedColumn<int>(
    'wickets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oversMeta = const VerificationMeta('overs');
  @override
  late final GeneratedColumn<String> overs = GeneratedColumn<String>(
    'overs',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    matchId,
    inningsNumber,
    battingTeam,
    totalRuns,
    wickets,
    overs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'innings_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<InningsSummary> instance, {
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
    if (data.containsKey('batting_team')) {
      context.handle(
        _battingTeamMeta,
        battingTeam.isAcceptableOrUnknown(
          data['batting_team']!,
          _battingTeamMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_battingTeamMeta);
    }
    if (data.containsKey('total_runs')) {
      context.handle(
        _totalRunsMeta,
        totalRuns.isAcceptableOrUnknown(data['total_runs']!, _totalRunsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalRunsMeta);
    }
    if (data.containsKey('wickets')) {
      context.handle(
        _wicketsMeta,
        wickets.isAcceptableOrUnknown(data['wickets']!, _wicketsMeta),
      );
    } else if (isInserting) {
      context.missing(_wicketsMeta);
    }
    if (data.containsKey('overs')) {
      context.handle(
        _oversMeta,
        overs.isAcceptableOrUnknown(data['overs']!, _oversMeta),
      );
    } else if (isInserting) {
      context.missing(_oversMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {matchId, inningsNumber};
  @override
  InningsSummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InningsSummary(
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_id'],
      )!,
      inningsNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}innings_number'],
      )!,
      battingTeam: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batting_team'],
      )!,
      totalRuns: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_runs'],
      )!,
      wickets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wickets'],
      )!,
      overs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overs'],
      )!,
    );
  }

  @override
  $InningsSummariesTable createAlias(String alias) {
    return $InningsSummariesTable(attachedDatabase, alias);
  }
}

class InningsSummary extends DataClass implements Insertable<InningsSummary> {
  final String matchId;
  final int inningsNumber;
  final String battingTeam;
  final int totalRuns;
  final int wickets;
  final String overs;
  const InningsSummary({
    required this.matchId,
    required this.inningsNumber,
    required this.battingTeam,
    required this.totalRuns,
    required this.wickets,
    required this.overs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['match_id'] = Variable<String>(matchId);
    map['innings_number'] = Variable<int>(inningsNumber);
    map['batting_team'] = Variable<String>(battingTeam);
    map['total_runs'] = Variable<int>(totalRuns);
    map['wickets'] = Variable<int>(wickets);
    map['overs'] = Variable<String>(overs);
    return map;
  }

  InningsSummariesCompanion toCompanion(bool nullToAbsent) {
    return InningsSummariesCompanion(
      matchId: Value(matchId),
      inningsNumber: Value(inningsNumber),
      battingTeam: Value(battingTeam),
      totalRuns: Value(totalRuns),
      wickets: Value(wickets),
      overs: Value(overs),
    );
  }

  factory InningsSummary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InningsSummary(
      matchId: serializer.fromJson<String>(json['matchId']),
      inningsNumber: serializer.fromJson<int>(json['inningsNumber']),
      battingTeam: serializer.fromJson<String>(json['battingTeam']),
      totalRuns: serializer.fromJson<int>(json['totalRuns']),
      wickets: serializer.fromJson<int>(json['wickets']),
      overs: serializer.fromJson<String>(json['overs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'matchId': serializer.toJson<String>(matchId),
      'inningsNumber': serializer.toJson<int>(inningsNumber),
      'battingTeam': serializer.toJson<String>(battingTeam),
      'totalRuns': serializer.toJson<int>(totalRuns),
      'wickets': serializer.toJson<int>(wickets),
      'overs': serializer.toJson<String>(overs),
    };
  }

  InningsSummary copyWith({
    String? matchId,
    int? inningsNumber,
    String? battingTeam,
    int? totalRuns,
    int? wickets,
    String? overs,
  }) => InningsSummary(
    matchId: matchId ?? this.matchId,
    inningsNumber: inningsNumber ?? this.inningsNumber,
    battingTeam: battingTeam ?? this.battingTeam,
    totalRuns: totalRuns ?? this.totalRuns,
    wickets: wickets ?? this.wickets,
    overs: overs ?? this.overs,
  );
  InningsSummary copyWithCompanion(InningsSummariesCompanion data) {
    return InningsSummary(
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      inningsNumber: data.inningsNumber.present
          ? data.inningsNumber.value
          : this.inningsNumber,
      battingTeam: data.battingTeam.present
          ? data.battingTeam.value
          : this.battingTeam,
      totalRuns: data.totalRuns.present ? data.totalRuns.value : this.totalRuns,
      wickets: data.wickets.present ? data.wickets.value : this.wickets,
      overs: data.overs.present ? data.overs.value : this.overs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InningsSummary(')
          ..write('matchId: $matchId, ')
          ..write('inningsNumber: $inningsNumber, ')
          ..write('battingTeam: $battingTeam, ')
          ..write('totalRuns: $totalRuns, ')
          ..write('wickets: $wickets, ')
          ..write('overs: $overs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    matchId,
    inningsNumber,
    battingTeam,
    totalRuns,
    wickets,
    overs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InningsSummary &&
          other.matchId == this.matchId &&
          other.inningsNumber == this.inningsNumber &&
          other.battingTeam == this.battingTeam &&
          other.totalRuns == this.totalRuns &&
          other.wickets == this.wickets &&
          other.overs == this.overs);
}

class InningsSummariesCompanion extends UpdateCompanion<InningsSummary> {
  final Value<String> matchId;
  final Value<int> inningsNumber;
  final Value<String> battingTeam;
  final Value<int> totalRuns;
  final Value<int> wickets;
  final Value<String> overs;
  final Value<int> rowid;
  const InningsSummariesCompanion({
    this.matchId = const Value.absent(),
    this.inningsNumber = const Value.absent(),
    this.battingTeam = const Value.absent(),
    this.totalRuns = const Value.absent(),
    this.wickets = const Value.absent(),
    this.overs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InningsSummariesCompanion.insert({
    required String matchId,
    required int inningsNumber,
    required String battingTeam,
    required int totalRuns,
    required int wickets,
    required String overs,
    this.rowid = const Value.absent(),
  }) : matchId = Value(matchId),
       inningsNumber = Value(inningsNumber),
       battingTeam = Value(battingTeam),
       totalRuns = Value(totalRuns),
       wickets = Value(wickets),
       overs = Value(overs);
  static Insertable<InningsSummary> custom({
    Expression<String>? matchId,
    Expression<int>? inningsNumber,
    Expression<String>? battingTeam,
    Expression<int>? totalRuns,
    Expression<int>? wickets,
    Expression<String>? overs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (matchId != null) 'match_id': matchId,
      if (inningsNumber != null) 'innings_number': inningsNumber,
      if (battingTeam != null) 'batting_team': battingTeam,
      if (totalRuns != null) 'total_runs': totalRuns,
      if (wickets != null) 'wickets': wickets,
      if (overs != null) 'overs': overs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InningsSummariesCompanion copyWith({
    Value<String>? matchId,
    Value<int>? inningsNumber,
    Value<String>? battingTeam,
    Value<int>? totalRuns,
    Value<int>? wickets,
    Value<String>? overs,
    Value<int>? rowid,
  }) {
    return InningsSummariesCompanion(
      matchId: matchId ?? this.matchId,
      inningsNumber: inningsNumber ?? this.inningsNumber,
      battingTeam: battingTeam ?? this.battingTeam,
      totalRuns: totalRuns ?? this.totalRuns,
      wickets: wickets ?? this.wickets,
      overs: overs ?? this.overs,
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
    if (battingTeam.present) {
      map['batting_team'] = Variable<String>(battingTeam.value);
    }
    if (totalRuns.present) {
      map['total_runs'] = Variable<int>(totalRuns.value);
    }
    if (wickets.present) {
      map['wickets'] = Variable<int>(wickets.value);
    }
    if (overs.present) {
      map['overs'] = Variable<String>(overs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InningsSummariesCompanion(')
          ..write('matchId: $matchId, ')
          ..write('inningsNumber: $inningsNumber, ')
          ..write('battingTeam: $battingTeam, ')
          ..write('totalRuns: $totalRuns, ')
          ..write('wickets: $wickets, ')
          ..write('overs: $overs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProvisionalMatchResultsTable extends ProvisionalMatchResults
    with TableInfo<$ProvisionalMatchResultsTable, ProvisionalMatchResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProvisionalMatchResultsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _winnerMeta = const VerificationMeta('winner');
  @override
  late final GeneratedColumn<String> winner = GeneratedColumn<String>(
    'winner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marginTypeMeta = const VerificationMeta(
    'marginType',
  );
  @override
  late final GeneratedColumn<String> marginType = GeneratedColumn<String>(
    'margin_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _marginMeta = const VerificationMeta('margin');
  @override
  late final GeneratedColumn<int> margin = GeneratedColumn<int>(
    'margin',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [matchId, winner, marginType, margin];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'provisional_match_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProvisionalMatchResult> instance, {
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
    if (data.containsKey('winner')) {
      context.handle(
        _winnerMeta,
        winner.isAcceptableOrUnknown(data['winner']!, _winnerMeta),
      );
    } else if (isInserting) {
      context.missing(_winnerMeta);
    }
    if (data.containsKey('margin_type')) {
      context.handle(
        _marginTypeMeta,
        marginType.isAcceptableOrUnknown(data['margin_type']!, _marginTypeMeta),
      );
    }
    if (data.containsKey('margin')) {
      context.handle(
        _marginMeta,
        margin.isAcceptableOrUnknown(data['margin']!, _marginMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {matchId};
  @override
  ProvisionalMatchResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProvisionalMatchResult(
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_id'],
      )!,
      winner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}winner'],
      )!,
      marginType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}margin_type'],
      ),
      margin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}margin'],
      ),
    );
  }

  @override
  $ProvisionalMatchResultsTable createAlias(String alias) {
    return $ProvisionalMatchResultsTable(attachedDatabase, alias);
  }
}

class ProvisionalMatchResult extends DataClass
    implements Insertable<ProvisionalMatchResult> {
  final String matchId;
  final String winner;
  final String? marginType;
  final int? margin;
  const ProvisionalMatchResult({
    required this.matchId,
    required this.winner,
    this.marginType,
    this.margin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['match_id'] = Variable<String>(matchId);
    map['winner'] = Variable<String>(winner);
    if (!nullToAbsent || marginType != null) {
      map['margin_type'] = Variable<String>(marginType);
    }
    if (!nullToAbsent || margin != null) {
      map['margin'] = Variable<int>(margin);
    }
    return map;
  }

  ProvisionalMatchResultsCompanion toCompanion(bool nullToAbsent) {
    return ProvisionalMatchResultsCompanion(
      matchId: Value(matchId),
      winner: Value(winner),
      marginType: marginType == null && nullToAbsent
          ? const Value.absent()
          : Value(marginType),
      margin: margin == null && nullToAbsent
          ? const Value.absent()
          : Value(margin),
    );
  }

  factory ProvisionalMatchResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProvisionalMatchResult(
      matchId: serializer.fromJson<String>(json['matchId']),
      winner: serializer.fromJson<String>(json['winner']),
      marginType: serializer.fromJson<String?>(json['marginType']),
      margin: serializer.fromJson<int?>(json['margin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'matchId': serializer.toJson<String>(matchId),
      'winner': serializer.toJson<String>(winner),
      'marginType': serializer.toJson<String?>(marginType),
      'margin': serializer.toJson<int?>(margin),
    };
  }

  ProvisionalMatchResult copyWith({
    String? matchId,
    String? winner,
    Value<String?> marginType = const Value.absent(),
    Value<int?> margin = const Value.absent(),
  }) => ProvisionalMatchResult(
    matchId: matchId ?? this.matchId,
    winner: winner ?? this.winner,
    marginType: marginType.present ? marginType.value : this.marginType,
    margin: margin.present ? margin.value : this.margin,
  );
  ProvisionalMatchResult copyWithCompanion(
    ProvisionalMatchResultsCompanion data,
  ) {
    return ProvisionalMatchResult(
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      winner: data.winner.present ? data.winner.value : this.winner,
      marginType: data.marginType.present
          ? data.marginType.value
          : this.marginType,
      margin: data.margin.present ? data.margin.value : this.margin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProvisionalMatchResult(')
          ..write('matchId: $matchId, ')
          ..write('winner: $winner, ')
          ..write('marginType: $marginType, ')
          ..write('margin: $margin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(matchId, winner, marginType, margin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProvisionalMatchResult &&
          other.matchId == this.matchId &&
          other.winner == this.winner &&
          other.marginType == this.marginType &&
          other.margin == this.margin);
}

class ProvisionalMatchResultsCompanion
    extends UpdateCompanion<ProvisionalMatchResult> {
  final Value<String> matchId;
  final Value<String> winner;
  final Value<String?> marginType;
  final Value<int?> margin;
  final Value<int> rowid;
  const ProvisionalMatchResultsCompanion({
    this.matchId = const Value.absent(),
    this.winner = const Value.absent(),
    this.marginType = const Value.absent(),
    this.margin = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProvisionalMatchResultsCompanion.insert({
    required String matchId,
    required String winner,
    this.marginType = const Value.absent(),
    this.margin = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : matchId = Value(matchId),
       winner = Value(winner);
  static Insertable<ProvisionalMatchResult> custom({
    Expression<String>? matchId,
    Expression<String>? winner,
    Expression<String>? marginType,
    Expression<int>? margin,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (matchId != null) 'match_id': matchId,
      if (winner != null) 'winner': winner,
      if (marginType != null) 'margin_type': marginType,
      if (margin != null) 'margin': margin,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProvisionalMatchResultsCompanion copyWith({
    Value<String>? matchId,
    Value<String>? winner,
    Value<String?>? marginType,
    Value<int?>? margin,
    Value<int>? rowid,
  }) {
    return ProvisionalMatchResultsCompanion(
      matchId: matchId ?? this.matchId,
      winner: winner ?? this.winner,
      marginType: marginType ?? this.marginType,
      margin: margin ?? this.margin,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (winner.present) {
      map['winner'] = Variable<String>(winner.value);
    }
    if (marginType.present) {
      map['margin_type'] = Variable<String>(marginType.value);
    }
    if (margin.present) {
      map['margin'] = Variable<int>(margin.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProvisionalMatchResultsCompanion(')
          ..write('matchId: $matchId, ')
          ..write('winner: $winner, ')
          ..write('marginType: $marginType, ')
          ..write('margin: $margin, ')
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
  late final $BallHistoryTable ballHistory = $BallHistoryTable(this);
  late final $PendingStartInningsTableTable pendingStartInningsTable =
      $PendingStartInningsTableTable(this);
  late final $InningsSummariesTable inningsSummaries = $InningsSummariesTable(
    this,
  );
  late final $ProvisionalMatchResultsTable provisionalMatchResults =
      $ProvisionalMatchResultsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    queuedSyncEvents,
    syncBaseline,
    ballHistory,
    pendingStartInningsTable,
    inningsSummaries,
    provisionalMatchResults,
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
typedef $$BallHistoryTableCreateCompanionBuilder =
    BallHistoryCompanion Function({
      Value<int> id,
      required String matchId,
      required int inningsNumber,
      Value<String?> ballEventId,
      required String preEventStateJson,
    });
typedef $$BallHistoryTableUpdateCompanionBuilder =
    BallHistoryCompanion Function({
      Value<int> id,
      Value<String> matchId,
      Value<int> inningsNumber,
      Value<String?> ballEventId,
      Value<String> preEventStateJson,
    });

class $$BallHistoryTableFilterComposer
    extends Composer<_$ScoringQueueDatabase, $BallHistoryTable> {
  $$BallHistoryTableFilterComposer({
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

  ColumnFilters<String> get ballEventId => $composableBuilder(
    column: $table.ballEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preEventStateJson => $composableBuilder(
    column: $table.preEventStateJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BallHistoryTableOrderingComposer
    extends Composer<_$ScoringQueueDatabase, $BallHistoryTable> {
  $$BallHistoryTableOrderingComposer({
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

  ColumnOrderings<String> get ballEventId => $composableBuilder(
    column: $table.ballEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preEventStateJson => $composableBuilder(
    column: $table.preEventStateJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BallHistoryTableAnnotationComposer
    extends Composer<_$ScoringQueueDatabase, $BallHistoryTable> {
  $$BallHistoryTableAnnotationComposer({
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

  GeneratedColumn<String> get ballEventId => $composableBuilder(
    column: $table.ballEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preEventStateJson => $composableBuilder(
    column: $table.preEventStateJson,
    builder: (column) => column,
  );
}

class $$BallHistoryTableTableManager
    extends
        RootTableManager<
          _$ScoringQueueDatabase,
          $BallHistoryTable,
          BallHistoryEntry,
          $$BallHistoryTableFilterComposer,
          $$BallHistoryTableOrderingComposer,
          $$BallHistoryTableAnnotationComposer,
          $$BallHistoryTableCreateCompanionBuilder,
          $$BallHistoryTableUpdateCompanionBuilder,
          (
            BallHistoryEntry,
            BaseReferences<
              _$ScoringQueueDatabase,
              $BallHistoryTable,
              BallHistoryEntry
            >,
          ),
          BallHistoryEntry,
          PrefetchHooks Function()
        > {
  $$BallHistoryTableTableManager(
    _$ScoringQueueDatabase db,
    $BallHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BallHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BallHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BallHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> matchId = const Value.absent(),
                Value<int> inningsNumber = const Value.absent(),
                Value<String?> ballEventId = const Value.absent(),
                Value<String> preEventStateJson = const Value.absent(),
              }) => BallHistoryCompanion(
                id: id,
                matchId: matchId,
                inningsNumber: inningsNumber,
                ballEventId: ballEventId,
                preEventStateJson: preEventStateJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String matchId,
                required int inningsNumber,
                Value<String?> ballEventId = const Value.absent(),
                required String preEventStateJson,
              }) => BallHistoryCompanion.insert(
                id: id,
                matchId: matchId,
                inningsNumber: inningsNumber,
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

typedef $$BallHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$ScoringQueueDatabase,
      $BallHistoryTable,
      BallHistoryEntry,
      $$BallHistoryTableFilterComposer,
      $$BallHistoryTableOrderingComposer,
      $$BallHistoryTableAnnotationComposer,
      $$BallHistoryTableCreateCompanionBuilder,
      $$BallHistoryTableUpdateCompanionBuilder,
      (
        BallHistoryEntry,
        BaseReferences<
          _$ScoringQueueDatabase,
          $BallHistoryTable,
          BallHistoryEntry
        >,
      ),
      BallHistoryEntry,
      PrefetchHooks Function()
    >;
typedef $$PendingStartInningsTableTableCreateCompanionBuilder =
    PendingStartInningsTableCompanion Function({
      required String matchId,
      required int inningsNumber,
      required String strikerName,
      required String nonStrikerName,
      required String bowlerName,
      Value<int> rowid,
    });
typedef $$PendingStartInningsTableTableUpdateCompanionBuilder =
    PendingStartInningsTableCompanion Function({
      Value<String> matchId,
      Value<int> inningsNumber,
      Value<String> strikerName,
      Value<String> nonStrikerName,
      Value<String> bowlerName,
      Value<int> rowid,
    });

class $$PendingStartInningsTableTableFilterComposer
    extends Composer<_$ScoringQueueDatabase, $PendingStartInningsTableTable> {
  $$PendingStartInningsTableTableFilterComposer({
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

  ColumnFilters<String> get strikerName => $composableBuilder(
    column: $table.strikerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nonStrikerName => $composableBuilder(
    column: $table.nonStrikerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bowlerName => $composableBuilder(
    column: $table.bowlerName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingStartInningsTableTableOrderingComposer
    extends Composer<_$ScoringQueueDatabase, $PendingStartInningsTableTable> {
  $$PendingStartInningsTableTableOrderingComposer({
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

  ColumnOrderings<String> get strikerName => $composableBuilder(
    column: $table.strikerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nonStrikerName => $composableBuilder(
    column: $table.nonStrikerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bowlerName => $composableBuilder(
    column: $table.bowlerName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingStartInningsTableTableAnnotationComposer
    extends Composer<_$ScoringQueueDatabase, $PendingStartInningsTableTable> {
  $$PendingStartInningsTableTableAnnotationComposer({
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

  GeneratedColumn<String> get strikerName => $composableBuilder(
    column: $table.strikerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nonStrikerName => $composableBuilder(
    column: $table.nonStrikerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bowlerName => $composableBuilder(
    column: $table.bowlerName,
    builder: (column) => column,
  );
}

class $$PendingStartInningsTableTableTableManager
    extends
        RootTableManager<
          _$ScoringQueueDatabase,
          $PendingStartInningsTableTable,
          PendingStartInnings,
          $$PendingStartInningsTableTableFilterComposer,
          $$PendingStartInningsTableTableOrderingComposer,
          $$PendingStartInningsTableTableAnnotationComposer,
          $$PendingStartInningsTableTableCreateCompanionBuilder,
          $$PendingStartInningsTableTableUpdateCompanionBuilder,
          (
            PendingStartInnings,
            BaseReferences<
              _$ScoringQueueDatabase,
              $PendingStartInningsTableTable,
              PendingStartInnings
            >,
          ),
          PendingStartInnings,
          PrefetchHooks Function()
        > {
  $$PendingStartInningsTableTableTableManager(
    _$ScoringQueueDatabase db,
    $PendingStartInningsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingStartInningsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PendingStartInningsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PendingStartInningsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> matchId = const Value.absent(),
                Value<int> inningsNumber = const Value.absent(),
                Value<String> strikerName = const Value.absent(),
                Value<String> nonStrikerName = const Value.absent(),
                Value<String> bowlerName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingStartInningsTableCompanion(
                matchId: matchId,
                inningsNumber: inningsNumber,
                strikerName: strikerName,
                nonStrikerName: nonStrikerName,
                bowlerName: bowlerName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String matchId,
                required int inningsNumber,
                required String strikerName,
                required String nonStrikerName,
                required String bowlerName,
                Value<int> rowid = const Value.absent(),
              }) => PendingStartInningsTableCompanion.insert(
                matchId: matchId,
                inningsNumber: inningsNumber,
                strikerName: strikerName,
                nonStrikerName: nonStrikerName,
                bowlerName: bowlerName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingStartInningsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$ScoringQueueDatabase,
      $PendingStartInningsTableTable,
      PendingStartInnings,
      $$PendingStartInningsTableTableFilterComposer,
      $$PendingStartInningsTableTableOrderingComposer,
      $$PendingStartInningsTableTableAnnotationComposer,
      $$PendingStartInningsTableTableCreateCompanionBuilder,
      $$PendingStartInningsTableTableUpdateCompanionBuilder,
      (
        PendingStartInnings,
        BaseReferences<
          _$ScoringQueueDatabase,
          $PendingStartInningsTableTable,
          PendingStartInnings
        >,
      ),
      PendingStartInnings,
      PrefetchHooks Function()
    >;
typedef $$InningsSummariesTableCreateCompanionBuilder =
    InningsSummariesCompanion Function({
      required String matchId,
      required int inningsNumber,
      required String battingTeam,
      required int totalRuns,
      required int wickets,
      required String overs,
      Value<int> rowid,
    });
typedef $$InningsSummariesTableUpdateCompanionBuilder =
    InningsSummariesCompanion Function({
      Value<String> matchId,
      Value<int> inningsNumber,
      Value<String> battingTeam,
      Value<int> totalRuns,
      Value<int> wickets,
      Value<String> overs,
      Value<int> rowid,
    });

class $$InningsSummariesTableFilterComposer
    extends Composer<_$ScoringQueueDatabase, $InningsSummariesTable> {
  $$InningsSummariesTableFilterComposer({
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

  ColumnFilters<String> get battingTeam => $composableBuilder(
    column: $table.battingTeam,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalRuns => $composableBuilder(
    column: $table.totalRuns,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wickets => $composableBuilder(
    column: $table.wickets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overs => $composableBuilder(
    column: $table.overs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InningsSummariesTableOrderingComposer
    extends Composer<_$ScoringQueueDatabase, $InningsSummariesTable> {
  $$InningsSummariesTableOrderingComposer({
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

  ColumnOrderings<String> get battingTeam => $composableBuilder(
    column: $table.battingTeam,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalRuns => $composableBuilder(
    column: $table.totalRuns,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wickets => $composableBuilder(
    column: $table.wickets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overs => $composableBuilder(
    column: $table.overs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InningsSummariesTableAnnotationComposer
    extends Composer<_$ScoringQueueDatabase, $InningsSummariesTable> {
  $$InningsSummariesTableAnnotationComposer({
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

  GeneratedColumn<String> get battingTeam => $composableBuilder(
    column: $table.battingTeam,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalRuns =>
      $composableBuilder(column: $table.totalRuns, builder: (column) => column);

  GeneratedColumn<int> get wickets =>
      $composableBuilder(column: $table.wickets, builder: (column) => column);

  GeneratedColumn<String> get overs =>
      $composableBuilder(column: $table.overs, builder: (column) => column);
}

class $$InningsSummariesTableTableManager
    extends
        RootTableManager<
          _$ScoringQueueDatabase,
          $InningsSummariesTable,
          InningsSummary,
          $$InningsSummariesTableFilterComposer,
          $$InningsSummariesTableOrderingComposer,
          $$InningsSummariesTableAnnotationComposer,
          $$InningsSummariesTableCreateCompanionBuilder,
          $$InningsSummariesTableUpdateCompanionBuilder,
          (
            InningsSummary,
            BaseReferences<
              _$ScoringQueueDatabase,
              $InningsSummariesTable,
              InningsSummary
            >,
          ),
          InningsSummary,
          PrefetchHooks Function()
        > {
  $$InningsSummariesTableTableManager(
    _$ScoringQueueDatabase db,
    $InningsSummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InningsSummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InningsSummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InningsSummariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> matchId = const Value.absent(),
                Value<int> inningsNumber = const Value.absent(),
                Value<String> battingTeam = const Value.absent(),
                Value<int> totalRuns = const Value.absent(),
                Value<int> wickets = const Value.absent(),
                Value<String> overs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InningsSummariesCompanion(
                matchId: matchId,
                inningsNumber: inningsNumber,
                battingTeam: battingTeam,
                totalRuns: totalRuns,
                wickets: wickets,
                overs: overs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String matchId,
                required int inningsNumber,
                required String battingTeam,
                required int totalRuns,
                required int wickets,
                required String overs,
                Value<int> rowid = const Value.absent(),
              }) => InningsSummariesCompanion.insert(
                matchId: matchId,
                inningsNumber: inningsNumber,
                battingTeam: battingTeam,
                totalRuns: totalRuns,
                wickets: wickets,
                overs: overs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InningsSummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$ScoringQueueDatabase,
      $InningsSummariesTable,
      InningsSummary,
      $$InningsSummariesTableFilterComposer,
      $$InningsSummariesTableOrderingComposer,
      $$InningsSummariesTableAnnotationComposer,
      $$InningsSummariesTableCreateCompanionBuilder,
      $$InningsSummariesTableUpdateCompanionBuilder,
      (
        InningsSummary,
        BaseReferences<
          _$ScoringQueueDatabase,
          $InningsSummariesTable,
          InningsSummary
        >,
      ),
      InningsSummary,
      PrefetchHooks Function()
    >;
typedef $$ProvisionalMatchResultsTableCreateCompanionBuilder =
    ProvisionalMatchResultsCompanion Function({
      required String matchId,
      required String winner,
      Value<String?> marginType,
      Value<int?> margin,
      Value<int> rowid,
    });
typedef $$ProvisionalMatchResultsTableUpdateCompanionBuilder =
    ProvisionalMatchResultsCompanion Function({
      Value<String> matchId,
      Value<String> winner,
      Value<String?> marginType,
      Value<int?> margin,
      Value<int> rowid,
    });

class $$ProvisionalMatchResultsTableFilterComposer
    extends Composer<_$ScoringQueueDatabase, $ProvisionalMatchResultsTable> {
  $$ProvisionalMatchResultsTableFilterComposer({
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

  ColumnFilters<String> get winner => $composableBuilder(
    column: $table.winner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marginType => $composableBuilder(
    column: $table.marginType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get margin => $composableBuilder(
    column: $table.margin,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProvisionalMatchResultsTableOrderingComposer
    extends Composer<_$ScoringQueueDatabase, $ProvisionalMatchResultsTable> {
  $$ProvisionalMatchResultsTableOrderingComposer({
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

  ColumnOrderings<String> get winner => $composableBuilder(
    column: $table.winner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marginType => $composableBuilder(
    column: $table.marginType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get margin => $composableBuilder(
    column: $table.margin,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProvisionalMatchResultsTableAnnotationComposer
    extends Composer<_$ScoringQueueDatabase, $ProvisionalMatchResultsTable> {
  $$ProvisionalMatchResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get matchId =>
      $composableBuilder(column: $table.matchId, builder: (column) => column);

  GeneratedColumn<String> get winner =>
      $composableBuilder(column: $table.winner, builder: (column) => column);

  GeneratedColumn<String> get marginType => $composableBuilder(
    column: $table.marginType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get margin =>
      $composableBuilder(column: $table.margin, builder: (column) => column);
}

class $$ProvisionalMatchResultsTableTableManager
    extends
        RootTableManager<
          _$ScoringQueueDatabase,
          $ProvisionalMatchResultsTable,
          ProvisionalMatchResult,
          $$ProvisionalMatchResultsTableFilterComposer,
          $$ProvisionalMatchResultsTableOrderingComposer,
          $$ProvisionalMatchResultsTableAnnotationComposer,
          $$ProvisionalMatchResultsTableCreateCompanionBuilder,
          $$ProvisionalMatchResultsTableUpdateCompanionBuilder,
          (
            ProvisionalMatchResult,
            BaseReferences<
              _$ScoringQueueDatabase,
              $ProvisionalMatchResultsTable,
              ProvisionalMatchResult
            >,
          ),
          ProvisionalMatchResult,
          PrefetchHooks Function()
        > {
  $$ProvisionalMatchResultsTableTableManager(
    _$ScoringQueueDatabase db,
    $ProvisionalMatchResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProvisionalMatchResultsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProvisionalMatchResultsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProvisionalMatchResultsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> matchId = const Value.absent(),
                Value<String> winner = const Value.absent(),
                Value<String?> marginType = const Value.absent(),
                Value<int?> margin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProvisionalMatchResultsCompanion(
                matchId: matchId,
                winner: winner,
                marginType: marginType,
                margin: margin,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String matchId,
                required String winner,
                Value<String?> marginType = const Value.absent(),
                Value<int?> margin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProvisionalMatchResultsCompanion.insert(
                matchId: matchId,
                winner: winner,
                marginType: marginType,
                margin: margin,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProvisionalMatchResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$ScoringQueueDatabase,
      $ProvisionalMatchResultsTable,
      ProvisionalMatchResult,
      $$ProvisionalMatchResultsTableFilterComposer,
      $$ProvisionalMatchResultsTableOrderingComposer,
      $$ProvisionalMatchResultsTableAnnotationComposer,
      $$ProvisionalMatchResultsTableCreateCompanionBuilder,
      $$ProvisionalMatchResultsTableUpdateCompanionBuilder,
      (
        ProvisionalMatchResult,
        BaseReferences<
          _$ScoringQueueDatabase,
          $ProvisionalMatchResultsTable,
          ProvisionalMatchResult
        >,
      ),
      ProvisionalMatchResult,
      PrefetchHooks Function()
    >;

class $ScoringQueueDatabaseManager {
  final _$ScoringQueueDatabase _db;
  $ScoringQueueDatabaseManager(this._db);
  $$QueuedSyncEventsTableTableManager get queuedSyncEvents =>
      $$QueuedSyncEventsTableTableManager(_db, _db.queuedSyncEvents);
  $$SyncBaselineTableTableManager get syncBaseline =>
      $$SyncBaselineTableTableManager(_db, _db.syncBaseline);
  $$BallHistoryTableTableManager get ballHistory =>
      $$BallHistoryTableTableManager(_db, _db.ballHistory);
  $$PendingStartInningsTableTableTableManager get pendingStartInningsTable =>
      $$PendingStartInningsTableTableTableManager(
        _db,
        _db.pendingStartInningsTable,
      );
  $$InningsSummariesTableTableManager get inningsSummaries =>
      $$InningsSummariesTableTableManager(_db, _db.inningsSummaries);
  $$ProvisionalMatchResultsTableTableManager get provisionalMatchResults =>
      $$ProvisionalMatchResultsTableTableManager(
        _db,
        _db.provisionalMatchResults,
      );
}
