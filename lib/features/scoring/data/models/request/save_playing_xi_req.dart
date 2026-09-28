import 'package:json_annotation/json_annotation.dart';

part 'save_playing_xi_req.g.dart';

/// Body of `PATCH /v1/match/:matchId/squad/:side/playing-xi` — the only way to
/// move players between the Playing XI and the Bench once scoring has started
/// (`PUT` refuses then). [side] (`teamA` / `teamB`) belongs to the path, so it
/// is kept off the JSON body. [playingXI] holds player ids; an empty list is a
/// deliberately empty XI.
@JsonSerializable()
class SavePlayingXiReq {
  @JsonKey(includeToJson: false)
  final String side;
  final List<String> playingXI;

  SavePlayingXiReq({required this.side, required this.playingXI});

  factory SavePlayingXiReq.fromJson(Map<String, dynamic> json) =>
      _$SavePlayingXiReqFromJson(json);

  Map<String, dynamic> toJson() => _$SavePlayingXiReqToJson(this);
}
