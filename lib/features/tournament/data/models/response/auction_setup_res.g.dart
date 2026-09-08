// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction_setup_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuctionSetupRes _$AuctionSetupResFromJson(Map<String, dynamic> json) =>
    AuctionSetupRes(
      tournamentId: json['tournamentId'] as String,
      minSquadSize: (json['minSquadSize'] as num?)?.toInt(),
      maxSquadSize: (json['maxSquadSize'] as num?)?.toInt(),
      categoryCaps: (json['categoryCaps'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      ),
      owners: (json['owners'] as List<dynamic>)
          .map((e) => AuctionOwnerRes.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AuctionSetupResToJson(AuctionSetupRes instance) =>
    <String, dynamic>{
      'tournamentId': instance.tournamentId,
      'minSquadSize': instance.minSquadSize,
      'maxSquadSize': instance.maxSquadSize,
      'categoryCaps': instance.categoryCaps,
      'owners': instance.owners.map((e) => e.toJson()).toList(),
    };

AuctionOwnerRes _$AuctionOwnerResFromJson(Map<String, dynamic> json) =>
    AuctionOwnerRes(
      teamId: json['teamId'] as String,
      teamName: json['teamName'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      budget: (json['budget'] as num).toInt(),
    );

Map<String, dynamic> _$AuctionOwnerResToJson(AuctionOwnerRes instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'teamName': instance.teamName,
      'userId': instance.userId,
      'userName': instance.userName,
      'budget': instance.budget,
    };
