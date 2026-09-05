// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_tournament_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTournamentReq _$CreateTournamentReqFromJson(Map<String, dynamic> json) =>
    CreateTournamentReq(
      name: json['name'] as String,
      format: json['format'] as String,
    );

Map<String, dynamic> _$CreateTournamentReqToJson(
  CreateTournamentReq instance,
) => <String, dynamic>{'name': instance.name, 'format': instance.format};
