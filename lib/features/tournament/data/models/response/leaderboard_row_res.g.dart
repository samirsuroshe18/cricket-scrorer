// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_row_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BattingLeaderboardRowRes _$BattingLeaderboardRowResFromJson(
  Map<String, dynamic> json,
) => BattingLeaderboardRowRes(
  playerId: json['playerId'] as String,
  playerName: json['playerName'] as String,
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

Map<String, dynamic> _$BattingLeaderboardRowResToJson(
  BattingLeaderboardRowRes instance,
) => <String, dynamic>{
  'playerId': instance.playerId,
  'playerName': instance.playerName,
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

BowlingLeaderboardRowRes _$BowlingLeaderboardRowResFromJson(
  Map<String, dynamic> json,
) => BowlingLeaderboardRowRes(
  playerId: json['playerId'] as String,
  playerName: json['playerName'] as String,
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

Map<String, dynamic> _$BowlingLeaderboardRowResToJson(
  BowlingLeaderboardRowRes instance,
) => <String, dynamic>{
  'playerId': instance.playerId,
  'playerName': instance.playerName,
  'inningsBowled': instance.inningsBowled,
  'legalDeliveries': instance.legalDeliveries,
  'runsConceded': instance.runsConceded,
  'wickets': instance.wickets,
  'maidens': instance.maidens,
  'economy': instance.economy,
  'bestBowling': instance.bestBowling?.toJson(),
};

TournamentLeaderboardsRes _$TournamentLeaderboardsResFromJson(
  Map<String, dynamic> json,
) => TournamentLeaderboardsRes(
  tournamentId: json['tournamentId'] as String,
  battingLeaderboard: (json['battingLeaderboard'] as List<dynamic>)
      .map((e) => BattingLeaderboardRowRes.fromJson(e as Map<String, dynamic>))
      .toList(),
  bowlingLeaderboard: (json['bowlingLeaderboard'] as List<dynamic>)
      .map((e) => BowlingLeaderboardRowRes.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TournamentLeaderboardsResToJson(
  TournamentLeaderboardsRes instance,
) => <String, dynamic>{
  'tournamentId': instance.tournamentId,
  'battingLeaderboard': instance.battingLeaderboard
      .map((e) => e.toJson())
      .toList(),
  'bowlingLeaderboard': instance.bowlingLeaderboard
      .map((e) => e.toJson())
      .toList(),
};
