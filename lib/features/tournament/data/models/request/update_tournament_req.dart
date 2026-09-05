/// Not `@JsonSerializable()`: the backend's `PATCH /v1/tournament/:id`
/// treats an *absent* field as "leave unchanged" but an explicit `null` as
/// "the caller sent this field" (which then fails validation, since
/// `name`/`format`/`status` can never legitimately be cleared to nothing —
/// see docs/api.md). Generated `toJson()` would serialize an unset field as
/// JSON `null` rather than omitting the key, which is exactly the wrong
/// wire behavior here. This class's `toJson()` omits every field that
/// wasn't provided.
class UpdateTournamentReq {
  final String? name;
  final String? format;
  final String? status;

  UpdateTournamentReq({this.name, this.format, this.status});

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (format != null) 'format': format,
    if (status != null) 'status': status,
  };
}
