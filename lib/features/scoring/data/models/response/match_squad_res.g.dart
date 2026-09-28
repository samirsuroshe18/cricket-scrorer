// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_squad_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SquadSidePlayerRes _$SquadSidePlayerResFromJson(Map<String, dynamic> json) =>
    SquadSidePlayerRes(
      playerId: json['playerId'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      jerseyNumber: (json['jerseyNumber'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SquadSidePlayerResToJson(SquadSidePlayerRes instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'name': instance.name,
      'role': instance.role,
      'jerseyNumber': instance.jerseyNumber,
    };

SquadSideRes _$SquadSideResFromJson(Map<String, dynamic> json) => SquadSideRes(
  teamId: json['teamId'] as String,
  players:
      (json['players'] as List<dynamic>?)
          ?.map((e) => SquadSidePlayerRes.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  captainId: json['captainId'] as String?,
  viceCaptainId: json['viceCaptainId'] as String?,
  keeperId: json['keeperId'] as String?,
  playingXI: (json['playingXI'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  savedAt: json['savedAt'] as String?,
);

Map<String, dynamic> _$SquadSideResToJson(SquadSideRes instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'players': instance.players.map((e) => e.toJson()).toList(),
      'captainId': instance.captainId,
      'viceCaptainId': instance.viceCaptainId,
      'keeperId': instance.keeperId,
      'playingXI': instance.playingXI,
      'savedAt': instance.savedAt,
    };

MatchSquadRes _$MatchSquadResFromJson(Map<String, dynamic> json) =>
    MatchSquadRes(
      matchId: json['matchId'] as String,
      inningsStarted: json['inningsStarted'] as bool? ?? false,
      teamA: SquadSideRes.fromJson(json['teamA'] as Map<String, dynamic>),
      teamB: SquadSideRes.fromJson(json['teamB'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MatchSquadResToJson(MatchSquadRes instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'inningsStarted': instance.inningsStarted,
      'teamA': instance.teamA.toJson(),
      'teamB': instance.teamB.toJson(),
    };
