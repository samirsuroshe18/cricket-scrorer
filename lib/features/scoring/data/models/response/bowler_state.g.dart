// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bowler_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BowlerState _$BowlerStateFromJson(Map<String, dynamic> json) => BowlerState(
  currentBowlerId: json['currentBowlerId'] as String?,
  currentBowlerName: json['currentBowlerName'] as String?,
  previousBowlerId: json['previousBowlerId'] as String?,
  previousBowlerName: json['previousBowlerName'] as String?,
);

Map<String, dynamic> _$BowlerStateToJson(BowlerState instance) =>
    <String, dynamic>{
      'currentBowlerId': instance.currentBowlerId,
      'currentBowlerName': instance.currentBowlerName,
      'previousBowlerId': instance.previousBowlerId,
      'previousBowlerName': instance.previousBowlerName,
    };
