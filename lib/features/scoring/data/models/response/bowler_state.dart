import 'package:json_annotation/json_annotation.dart';

part 'bowler_state.g.dart';

/// The bowler half of the `match:state` join ack.
///
/// This is what lets a scorer resuming on a fresh app launch know whether a
/// bowler is still owed without waiting for the next ball:
/// [currentBowlerId] null alongside a non-null [previousBowlerId] *is* the
/// "between overs, nobody selected yet" state.
///
/// [previousBowlerId] is the bowler of the last completed over — the one
/// `select-bowler` will refuse under Law 17.6.
@JsonSerializable()
class BowlerState {
  final String? currentBowlerId;
  final String? currentBowlerName;
  final String? previousBowlerId;
  final String? previousBowlerName;

  BowlerState({
    this.currentBowlerId,
    this.currentBowlerName,
    this.previousBowlerId,
    this.previousBowlerName,
  });

  /// True when the innings is open but nobody is set to bowl. The console reads
  /// this rather than recombining the four fields at each call site.
  bool get awaitingBowler => currentBowlerId == null;

  factory BowlerState.fromJson(Map<String, dynamic> json) =>
      _$BowlerStateFromJson(json);

  Map<String, dynamic> toJson() => _$BowlerStateToJson(this);
}
