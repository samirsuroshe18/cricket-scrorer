// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scorer_candidates_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScorerCandidatesRes _$ScorerCandidatesResFromJson(Map<String, dynamic> json) =>
    ScorerCandidatesRes(
      candidates: (json['candidates'] as List<dynamic>)
          .map((e) => MatchUserRef.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ScorerCandidatesResToJson(
  ScorerCandidatesRes instance,
) => <String, dynamic>{
  'candidates': instance.candidates.map((e) => e.toJson()).toList(),
};
