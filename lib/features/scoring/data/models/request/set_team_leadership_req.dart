/// Body of `PATCH /v1/team/:teamId` when setting the team-level captain and
/// vice-captain. The endpoint still requires `name`, so the current name and
/// short name ride along.
///
/// Not `@JsonSerializable()` because the wire contract is presence-sensitive:
/// an *absent* leader key means "leave unchanged" while an explicit `null`
/// clears it. This body always sends both leader keys — a caller changing one
/// slot passes the other slot's current value — so [toJson] keeps null leaders.
class SetTeamLeadershipReq {
  final String name;
  final String? shortName;
  final String? captainId;
  final String? viceCaptainId;

  SetTeamLeadershipReq({
    required this.name,
    this.shortName,
    this.captainId,
    this.viceCaptainId,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    if (shortName != null) 'shortName': shortName,
    'captainId': captainId,
    'viceCaptainId': viceCaptainId,
  };
}
