import 'package:json_annotation/json_annotation.dart';

part 'strike.g.dart';

/// Who is on strike, exactly as the server reported it.
///
/// The client never derives this. Rotation is computed server-side — odd runs
/// run and the end of an over each flip strike, and both on one ball cancel —
/// so this model is only ever built from a response payload, never from a tap.
///
/// [rotated] and [rotationReason] describe the delivery that produced the
/// state, so they are absent from the `start-innings` payload, which has no
/// delivery behind it.
@JsonSerializable()
class Strike {
  final String? strikerId;
  final String? strikerName;
  final String? nonStrikerId;
  final String? nonStrikerName;

  /// True when the striker after the last ball is the non-striker from before
  /// it. Null when this state did not come from a delivery.
  final bool? rotated;

  /// `odd_runs`, `over_end`, or null. Null both when nothing rotated and when
  /// both rules fired and cancelled — read [rotated] for whether strike
  /// actually changed.
  final String? rotationReason;

  Strike({
    this.strikerId,
    this.strikerName,
    this.nonStrikerId,
    this.nonStrikerName,
    this.rotated,
    this.rotationReason,
  });

  factory Strike.fromJson(Map<String, dynamic> json) => _$StrikeFromJson(json);

  Map<String, dynamic> toJson() => _$StrikeToJson(this);
}
