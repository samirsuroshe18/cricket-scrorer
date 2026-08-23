// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_match_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamRef _$TeamRefFromJson(Map<String, dynamic> json) => TeamRef(
  id: json['id'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$TeamRefToJson(TeamRef instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

CreateMatchRes _$CreateMatchResFromJson(Map<String, dynamic> json) =>
    CreateMatchRes(
      matchId: json['matchId'] as String,
      teamA: TeamRef.fromJson(json['teamA'] as Map<String, dynamic>),
      teamB: TeamRef.fromJson(json['teamB'] as Map<String, dynamic>),
      totalOvers: (json['totalOvers'] as num).toInt(),
      status: json['status'] as String,
      syncStatus: json['syncStatus'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$CreateMatchResToJson(CreateMatchRes instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'teamA': instance.teamA.toJson(),
      'teamB': instance.teamB.toJson(),
      'totalOvers': instance.totalOvers,
      'status': instance.status,
      'syncStatus': instance.syncStatus,
      'createdAt': instance.createdAt,
    };
