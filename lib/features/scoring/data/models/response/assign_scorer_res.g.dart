// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assign_scorer_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignScorerRes _$AssignScorerResFromJson(Map<String, dynamic> json) =>
    AssignScorerRes(
      matchId: json['matchId'] as String,
      assignedScorer: json['assignedScorer'] == null
          ? null
          : MatchUserRef.fromJson(
              json['assignedScorer'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$AssignScorerResToJson(AssignScorerRes instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'assignedScorer': instance.assignedScorer?.toJson(),
    };
