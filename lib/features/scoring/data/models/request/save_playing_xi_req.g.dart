// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_playing_xi_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavePlayingXiReq _$SavePlayingXiReqFromJson(Map<String, dynamic> json) =>
    SavePlayingXiReq(
      side: json['side'] as String,
      playingXI: (json['playingXI'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SavePlayingXiReqToJson(SavePlayingXiReq instance) =>
    <String, dynamic>{'playingXI': instance.playingXI};
