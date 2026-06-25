// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationVersion _$TranslationVersionFromJson(Map<String, dynamic> json) =>
    TranslationVersion(
      globalVersion: (json['globalVersion'] as num).toInt(),
      languages: (json['languages'] as List<dynamic>)
          .map((e) => LanguageVersion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TranslationVersionToJson(TranslationVersion instance) =>
    <String, dynamic>{
      'globalVersion': instance.globalVersion,
      'languages': instance.languages,
    };

LanguageVersion _$LanguageVersionFromJson(Map<String, dynamic> json) =>
    LanguageVersion(
      languageCode: json['languageCode'] as String,
      version: (json['version'] as num).toInt(),
    );

Map<String, dynamic> _$LanguageVersionToJson(LanguageVersion instance) =>
    <String, dynamic>{
      'languageCode': instance.languageCode,
      'version': instance.version,
    };
