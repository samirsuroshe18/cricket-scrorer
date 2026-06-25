import 'package:json_annotation/json_annotation.dart';

part 'translation_version.g.dart';

@JsonSerializable()
class TranslationVersion {
  final int globalVersion;
  final List<LanguageVersion> languages;

  const TranslationVersion({
    required this.globalVersion,
    required this.languages,
  });

  factory TranslationVersion.fromJson(Map<String, dynamic> json) =>
      _$TranslationVersionFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationVersionToJson(this);
}

@JsonSerializable()
class LanguageVersion {
  final String languageCode;
  final int version;

  const LanguageVersion({
    required this.languageCode,
    required this.version,
  });

  factory LanguageVersion.fromJson(Map<String, dynamic> json) =>
      _$LanguageVersionFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageVersionToJson(this);
}
