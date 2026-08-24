import 'package:json_annotation/json_annotation.dart';

part 'wicket.g.dart';

/// A dismissal, exactly as the server reported it. Null on an ordinary
/// delivery, so presence is the check — there is no separate boolean.
///
/// Both `incoming*` fields are null on the final wicket: nobody is left to come
/// in, and the innings ends.
@JsonSerializable()
class Wicket {
  /// One of [WicketType]'s six values.
  final String? type;

  final String? dismissedPlayerId;
  final String? dismissedPlayerName;
  final String? incomingBatsmanId;
  final String? incomingBatsmanName;

  Wicket({
    this.type,
    this.dismissedPlayerId,
    this.dismissedPlayerName,
    this.incomingBatsmanId,
    this.incomingBatsmanName,
  });

  factory Wicket.fromJson(Map<String, dynamic> json) => _$WicketFromJson(json);

  Map<String, dynamic> toJson() => _$WicketToJson(this);
}
