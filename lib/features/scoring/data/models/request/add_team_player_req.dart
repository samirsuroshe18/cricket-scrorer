/// Body of `POST /v1/team/:teamId/players`. Not `@JsonSerializable()`: the
/// server treats `null` and an absent key the same, but omitting unset fields
/// keeps the wire body minimal and matches [UpdatePlayerReq].
class AddTeamPlayerReq {
  final String name;
  final String? role;
  final int? jerseyNumber;

  AddTeamPlayerReq({required this.name, this.role, this.jerseyNumber});

  Map<String, dynamic> toJson() => {
    'name': name,
    if (role != null) 'role': role,
    if (jerseyNumber != null) 'jerseyNumber': jerseyNumber,
  };
}
