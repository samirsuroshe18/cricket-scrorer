// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'career_stats_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HighScore _$HighScoreFromJson(Map<String, dynamic> json) => HighScore(
  runs: (json['runs'] as num).toInt(),
  isNotOut: json['isNotOut'] as bool,
  matchId: json['matchId'] as String,
);

Map<String, dynamic> _$HighScoreToJson(HighScore instance) => <String, dynamic>{
  'runs': instance.runs,
  'isNotOut': instance.isNotOut,
  'matchId': instance.matchId,
};

BestBowling _$BestBowlingFromJson(Map<String, dynamic> json) => BestBowling(
  wickets: (json['wickets'] as num).toInt(),
  runs: (json['runs'] as num).toInt(),
  matchId: json['matchId'] as String,
);

Map<String, dynamic> _$BestBowlingToJson(BestBowling instance) =>
    <String, dynamic>{
      'wickets': instance.wickets,
      'runs': instance.runs,
      'matchId': instance.matchId,
    };

BattingCareerStats _$BattingCareerStatsFromJson(Map<String, dynamic> json) =>
    BattingCareerStats(
      inningsBatted: (json['inningsBatted'] as num).toInt(),
      runs: (json['runs'] as num).toInt(),
      ballsFaced: (json['ballsFaced'] as num).toInt(),
      timesOut: (json['timesOut'] as num).toInt(),
      notOuts: (json['notOuts'] as num).toInt(),
      average: (json['average'] as num?)?.toDouble(),
      strikeRate: (json['strikeRate'] as num).toDouble(),
      fours: (json['fours'] as num).toInt(),
      sixes: (json['sixes'] as num).toInt(),
      fifties: (json['fifties'] as num).toInt(),
      hundreds: (json['hundreds'] as num).toInt(),
      highScore: json['highScore'] == null
          ? null
          : HighScore.fromJson(json['highScore'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BattingCareerStatsToJson(BattingCareerStats instance) =>
    <String, dynamic>{
      'inningsBatted': instance.inningsBatted,
      'runs': instance.runs,
      'ballsFaced': instance.ballsFaced,
      'timesOut': instance.timesOut,
      'notOuts': instance.notOuts,
      'average': instance.average,
      'strikeRate': instance.strikeRate,
      'fours': instance.fours,
      'sixes': instance.sixes,
      'fifties': instance.fifties,
      'hundreds': instance.hundreds,
      'highScore': instance.highScore?.toJson(),
    };

BowlingCareerStats _$BowlingCareerStatsFromJson(Map<String, dynamic> json) =>
    BowlingCareerStats(
      inningsBowled: (json['inningsBowled'] as num).toInt(),
      legalDeliveries: (json['legalDeliveries'] as num).toInt(),
      runsConceded: (json['runsConceded'] as num).toInt(),
      wickets: (json['wickets'] as num).toInt(),
      maidens: (json['maidens'] as num).toInt(),
      economy: (json['economy'] as num).toDouble(),
      bestBowling: json['bestBowling'] == null
          ? null
          : BestBowling.fromJson(json['bestBowling'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BowlingCareerStatsToJson(BowlingCareerStats instance) =>
    <String, dynamic>{
      'inningsBowled': instance.inningsBowled,
      'legalDeliveries': instance.legalDeliveries,
      'runsConceded': instance.runsConceded,
      'wickets': instance.wickets,
      'maidens': instance.maidens,
      'economy': instance.economy,
      'bestBowling': instance.bestBowling?.toJson(),
    };

CareerStatsRes _$CareerStatsResFromJson(
  Map<String, dynamic> json,
) => CareerStatsRes(
  playerId: json['playerId'] as String,
  playerName: json['playerName'] as String,
  matchesPlayed: (json['matchesPlayed'] as num).toInt(),
  batting: BattingCareerStats.fromJson(json['batting'] as Map<String, dynamic>),
  bowling: BowlingCareerStats.fromJson(json['bowling'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CareerStatsResToJson(CareerStatsRes instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'playerName': instance.playerName,
      'matchesPlayed': instance.matchesPlayed,
      'batting': instance.batting.toJson(),
      'bowling': instance.bowling.toJson(),
    };
