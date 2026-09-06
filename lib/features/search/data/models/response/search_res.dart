import 'package:json_annotation/json_annotation.dart';

part 'search_res.g.dart';

/// One row of `GET /v1/search`'s `organizations` array — see `docs/api.md`.
/// Every organization is searchable regardless of the caller's membership;
/// there is no visibility/privacy concept on this model.
@JsonSerializable()
class SearchOrganizationRes {
  final String id;
  final String name;
  final int memberCount;

  SearchOrganizationRes({
    required this.id,
    required this.name,
    required this.memberCount,
  });

  factory SearchOrganizationRes.fromJson(Map<String, dynamic> json) =>
      _$SearchOrganizationResFromJson(json);

  Map<String, dynamic> toJson() => _$SearchOrganizationResToJson(this);
}

/// One row of the same response's `tournaments` array.
@JsonSerializable()
class SearchTournamentRes {
  final String id;
  final String name;
  final String organizationName;
  final String format;
  final String status;

  SearchTournamentRes({
    required this.id,
    required this.name,
    required this.organizationName,
    required this.format,
    required this.status,
  });

  factory SearchTournamentRes.fromJson(Map<String, dynamic> json) =>
      _$SearchTournamentResFromJson(json);

  Map<String, dynamic> toJson() => _$SearchTournamentResToJson(this);
}

/// `GET /v1/search`'s full response `data` — both lists may be empty, which
/// is not an error, just no matches.
@JsonSerializable(explicitToJson: true)
class SearchRes {
  final List<SearchOrganizationRes> organizations;
  final List<SearchTournamentRes> tournaments;

  SearchRes({
    required this.organizations,
    required this.tournaments,
  });

  factory SearchRes.fromJson(Map<String, dynamic> json) =>
      _$SearchResFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResToJson(this);
}
