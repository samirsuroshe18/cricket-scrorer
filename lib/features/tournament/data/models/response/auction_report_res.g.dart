// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction_report_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuctionSquadRes _$AuctionSquadResFromJson(Map<String, dynamic> json) =>
    AuctionSquadRes(
      tournamentId: json['tournamentId'] as String,
      teams: (json['teams'] as List<dynamic>)
          .map((e) => AuctionSquadTeamRes.fromJson(e as Map<String, dynamic>))
          .toList(),
      unsold: (json['unsold'] as List<dynamic>)
          .map(
            (e) => AuctionUnsoldPlayerRes.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$AuctionSquadResToJson(AuctionSquadRes instance) =>
    <String, dynamic>{
      'tournamentId': instance.tournamentId,
      'teams': instance.teams.map((e) => e.toJson()).toList(),
      'unsold': instance.unsold.map((e) => e.toJson()).toList(),
    };

AuctionSquadTeamRes _$AuctionSquadTeamResFromJson(Map<String, dynamic> json) =>
    AuctionSquadTeamRes(
      teamId: json['teamId'] as String,
      teamName: json['teamName'] as String,
      ownerId: json['ownerId'] as String,
      ownerName: json['ownerName'] as String,
      budget: (json['budget'] as num).toInt(),
      spent: (json['spent'] as num).toInt(),
      remaining: (json['remaining'] as num).toInt(),
      players: (json['players'] as List<dynamic>)
          .map((e) => AuctionSquadPlayerRes.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AuctionSquadTeamResToJson(
  AuctionSquadTeamRes instance,
) => <String, dynamic>{
  'teamId': instance.teamId,
  'teamName': instance.teamName,
  'ownerId': instance.ownerId,
  'ownerName': instance.ownerName,
  'budget': instance.budget,
  'spent': instance.spent,
  'remaining': instance.remaining,
  'players': instance.players.map((e) => e.toJson()).toList(),
};

AuctionSquadPlayerRes _$AuctionSquadPlayerResFromJson(
  Map<String, dynamic> json,
) => AuctionSquadPlayerRes(
  playerId: json['playerId'] as String,
  playerName: json['playerName'] as String,
  role: json['role'] as String?,
  soldPrice: (json['soldPrice'] as num).toInt(),
);

Map<String, dynamic> _$AuctionSquadPlayerResToJson(
  AuctionSquadPlayerRes instance,
) => <String, dynamic>{
  'playerId': instance.playerId,
  'playerName': instance.playerName,
  'role': instance.role,
  'soldPrice': instance.soldPrice,
};

AuctionUnsoldPlayerRes _$AuctionUnsoldPlayerResFromJson(
  Map<String, dynamic> json,
) => AuctionUnsoldPlayerRes(
  playerId: json['playerId'] as String,
  playerName: json['playerName'] as String,
  role: json['role'] as String?,
  basePrice: (json['basePrice'] as num).toInt(),
);

Map<String, dynamic> _$AuctionUnsoldPlayerResToJson(
  AuctionUnsoldPlayerRes instance,
) => <String, dynamic>{
  'playerId': instance.playerId,
  'playerName': instance.playerName,
  'role': instance.role,
  'basePrice': instance.basePrice,
};

AuctionHistoryRes _$AuctionHistoryResFromJson(Map<String, dynamic> json) =>
    AuctionHistoryRes(
      tournamentId: json['tournamentId'] as String,
      entries: (json['entries'] as List<dynamic>)
          .map(
            (e) => AuctionHistoryEntryRes.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$AuctionHistoryResToJson(AuctionHistoryRes instance) =>
    <String, dynamic>{
      'tournamentId': instance.tournamentId,
      'entries': instance.entries.map((e) => e.toJson()).toList(),
    };

AuctionHistoryEntryRes _$AuctionHistoryEntryResFromJson(
  Map<String, dynamic> json,
) => AuctionHistoryEntryRes(
  lotId: json['lotId'] as String,
  playerId: json['playerId'] as String,
  playerName: json['playerName'] as String,
  role: json['role'] as String?,
  basePrice: (json['basePrice'] as num).toInt(),
  outcome: json['outcome'] as String,
  soldPrice: (json['soldPrice'] as num?)?.toInt(),
  teamId: json['teamId'] as String?,
  teamName: json['teamName'] as String?,
  resolvedAt: DateTime.parse(json['resolvedAt'] as String),
);

Map<String, dynamic> _$AuctionHistoryEntryResToJson(
  AuctionHistoryEntryRes instance,
) => <String, dynamic>{
  'lotId': instance.lotId,
  'playerId': instance.playerId,
  'playerName': instance.playerName,
  'role': instance.role,
  'basePrice': instance.basePrice,
  'outcome': instance.outcome,
  'soldPrice': instance.soldPrice,
  'teamId': instance.teamId,
  'teamName': instance.teamName,
  'resolvedAt': instance.resolvedAt.toIso8601String(),
};
