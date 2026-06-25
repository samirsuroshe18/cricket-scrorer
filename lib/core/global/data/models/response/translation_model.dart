// To parse this JSON data, do
//
//     final translation = translationFromJson(jsonString);

import 'package:json_annotation/json_annotation.dart';

part 'translation_model.g.dart';

@JsonSerializable()
class TranslationModel {
  @JsonKey(name: '_id')
  final String id;

  final String languageCode;

  final Map<String, String> strings;

  final int version;

  final DateTime createdAt;

  final DateTime updatedAt;

  const TranslationModel({
    required this.id,
    required this.languageCode,
    required this.strings,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TranslationModel.fromJson(Map<String, dynamic> json) =>
      _$TranslationModelFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationModelToJson(this);
}
