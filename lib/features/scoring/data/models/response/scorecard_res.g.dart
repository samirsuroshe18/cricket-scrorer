// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scorecard_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BattingLine _$BattingLineFromJson(Map<String, dynamic> json) => BattingLine(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      runs: (json['runs'] as num).toInt(),
      balls: (json['balls'] as num).toInt(),
      fours: (json['fours'] as num).toInt(),
      sixes: (json['sixes'] as num).toInt(),
      strikeRate: (json['strikeRate'] as num).toDouble(),
      dismissalType: json['dismissalType'] as String?,
      isNotOut: json['isNotOut'] as bool,
    );

Map<String, dynamic> _$BattingLineToJson(BattingLine instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'playerName': instance.playerName,
      'runs': instance.runs,
      'balls': instance.balls,
      'fours': instance.fours,
      'sixes': instance.sixes,
      'strikeRate': instance.strikeRate,
      'dismissalType': instance.dismissalType,
      'isNotOut': instance.isNotOut,
    };

BowlingLine _$BowlingLineFromJson(Map<String, dynamic> json) => BowlingLine(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      overs: json['overs'] as String,
      maidens: (json['maidens'] as num).toInt(),
      runs: (json['runs'] as num).toInt(),
      wickets: (json['wickets'] as num).toInt(),
      economy: (json['economy'] as num).toDouble(),
      wides: (json['wides'] as num).toInt(),
      noBalls: (json['noBalls'] as num).toInt(),
    );

Map<String, dynamic> _$BowlingLineToJson(BowlingLine instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'playerName': instance.playerName,
      'overs': instance.overs,
      'maidens': instance.maidens,
      'runs': instance.runs,
      'wickets': instance.wickets,
      'economy': instance.economy,
      'wides': instance.wides,
      'noBalls': instance.noBalls,
    };

ScorecardExtras _$ScorecardExtrasFromJson(Map<String, dynamic> json) =>
    ScorecardExtras(
      total: (json['total'] as num).toInt(),
      wides: (json['wides'] as num).toInt(),
      noBalls: (json['noBalls'] as num).toInt(),
      byes: (json['byes'] as num).toInt(),
      legByes: (json['legByes'] as num).toInt(),
    );

Map<String, dynamic> _$ScorecardExtrasToJson(ScorecardExtras instance) =>
    <String, dynamic>{
      'total': instance.total,
      'wides': instance.wides,
      'noBalls': instance.noBalls,
      'byes': instance.byes,
      'legByes': instance.legByes,
    };

InningsScorecard _$InningsScorecardFromJson(Map<String, dynamic> json) =>
    InningsScorecard(
      inningsId: json['inningsId'] as String,
      inningsNumber: (json['inningsNumber'] as num).toInt(),
      battingTeam: json['battingTeam'] as String,
      battingScores: (json['battingScores'] as List<dynamic>)
          .map((e) => BattingLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      bowlingScores: (json['bowlingScores'] as List<dynamic>)
          .map((e) => BowlingLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalRuns: (json['totalRuns'] as num).toInt(),
      totalWickets: (json['totalWickets'] as num).toInt(),
      totalOvers: json['totalOvers'] as String,
      extras: ScorecardExtras.fromJson(json['extras'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InningsScorecardToJson(InningsScorecard instance) =>
    <String, dynamic>{
      'inningsId': instance.inningsId,
      'inningsNumber': instance.inningsNumber,
      'battingTeam': instance.battingTeam,
      'battingScores': instance.battingScores.map((e) => e.toJson()).toList(),
      'bowlingScores': instance.bowlingScores.map((e) => e.toJson()).toList(),
      'totalRuns': instance.totalRuns,
      'totalWickets': instance.totalWickets,
      'totalOvers': instance.totalOvers,
      'extras': instance.extras.toJson(),
    };

ScorecardRes _$ScorecardResFromJson(Map<String, dynamic> json) => ScorecardRes(
      matchId: json['matchId'] as String,
      teamA: PublicTeamRef.fromJson(json['teamA'] as Map<String, dynamic>),
      teamB: PublicTeamRef.fromJson(json['teamB'] as Map<String, dynamic>),
      result: MatchResultInfo.fromJson(json['result'] as Map<String, dynamic>),
      innings: (json['innings'] as List<dynamic>)
          .map((e) => InningsScorecard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ScorecardResToJson(ScorecardRes instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'result': instance.result.toJson(),
      'innings': instance.innings.map((e) => e.toJson()).toList(),
      'teamA': instance.teamA.toJson(),
      'teamB': instance.teamB.toJson(),
    };
