// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_players_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyPlayerRow _$MyPlayerRowFromJson(Map<String, dynamic> json) => MyPlayerRow(
  playerId: json['playerId'] as String,
  playerName: json['playerName'] as String,
  role: json['role'] as String? ?? 'unknown',
  jerseyNumber: (json['jerseyNumber'] as num?)?.toInt(),
  isClaimed: json['isClaimed'] as bool? ?? false,
  onTeam: json['onTeam'] as bool? ?? false,
);

Map<String, dynamic> _$MyPlayerRowToJson(MyPlayerRow instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'playerName': instance.playerName,
      'role': instance.role,
      'jerseyNumber': instance.jerseyNumber,
      'isClaimed': instance.isClaimed,
      'onTeam': instance.onTeam,
    };

MyPlayersRes _$MyPlayersResFromJson(Map<String, dynamic> json) => MyPlayersRes(
  players: (json['players'] as List<dynamic>)
      .map((e) => MyPlayerRow.fromJson(e as Map<String, dynamic>))
      .toList(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$MyPlayersResToJson(MyPlayersRes instance) =>
    <String, dynamic>{
      'players': instance.players,
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
    };
