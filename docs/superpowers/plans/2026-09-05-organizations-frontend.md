# Organizations Frontend Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans or manual inline execution, task-by-task. After Tasks 1–7 (functionally correct, deliberately plain), Task 8 is a required superpowers:frontend-design pass — do not skip it, matching the mistake the team-profile feature's first pass made. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a scorer create an Organization, add members by email, create teams under it, and manage membership — mirroring the already-shipped backend contract — while proving ad-hoc match creation is pixel-for-pixel unchanged.

**Architecture:** A new `lib/features/organization/` vertical (data/domain/presentation), following the exact clean-architecture shape `lib/features/scoring/` already establishes for team-profile. Two new screens (`OrganizationsListScreen`, `OrganizationDetailScreen`), reached from a new Home app-bar icon. `Team`'s existing client model (`TeamSummary`, `TeamProfileRes`) gains an `organization` field, since the backend now returns one.

**Tech Stack:** Flutter, GetX (state + DI + routing), `json_serializable`, `flutter_test` + `get_test`-style fakes (no mocking package — this codebase writes fakes by hand).

**Spec:** Backend contract already implemented: [docs/api.md](../../../../docs/api.md)'s `## Organization` section (workspace root). No new spec document for the frontend — the backend contract is binding; this plan is the design.

## Global Constraints

- Ad-hoc match creation (`CreateMatchScreen` with two typed names, no `teamAId`/`teamBId`) must render and behave identically after every task — verified explicitly in Task 9's on-device checklist, not assumed.
- Every new screen in Tasks 1–7 is deliberately plain/functional — no aesthetic work yet. Task 8 (`frontend-design`) is mandatory before this plan is considered done; the team-profile feature shipped once without it and needed a follow-up pass, which cost a whole review cycle.
- New client-facing strings need: a `TranslationKeys` constant, AND a CMS `bulk-update` record (`POST /api/v1/translations/bulk-update`) — the CMS record is what the app actually renders once translations sync; the local `en.dart`/`hi.dart`/`mr.dart` maps are not being kept current for newer features (confirmed: `team_profile`/`roster`/etc. keys exist in `TranslationKeys` but not in `en.dart` — this repo relies on the CMS as the only real source since that feature shipped) and this plan follows the same precedent rather than fighting it.
- Response envelope: every use case returns `Either<CricketResponse<T>, CricketFailure>` — the same pattern as every existing use case in this repo. Nothing bypasses it.
- Follow `MatchRepository`'s error-mapping shape exactly in the new `OrganizationRepositoryImpl` — `Either.result(CricketResponse(data: X.fromJson(...), message: ...))` / `Either.fallback(response.fallback)`.
- Run tests with `flutter test` (or `flutter test test/path/to/file_test.dart` for one file); `flutter analyze` for lint. Both via background Bash — foreground calls have repeatedly exceeded this session's tool timeout.

---

## Task 1: Client data models

**Files:**
- Create: `lib/features/organization/data/models/response/organization_summary_res.dart`
- Create: `lib/features/organization/data/models/response/organization_detail_res.dart`
- Create: `lib/features/organization/data/models/request/create_organization_req.dart`
- Create: `lib/features/organization/data/models/request/add_organization_member_req.dart`
- Create: `lib/features/organization/data/models/request/create_organization_team_req.dart`
- Modify: `lib/features/scoring/data/models/response/my_teams_res.dart` (add `organization` to `TeamSummary`)
- Modify: `lib/features/scoring/data/models/response/team_profile_res.dart` (add `organization` to `TeamProfileRes`)
- Test: `test/features/organization/data/models/organization_detail_res_test.dart`

**Interfaces:**
- Produces: `OrganizationRef` (shared `{id, name}` shape, used by both `TeamSummary.organization` and `TeamProfileRes.organization`), `OrganizationSummaryRes` (one row of `GET /v1/organization`), `OrganizationDetailRes` + `OrganizationMemberRes` + `OrganizationTeamRef` (the shape of `POST /v1/organization` and `GET /v1/organization/:orgId`, which are identical per `docs/api.md`), `CreateOrganizationReq`, `AddOrganizationMemberReq`, `CreateOrganizationTeamReq`.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/organization/data/models/organization_detail_res_test.dart
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OrganizationDetailRes.fromJson parses owner, members, and teams', () {
    final json = {
      'id': 'org-1',
      'name': 'Riverside Cricket Club',
      'owner': {'id': 'user-1', 'name': 'Asha'},
      'members': [
        {'id': 'user-1', 'name': 'Asha', 'role': 'owner'},
        {'id': 'user-2', 'name': 'Vikram', 'role': 'member'},
      ],
      'teams': [
        {'id': 'team-1', 'name': 'Riverside U19', 'shortName': 'RU19'},
      ],
    };

    final res = OrganizationDetailRes.fromJson(json);

    expect(res.id, 'org-1');
    expect(res.name, 'Riverside Cricket Club');
    expect(res.owner.name, 'Asha');
    expect(res.members.length, 2);
    expect(res.members[1].role, 'member');
    expect(res.teams.single.shortName, 'RU19');
  });

  test('OrganizationDetailRes.fromJson handles a team with no shortName', () {
    final json = {
      'id': 'org-1',
      'name': 'Riverside Cricket Club',
      'owner': {'id': 'user-1', 'name': 'Asha'},
      'members': <Map<String, dynamic>>[],
      'teams': [
        {'id': 'team-1', 'name': 'Riverside U19', 'shortName': null},
      ],
    };

    final res = OrganizationDetailRes.fromJson(json);

    expect(res.teams.single.shortName, isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/organization/data/models/organization_detail_res_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart'`.

- [ ] **Step 3: Write minimal implementation**

`lib/features/organization/data/models/response/organization_detail_res.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'organization_detail_res.g.dart';

/// A user reference `{id, name}` — the shape `owner` and each `members`
/// entry share on `POST /v1/organization` and `GET /v1/organization/:orgId`.
@JsonSerializable()
class OrganizationUserRef {
  final String id;
  final String name;

  OrganizationUserRef({required this.id, required this.name});

  factory OrganizationUserRef.fromJson(Map<String, dynamic> json) =>
      _$OrganizationUserRefFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationUserRefToJson(this);
}

/// One row of `OrganizationDetailRes.members` — a user plus their role in
/// this specific organization.
@JsonSerializable()
class OrganizationMemberRes {
  final String id;
  final String name;

  /// `'owner'` or `'member'` — see docs/api.md's `## Organization` section.
  final String role;

  OrganizationMemberRes({
    required this.id,
    required this.name,
    required this.role,
  });

  factory OrganizationMemberRes.fromJson(Map<String, dynamic> json) =>
      _$OrganizationMemberResFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationMemberResToJson(this);
}

/// One row of `OrganizationDetailRes.teams` — deliberately lighter than
/// [TeamSummary]: this list never needs to distinguish "which org" (it's
/// already scoped to one) the way the my-teams picker does.
@JsonSerializable()
class OrganizationTeamRef {
  final String id;
  final String name;
  final String? shortName;

  OrganizationTeamRef({required this.id, required this.name, this.shortName});

  factory OrganizationTeamRef.fromJson(Map<String, dynamic> json) =>
      _$OrganizationTeamRefFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationTeamRefToJson(this);
}

/// `POST /v1/organization` and `GET /v1/organization/:orgId` share this
/// exact response shape — see docs/api.md.
@JsonSerializable(explicitToJson: true)
class OrganizationDetailRes {
  final String id;
  final String name;
  final OrganizationUserRef owner;
  final List<OrganizationMemberRes> members;
  final List<OrganizationTeamRef> teams;

  OrganizationDetailRes({
    required this.id,
    required this.name,
    required this.owner,
    required this.members,
    required this.teams,
  });

  factory OrganizationDetailRes.fromJson(Map<String, dynamic> json) =>
      _$OrganizationDetailResFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationDetailResToJson(this);
}
```

`lib/features/organization/data/models/response/organization_summary_res.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'organization_summary_res.g.dart';

/// One row of `GET /v1/organization` — the list of orgs the caller owns or
/// belongs to. Deliberately lighter than [OrganizationDetailRes]: the list
/// screen never needs the full member/team rows, just enough to decide
/// which org to open.
@JsonSerializable()
class OrganizationSummaryRes {
  final String id;
  final String name;

  /// `'owner'` or `'member'` — the caller's own role in this org.
  final String myRole;
  final int memberCount;
  final int teamCount;

  OrganizationSummaryRes({
    required this.id,
    required this.name,
    required this.myRole,
    required this.memberCount,
    required this.teamCount,
  });

  factory OrganizationSummaryRes.fromJson(Map<String, dynamic> json) =>
      _$OrganizationSummaryResFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationSummaryResToJson(this);
}

/// `GET /v1/organization` — the envelope around [OrganizationSummaryRes].
@JsonSerializable(explicitToJson: true)
class MyOrganizationsRes {
  final List<OrganizationSummaryRes> organizations;

  MyOrganizationsRes({required this.organizations});

  factory MyOrganizationsRes.fromJson(Map<String, dynamic> json) =>
      _$MyOrganizationsResFromJson(json);

  Map<String, dynamic> toJson() => _$MyOrganizationsResToJson(this);
}
```

`lib/features/organization/data/models/request/create_organization_req.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'create_organization_req.g.dart';

@JsonSerializable()
class CreateOrganizationReq {
  final String name;

  CreateOrganizationReq({required this.name});

  factory CreateOrganizationReq.fromJson(Map<String, dynamic> json) =>
      _$CreateOrganizationReqFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrganizationReqToJson(this);
}
```

`lib/features/organization/data/models/request/add_organization_member_req.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'add_organization_member_req.g.dart';

@JsonSerializable()
class AddOrganizationMemberReq {
  final String email;

  AddOrganizationMemberReq({required this.email});

  factory AddOrganizationMemberReq.fromJson(Map<String, dynamic> json) =>
      _$AddOrganizationMemberReqFromJson(json);

  Map<String, dynamic> toJson() => _$AddOrganizationMemberReqToJson(this);
}
```

`lib/features/organization/data/models/request/create_organization_team_req.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'create_organization_team_req.g.dart';

@JsonSerializable()
class CreateOrganizationTeamReq {
  final String name;
  final String? shortName;

  CreateOrganizationTeamReq({required this.name, this.shortName});

  factory CreateOrganizationTeamReq.fromJson(Map<String, dynamic> json) =>
      _$CreateOrganizationTeamReqFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrganizationTeamReqToJson(this);
}
```

Modify `lib/features/scoring/data/models/response/my_teams_res.dart` — add the shared `OrganizationRef` and the new field on `TeamSummary`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'my_teams_res.g.dart';

/// The `{id, name}` an org-owned `Team` carries — shared by [TeamSummary]
/// and `TeamProfileRes`. Named distinctly from
/// `organization/OrganizationUserRef` even though the shape is identical:
/// that one is a *user* reference (owner/member), this one is an
/// *organization* reference. Collapsing them into one shared type would
/// couple two features' wire contracts that only coincidentally match today.
@JsonSerializable()
class OrganizationRef {
  final String id;
  final String name;

  OrganizationRef({required this.id, required this.name});

  factory OrganizationRef.fromJson(Map<String, dynamic> json) =>
      _$OrganizationRefFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationRefToJson(this);
}

/// One row of `GET /v1/team` — the source list for the "reuse this team"
/// picker on `CreateMatchScreen`. A team appears once regardless of how many
/// matches reference it.
@JsonSerializable(explicitToJson: true)
class TeamSummary {
  final String id;
  final String name;
  final String? shortName;

  /// Non-null when this team belongs to an organization the caller is a
  /// member of — see docs/api.md's `## Organization` section. Null for a
  /// standalone team, which is every team created before this feature
  /// shipped, and every ad-hoc team created since.
  final OrganizationRef? organization;

  TeamSummary({
    required this.id,
    required this.name,
    this.shortName,
    this.organization,
  });

  factory TeamSummary.fromJson(Map<String, dynamic> json) =>
      _$TeamSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$TeamSummaryToJson(this);
}

/// `GET /v1/team` — the caller's own teams.
@JsonSerializable(explicitToJson: true)
class MyTeamsRes {
  final List<TeamSummary> teams;

  MyTeamsRes({required this.teams});

  factory MyTeamsRes.fromJson(Map<String, dynamic> json) =>
      _$MyTeamsResFromJson(json);

  Map<String, dynamic> toJson() => _$MyTeamsResToJson(this);
}
```

Modify `lib/features/scoring/data/models/response/team_profile_res.dart` — add the `organization` field, importing the type just added:

```dart
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart' show OrganizationRef;
import 'package:json_annotation/json_annotation.dart';

part 'team_profile_res.g.dart';

@JsonSerializable()
class TeamRosterPlayer {
  final String playerId;
  final String playerName;
  final int? jerseyNumber;
  final String role;

  TeamRosterPlayer({
    required this.playerId,
    required this.playerName,
    this.jerseyNumber,
    required this.role,
  });

  factory TeamRosterPlayer.fromJson(Map<String, dynamic> json) =>
      _$TeamRosterPlayerFromJson(json);

  Map<String, dynamic> toJson() => _$TeamRosterPlayerToJson(this);
}

/// `GET /v1/team/:teamId` — a team's display identity plus every player
/// accumulated onto its roster. `organization` is non-null when this team
/// belongs to one — see `TeamSummary.organization`'s own comment for why
/// this reuses [OrganizationRef] rather than a second identical type.
@JsonSerializable(explicitToJson: true)
class TeamProfileRes {
  final String teamId;
  final String name;
  final String? shortName;
  final OrganizationRef? organization;
  final List<TeamRosterPlayer> roster;

  TeamProfileRes({
    required this.teamId,
    required this.name,
    this.shortName,
    this.organization,
    required this.roster,
  });

  factory TeamProfileRes.fromJson(Map<String, dynamic> json) =>
      _$TeamProfileResFromJson(json);

  Map<String, dynamic> toJson() => _$TeamProfileResToJson(this);
}
```

Run code generation for every new/modified `@JsonSerializable` file:

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/organization/data/models/organization_detail_res_test.dart`
Expected: PASS, 2 tests.

Also run the existing team-profile model test to confirm the additive field doesn't break decoding of a response that omits it (the real backend always sends it now, but this guards the model itself):
Run: `flutter test test/features/scoring/data/models/response/team_profile_res_test.dart`
Expected: PASS, unaffected — `organization` is nullable and optional in the constructor.

- [ ] **Step 5: Commit**

```bash
git add lib/features/organization/data/models lib/features/scoring/data/models/response/my_teams_res.dart lib/features/scoring/data/models/response/my_teams_res.g.dart lib/features/scoring/data/models/response/team_profile_res.dart lib/features/scoring/data/models/response/team_profile_res.g.dart test/features/organization/data/models
git commit -m "feat: add Organization client models, widen Team models with organization"
```

---

## Task 2: `ApiClient.patch()`, `OrganizationEndpoint`, `OrganizationApiService`

**Files:**
- Modify: `lib/core/network/api_client_service.dart` (add `patch()`, mirroring `put()`)
- Create: `lib/features/organization/data/organization_endpoint.dart`
- Create: `lib/features/organization/data/data_sources/remote/organization_api_service.dart`
- Modify: `lib/features/scoring/data/match_endpoint.dart` (add `updateTeamOrganization` — this one endpoint lives on `/v1/team`, not `/v1/organization`, so it stays with the other team paths)

**Interfaces:**
- Produces: `ApiClient.patch()`, `OrganizationEndpoint` (all `/v1/organization/...` paths), `OrganizationApiService` (raw HTTP calls, `Either<ApiResponseModel, CricketFailure>` — same shape as `MatchApiService`).
- Consumes: `MatchEndpoint.updateTeamOrganization(teamId)` is added here but consumed by `OrganizationApiService`, not `MatchApiService` — the org feature owns the call even though the path lives under `/team`.

- [ ] **Step 1: Write the failing test**

There is no existing per-method unit test for `ApiClient` (`get`/`post`/`put`/`delete` are exercised transitively through repository tests, not directly) — `patch()` follows that same precedent, so this task has no test of its own. Skip to Step 3.

- [ ] **Step 3: Write minimal implementation**

Add to `lib/core/network/api_client_service.dart`, immediately after `put()`:

```dart
  Future<Either<ApiResponseModel, CricketFailure>> patch({
    required String endpoint,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    void Function(int count, int total)? onSendProgress,
    void Function(int count, int total)? onReceiveProgress,
  }) async {
    try {
      Response<dynamic> response = await _dio.patch(
        endpoint,
        data: data,
        cancelToken: cancelToken ?? _cancelToken,
        options: options,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
      );

      return Either.result(
        ApiResponseModel.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Either.fallback(await _handleError(e));
    }
  }
```

`lib/features/organization/data/organization_endpoint.dart`:

```dart
class OrganizationEndpoint {
  const OrganizationEndpoint();

  final String create = '/v1/organization';
  final String listMine = '/v1/organization';

  String detail(String orgId) => '/v1/organization/$orgId';

  String addMember(String orgId) => '/v1/organization/$orgId/members';

  String removeMember(String orgId, String userId) =>
      '/v1/organization/$orgId/members/$userId';

  String createTeam(String orgId) => '/v1/organization/$orgId/teams';

  String delete(String orgId) => '/v1/organization/$orgId';
}
```

Add to `lib/features/scoring/data/match_endpoint.dart` (the one organization-related path that lives on the team router):

```dart
  /// `PATCH /v1/team/:teamId/organization` — attach/detach. Lives here, not
  /// on `OrganizationEndpoint`, because the route itself is under `/v1/team`
  /// — see docs/api.md's `## Organization` section.
  String updateTeamOrganization(String teamId) => '/v1/team/$teamId/organization';
```

`lib/features/organization/data/data_sources/remote/organization_api_service.dart`:

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/request/add_organization_member_req.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_req.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_team_req.dart';
import 'package:cricket_scorer/features/organization/data/organization_endpoint.dart';

class OrganizationApiService {
  final ApiClient apiClient;
  final OrganizationEndpoint organizationEndpoint;

  OrganizationApiService({
    required this.apiClient,
    required this.organizationEndpoint,
  });

  Future<Either<ApiResponseModel, CricketFailure>> createOrganization({
    required CreateOrganizationReq? params,
  }) async {
    return await apiClient.post(
      endpoint: organizationEndpoint.create,
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> getMyOrganizations() async {
    return await apiClient.get(endpoint: organizationEndpoint.listMine);
  }

  Future<Either<ApiResponseModel, CricketFailure>> getOrganization({
    required String orgId,
  }) async {
    return await apiClient.get(endpoint: organizationEndpoint.detail(orgId));
  }

  Future<Either<ApiResponseModel, CricketFailure>> addMember({
    required String orgId,
    required AddOrganizationMemberReq? params,
  }) async {
    return await apiClient.post(
      endpoint: organizationEndpoint.addMember(orgId),
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> removeMember({
    required String orgId,
    required String userId,
  }) async {
    return await apiClient.delete(
      endpoint: organizationEndpoint.removeMember(orgId, userId),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> createTeam({
    required String orgId,
    required CreateOrganizationTeamReq? params,
  }) async {
    return await apiClient.post(
      endpoint: organizationEndpoint.createTeam(orgId),
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> deleteOrganization({
    required String orgId,
  }) async {
    return await apiClient.delete(
      endpoint: organizationEndpoint.delete(orgId),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

No new test to run for this task. Confirm the codebase still compiles:
Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/core/network/api_client_service.dart lib/features/organization/data/organization_endpoint.dart lib/features/organization/data/data_sources/remote/organization_api_service.dart lib/features/scoring/data/match_endpoint.dart
git commit -m "feat: add ApiClient.patch(), OrganizationEndpoint, OrganizationApiService"
```

---

## Task 3: `OrganizationRepository`, use cases, `updateTeamOrganization`, DI

**Files:**
- Create: `lib/features/organization/domain/repositories/organization_repository.dart`
- Create: `lib/features/organization/data/repositories/organization_repository_impl.dart`
- Create: `lib/features/organization/domain/usecases/create_organization.dart`
- Create: `lib/features/organization/domain/usecases/get_my_organizations.dart`
- Create: `lib/features/organization/domain/usecases/get_organization.dart`
- Create: `lib/features/organization/domain/usecases/add_organization_member.dart`
- Create: `lib/features/organization/domain/usecases/remove_organization_member.dart`
- Create: `lib/features/organization/domain/usecases/create_organization_team.dart`
- Create: `lib/features/organization/domain/usecases/delete_organization.dart`
- Modify: `lib/features/scoring/domain/repositories/match_repository.dart` (add `updateTeamOrganization`)
- Modify: `lib/features/scoring/data/repositories/match_repository_impl.dart` (implement it)
- Create: `lib/features/scoring/domain/usecases/update_team_organization.dart`
- Create: `lib/core/di/injection/organization_injection.dart`
- Modify: `lib/core/di/injection_container.dart` (call `OrganizationInjection.init()`)

No dedicated tests for this task — matching this repo's existing convention: `match_repository_impl.dart` and its use cases (`get_my_teams.dart`, `get_team_profile.dart`, etc.) have no unit tests of their own; they're thin pass-throughs exercised transitively through controller tests (Tasks 5–6). Confirmed by absence of `test/features/scoring/data/repositories/match_repository_impl_test.dart` or any `test/features/scoring/domain/usecases/get_*_test.dart` anywhere in this repo.

- [ ] **Step 1: No test — see rationale above.**

- [ ] **Step 3: Write the implementation**

`lib/features/organization/domain/repositories/organization_repository.dart`:

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/request/add_organization_member_req.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_req.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_team_req.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';

abstract class OrganizationRepository {
  /// `POST /v1/organization` — caller becomes owner.
  Future<Either<CricketResponse<OrganizationDetailRes>, CricketFailure>>
  createOrganization({required CreateOrganizationReq? params});

  /// `GET /v1/organization` — every org the caller owns or belongs to.
  Future<Either<CricketResponse<MyOrganizationsRes>, CricketFailure>>
  getMyOrganizations();

  /// `GET /v1/organization/:orgId` — full member/team detail. Requires
  /// membership; `403 NOT_ORG_MEMBER` if the caller isn't in it.
  Future<Either<CricketResponse<OrganizationDetailRes>, CricketFailure>>
  getOrganization({required String orgId});

  /// `POST /v1/organization/:orgId/members` — owner-only, adds an existing
  /// account by exact email.
  Future<Either<CricketResponse<OrganizationMemberRes>, CricketFailure>>
  addMember({required String orgId, required AddOrganizationMemberReq? params});

  /// `DELETE /v1/organization/:orgId/members/:userId` — owner removes
  /// anyone but themselves, or a member removes themselves (leave).
  Future<Either<CricketResponse<void>, CricketFailure>> removeMember({
    required String orgId,
    required String userId,
  });

  /// `POST /v1/organization/:orgId/teams` — owner-only, creates a new team
  /// directly under the org.
  Future<Either<CricketResponse<OrganizationTeamRef>, CricketFailure>>
  createTeam({
    required String orgId,
    required CreateOrganizationTeamReq? params,
  });

  /// `DELETE /v1/organization/:orgId` — owner-only, soft-deletes; the org's
  /// teams orphan back to standalone server-side.
  Future<Either<CricketResponse<void>, CricketFailure>> deleteOrganization({
    required String orgId,
  });
}
```

`lib/features/organization/data/repositories/organization_repository_impl.dart`:

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/data_sources/remote/organization_api_service.dart';
import 'package:cricket_scorer/features/organization/data/models/request/add_organization_member_req.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_req.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_team_req.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final OrganizationApiService organizationApiService;

  OrganizationRepositoryImpl({required this.organizationApiService});

  @override
  Future<Either<CricketResponse<OrganizationDetailRes>, CricketFailure>>
  createOrganization({required CreateOrganizationReq? params}) async {
    final response = await organizationApiService.createOrganization(
      params: params,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: OrganizationDetailRes.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<MyOrganizationsRes>, CricketFailure>>
  getMyOrganizations() async {
    final response = await organizationApiService.getMyOrganizations();
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: MyOrganizationsRes.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<OrganizationDetailRes>, CricketFailure>>
  getOrganization({required String orgId}) async {
    final response = await organizationApiService.getOrganization(
      orgId: orgId,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: OrganizationDetailRes.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<OrganizationMemberRes>, CricketFailure>>
  addMember({
    required String orgId,
    required AddOrganizationMemberReq? params,
  }) async {
    final response = await organizationApiService.addMember(
      orgId: orgId,
      params: params,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: OrganizationMemberRes.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> removeMember({
    required String orgId,
    required String userId,
  }) async {
    final response = await organizationApiService.removeMember(
      orgId: orgId,
      userId: userId,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: null, message: response.result.message),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<OrganizationTeamRef>, CricketFailure>>
  createTeam({
    required String orgId,
    required CreateOrganizationTeamReq? params,
  }) async {
    final response = await organizationApiService.createTeam(
      orgId: orgId,
      params: params,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: OrganizationTeamRef.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> deleteOrganization({
    required String orgId,
  }) async {
    final response = await organizationApiService.deleteOrganization(
      orgId: orgId,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: null, message: response.result.message),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }
}
```

The seven use cases, one file each, all following `GetMyTeamsUseCase`'s exact shape:

`lib/features/organization/domain/usecases/create_organization.dart`:
```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_req.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';

class CreateOrganizationUseCase
    implements
        UseCase<
          Either<CricketResponse<OrganizationDetailRes>, CricketFailure>,
          CreateOrganizationReq
        > {
  final OrganizationRepository organizationRepository;

  CreateOrganizationUseCase({required this.organizationRepository});

  @override
  Future<Either<CricketResponse<OrganizationDetailRes>, CricketFailure>> call({
    CreateOrganizationReq? params,
  }) {
    return organizationRepository.createOrganization(params: params);
  }
}
```

`lib/features/organization/domain/usecases/get_my_organizations.dart`:
```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';

class GetMyOrganizationsUseCase
    implements
        UseCase<
          Either<CricketResponse<MyOrganizationsRes>, CricketFailure>,
          void
        > {
  final OrganizationRepository organizationRepository;

  GetMyOrganizationsUseCase({required this.organizationRepository});

  @override
  Future<Either<CricketResponse<MyOrganizationsRes>, CricketFailure>> call({
    void params,
  }) {
    return organizationRepository.getMyOrganizations();
  }
}
```

`lib/features/organization/domain/usecases/get_organization.dart`:
```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';

class GetOrganizationParams {
  final String orgId;

  GetOrganizationParams({required this.orgId});
}

class GetOrganizationUseCase
    implements
        UseCase<
          Either<CricketResponse<OrganizationDetailRes>, CricketFailure>,
          GetOrganizationParams
        > {
  final OrganizationRepository organizationRepository;

  GetOrganizationUseCase({required this.organizationRepository});

  @override
  Future<Either<CricketResponse<OrganizationDetailRes>, CricketFailure>> call({
    GetOrganizationParams? params,
  }) {
    return organizationRepository.getOrganization(orgId: params!.orgId);
  }
}
```

`lib/features/organization/domain/usecases/add_organization_member.dart`:
```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/request/add_organization_member_req.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';

class AddOrganizationMemberParams {
  final String orgId;
  final AddOrganizationMemberReq req;

  AddOrganizationMemberParams({required this.orgId, required this.req});
}

class AddOrganizationMemberUseCase
    implements
        UseCase<
          Either<CricketResponse<OrganizationMemberRes>, CricketFailure>,
          AddOrganizationMemberParams
        > {
  final OrganizationRepository organizationRepository;

  AddOrganizationMemberUseCase({required this.organizationRepository});

  @override
  Future<Either<CricketResponse<OrganizationMemberRes>, CricketFailure>> call({
    AddOrganizationMemberParams? params,
  }) {
    return organizationRepository.addMember(
      orgId: params!.orgId,
      params: params.req,
    );
  }
}
```

`lib/features/organization/domain/usecases/remove_organization_member.dart`:
```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';

class RemoveOrganizationMemberParams {
  final String orgId;
  final String userId;

  RemoveOrganizationMemberParams({required this.orgId, required this.userId});
}

class RemoveOrganizationMemberUseCase
    implements
        UseCase<Either<CricketResponse<void>, CricketFailure>,
            RemoveOrganizationMemberParams> {
  final OrganizationRepository organizationRepository;

  RemoveOrganizationMemberUseCase({required this.organizationRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    RemoveOrganizationMemberParams? params,
  }) {
    return organizationRepository.removeMember(
      orgId: params!.orgId,
      userId: params.userId,
    );
  }
}
```

`lib/features/organization/domain/usecases/create_organization_team.dart`:
```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_team_req.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';

class CreateOrganizationTeamParams {
  final String orgId;
  final CreateOrganizationTeamReq req;

  CreateOrganizationTeamParams({required this.orgId, required this.req});
}

class CreateOrganizationTeamUseCase
    implements
        UseCase<
          Either<CricketResponse<OrganizationTeamRef>, CricketFailure>,
          CreateOrganizationTeamParams
        > {
  final OrganizationRepository organizationRepository;

  CreateOrganizationTeamUseCase({required this.organizationRepository});

  @override
  Future<Either<CricketResponse<OrganizationTeamRef>, CricketFailure>> call({
    CreateOrganizationTeamParams? params,
  }) {
    return organizationRepository.createTeam(
      orgId: params!.orgId,
      params: params.req,
    );
  }
}
```

`lib/features/organization/domain/usecases/delete_organization.dart`:
```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';

class DeleteOrganizationParams {
  final String orgId;

  DeleteOrganizationParams({required this.orgId});
}

class DeleteOrganizationUseCase
    implements
        UseCase<Either<CricketResponse<void>, CricketFailure>,
            DeleteOrganizationParams> {
  final OrganizationRepository organizationRepository;

  DeleteOrganizationUseCase({required this.organizationRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    DeleteOrganizationParams? params,
  }) {
    return organizationRepository.deleteOrganization(orgId: params!.orgId);
  }
}
```

`updateTeamOrganization` on the **existing** `MatchRepository` (attach/detach lives on the team router server-side, so it stays on the team-domain repository client-side too, matching the endpoint's real owner). Add to `lib/features/scoring/domain/repositories/match_repository.dart`:

```dart
  /// `PATCH /v1/team/:teamId/organization` — attach an existing standalone
  /// team the caller owns to an org the caller owns, or detach (pass
  /// `organizationId: null`) back to standalone.
  Future<Either<CricketResponse<TeamSummary>, CricketFailure>>
  updateTeamOrganization({
    required String teamId,
    required String? organizationId,
  });
```

Add the import `import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';` to that file if not already present (it already is, for `MyTeamsRes`/`TeamSummary`).

Add to `lib/features/scoring/data/repositories/match_repository_impl.dart`:

```dart
  @override
  Future<Either<CricketResponse<TeamSummary>, CricketFailure>>
  updateTeamOrganization({
    required String teamId,
    required String? organizationId,
  }) async {
    final response = await matchApiService.updateTeamOrganization(
      teamId: teamId,
      organizationId: organizationId,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: TeamSummary.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }
```

Note: `PATCH /v1/team/:teamId/organization`'s response is `{id, organization}`, not a full `TeamSummary` (no `name`/`shortName`) — `TeamSummary.fromJson` on that payload would throw on the missing required `name` field. Use a small dedicated response instead. Create `lib/features/scoring/data/models/response/team_organization_res.dart`:

```dart
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart' show OrganizationRef;
import 'package:json_annotation/json_annotation.dart';

part 'team_organization_res.g.dart';

/// `PATCH /v1/team/:teamId/organization`'s response — deliberately smaller
/// than [TeamSummary]: attach/detach only ever needs to confirm the new
/// organization state, not re-send the team's name/shortName.
@JsonSerializable(explicitToJson: true)
class TeamOrganizationRes {
  final String id;
  final OrganizationRef? organization;

  TeamOrganizationRes({required this.id, this.organization});

  factory TeamOrganizationRes.fromJson(Map<String, dynamic> json) =>
      _$TeamOrganizationResFromJson(json);

  Map<String, dynamic> toJson() => _$TeamOrganizationResToJson(this);
}
```

Then use `TeamOrganizationRes` in place of `TeamSummary` in both the repository interface and impl above (replace every `TeamSummary` in this task's `updateTeamOrganization` signature/body with `TeamOrganizationRes`, and add its import).

Add to `lib/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart`:

```dart
  Future<Either<ApiResponseModel, CricketFailure>> updateTeamOrganization({
    required String teamId,
    required String? organizationId,
  }) async {
    return await apiClient.patch(
      endpoint: matchEndpoint.updateTeamOrganization(teamId),
      data: {'organizationId': organizationId},
    );
  }
```

`lib/features/scoring/domain/usecases/update_team_organization.dart`:
```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_organization_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class UpdateTeamOrganizationParams {
  final String teamId;
  final String? organizationId;

  UpdateTeamOrganizationParams({required this.teamId, this.organizationId});
}

class UpdateTeamOrganizationUseCase
    implements
        UseCase<
          Either<CricketResponse<TeamOrganizationRes>, CricketFailure>,
          UpdateTeamOrganizationParams
        > {
  final MatchRepository matchRepository;

  UpdateTeamOrganizationUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<TeamOrganizationRes>, CricketFailure>> call({
    UpdateTeamOrganizationParams? params,
  }) {
    return matchRepository.updateTeamOrganization(
      teamId: params!.teamId,
      organizationId: params.organizationId,
    );
  }
}
```

(This use case is included for completeness with the backend contract but has no UI call site in this plan — see Task 6's note on why attach/detach-an-existing-team is deliberately out of this plan's screen scope.)

`lib/core/di/injection/organization_injection.dart` (mirrors `ScoringInjection` exactly):

```dart
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/features/organization/data/data_sources/remote/organization_api_service.dart';
import 'package:cricket_scorer/features/organization/data/organization_endpoint.dart';
import 'package:cricket_scorer/features/organization/data/repositories/organization_repository_impl.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/add_organization_member.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization_team.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/delete_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_my_organizations.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/remove_organization_member.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team_organization.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:get/get.dart';

class OrganizationInjection {
  OrganizationInjection._();

  static void init() {
    const organizationEndpoint = OrganizationEndpoint();

    Get.lazyPut<OrganizationApiService>(
      () => OrganizationApiService(
        apiClient: Get.find<ApiClient>(),
        organizationEndpoint: organizationEndpoint,
      ),
      fenix: true,
    );

    Get.lazyPut<OrganizationRepository>(
      () => OrganizationRepositoryImpl(
        organizationApiService: Get.find<OrganizationApiService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<CreateOrganizationUseCase>(
      () => CreateOrganizationUseCase(
        organizationRepository: Get.find<OrganizationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetMyOrganizationsUseCase>(
      () => GetMyOrganizationsUseCase(
        organizationRepository: Get.find<OrganizationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetOrganizationUseCase>(
      () => GetOrganizationUseCase(
        organizationRepository: Get.find<OrganizationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<AddOrganizationMemberUseCase>(
      () => AddOrganizationMemberUseCase(
        organizationRepository: Get.find<OrganizationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<RemoveOrganizationMemberUseCase>(
      () => RemoveOrganizationMemberUseCase(
        organizationRepository: Get.find<OrganizationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<CreateOrganizationTeamUseCase>(
      () => CreateOrganizationTeamUseCase(
        organizationRepository: Get.find<OrganizationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<DeleteOrganizationUseCase>(
      () => DeleteOrganizationUseCase(
        organizationRepository: Get.find<OrganizationRepository>(),
      ),
      fenix: true,
    );

    // Lives on ScoringInjection's MatchRepository, not OrganizationRepository
    // — see this use case's own file comment. Registered here (not in
    // scoring_injection.dart) because it's conceptually an organization
    // action, and ScoringInjection.init() already runs before this file's
    // init() (see injection_container.dart), so MatchRepository exists by
    // the time this resolves it.
    Get.lazyPut<UpdateTeamOrganizationUseCase>(
      () => UpdateTeamOrganizationUseCase(
        matchRepository: Get.find<MatchRepository>(),
      ),
      fenix: true,
    );
  }
}
```

Modify `lib/core/di/injection_container.dart`:

```dart
import 'package:cricket_scorer/config/flavor_config.dart';
import 'package:cricket_scorer/core/di/injection/auth_injection.dart';
import 'package:cricket_scorer/core/di/injection/core_injection.dart';
import 'package:cricket_scorer/core/di/injection/global_injection.dart';
import 'package:cricket_scorer/core/di/injection/organization_injection.dart';
import 'package:cricket_scorer/core/di/injection/scoring_injection.dart';

class InjectionContainer {
  const InjectionContainer._();

  static Future<void> init({required FlavorConfig flavorConfig}) async {
    await CoreInjection.init(flavorConfig: flavorConfig);

    GlobalInjection.init();
    AuthInjection.init();
    ScoringInjection.init();
    OrganizationInjection.init();
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

No new test. Confirm the codebase compiles and every existing test is unaffected:
Run: `flutter analyze`
Expected: `No issues found!`
Run: `flutter test`
Expected: `All tests passed!`, same count as before this task (no test added or removed here).

- [ ] **Step 5: Commit**

```bash
git add lib/features/organization/domain lib/features/organization/data/repositories lib/features/scoring/domain/repositories/match_repository.dart lib/features/scoring/data/repositories/match_repository_impl.dart lib/features/scoring/domain/usecases/update_team_organization.dart lib/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart lib/features/scoring/data/models/response/team_organization_res.dart lib/features/scoring/data/models/response/team_organization_res.g.dart lib/core/di/injection/organization_injection.dart lib/core/di/injection_container.dart
git commit -m "feat: add OrganizationRepository, use cases, and DI wiring"
```

---

## Task 4: Routes

**Files:**
- Modify: `lib/config/routes/app_routes.dart`
- Modify: `lib/config/routes/app_pages.dart`

**Interfaces:**
- Produces: `AppRoutes.organizations`, `AppRoutes.organizationDetail` / `AppRoutes.organizationDetailPath(orgId)`.

- [ ] **Step 1: No test** — route string constants have no behavior of their own to test; the screens registered against them are exercised in Tasks 5–6.

- [ ] **Step 3: Write the implementation**

Add to `lib/config/routes/app_routes.dart`:

```dart
  static const String organizations = '/organizations';

  /// Registered with a GetX path parameter, same shape as [teamProfile].
  /// Never navigate with this constant directly — use
  /// [organizationDetailPath].
  static const String organizationDetail = '/organization/:orgId';

  static String organizationDetailPath(String orgId) =>
      '/organization/$orgId';
```

Add to `lib/config/routes/app_pages.dart` — the two new imports and two new `GetPage` entries (bindings created in Tasks 5–6, referenced here now; the file won't compile until those exist, which is fine since this task's own compile check happens after Task 6):

```dart
import 'package:cricket_scorer/features/organization/presentation/bindings/organization_detail_binding.dart';
import 'package:cricket_scorer/features/organization/presentation/bindings/organizations_list_binding.dart';
import 'package:cricket_scorer/features/organization/presentation/pages/organization_detail_screen.dart';
import 'package:cricket_scorer/features/organization/presentation/pages/organizations_list_screen.dart';
```

```dart
    GetPage(
      name: AppRoutes.organizations,
      page: () => const OrganizationsListScreen(),
      binding: OrganizationsListBinding(),
    ),
    GetPage(
      name: AppRoutes.organizationDetail,
      page: () => const OrganizationDetailScreen(),
      binding: OrganizationDetailBinding(),
    ),
```

- [ ] **Step 4: Run test to verify it passes**

This task's own compile check is deferred to the end of Task 6 (the imports above don't resolve until those files exist). Note that in the ledger and continue; do not run `flutter analyze` yet.

- [ ] **Step 5: Commit** — deferred; this task's changes are committed together with Task 6 (see Task 6's own Step 5), since `app_pages.dart` doesn't compile on its own until those screens/bindings exist.

---

## Task 5: `OrganizationsListScreen` (baseline — plain, functional)

**Files:**
- Create: `lib/features/organization/presentation/controllers/organizations_list_controller.dart`
- Create: `lib/features/organization/presentation/bindings/organizations_list_binding.dart`
- Create: `lib/features/organization/presentation/pages/organizations_list_screen.dart`
- Test: `test/features/organization/presentation/controllers/organizations_list_controller_test.dart`

**Interfaces:**
- Consumes: `GetMyOrganizationsUseCase`, `CreateOrganizationUseCase` (Task 3).
- Produces: `OrganizationsListController` (`organizations`, `isLoading`, `loadError`, `loadOrganizations()`, `createOrganization(name)`, `openOrganization(org)`).

- [ ] **Step 1: Write the failing test**

```dart
// test/features/organization/presentation/controllers/organizations_list_controller_test.dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_req.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_my_organizations.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organizations_list_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _FakeGetMyOrganizationsUseCase implements GetMyOrganizationsUseCase {
  Either<CricketResponse<MyOrganizationsRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<MyOrganizationsRes>, CricketFailure>> call({
    void params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeCreateOrganizationUseCase implements CreateOrganizationUseCase {
  Either<CricketResponse<OrganizationDetailRes>, CricketFailure>? response;
  CreateOrganizationReq? lastRequest;

  @override
  Future<Either<CricketResponse<OrganizationDetailRes>, CricketFailure>> call({
    CreateOrganizationReq? params,
  }) async {
    lastRequest = params;
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  late _FakeGetMyOrganizationsUseCase getMyOrganizationsUseCase;
  late _FakeCreateOrganizationUseCase createOrganizationUseCase;
  late OrganizationsListController controller;

  setUp(() {
    Get.testMode = true;
    getMyOrganizationsUseCase = _FakeGetMyOrganizationsUseCase();
    createOrganizationUseCase = _FakeCreateOrganizationUseCase();
    controller = OrganizationsListController(
      getMyOrganizationsUseCase: getMyOrganizationsUseCase,
      createOrganizationUseCase: createOrganizationUseCase,
    );
  });

  tearDown(Get.reset);

  test('loadOrganizations populates the list on success', () async {
    getMyOrganizationsUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: MyOrganizationsRes(
          organizations: [
            OrganizationSummaryRes(
              id: 'org-1',
              name: 'Riverside CC',
              myRole: 'owner',
              memberCount: 1,
              teamCount: 0,
            ),
          ],
        ),
      ),
    );

    await controller.loadOrganizations();

    expect(controller.organizations.length, 1);
    expect(controller.organizations.first.name, 'Riverside CC');
    expect(controller.isLoading.value, isFalse);
    expect(controller.loadError.value, isNull);
  });

  test('loadOrganizations sets loadError on failure', () async {
    getMyOrganizationsUseCase.response = Either.fallback(
      CricketServerErrorFailure(statusCode: 500, message: 'Server error'),
    );

    await controller.loadOrganizations();

    expect(controller.organizations, isEmpty);
    expect(controller.loadError.value, 'Server error');
  });

  test('createOrganization sends the typed name and prepends the result on success', () async {
    createOrganizationUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: OrganizationDetailRes(
          id: 'org-2',
          name: 'New Club',
          owner: OrganizationUserRef(id: 'user-1', name: 'Asha'),
          members: [
            OrganizationMemberRes(id: 'user-1', name: 'Asha', role: 'owner'),
          ],
          teams: const [],
        ),
      ),
    );

    final result = await controller.createOrganization('New Club');

    expect(result, isTrue);
    expect(createOrganizationUseCase.lastRequest?.name, 'New Club');
    expect(controller.organizations.first.name, 'New Club');
    expect(controller.organizations.first.myRole, 'owner');
  });

  test('createOrganization returns false and does not touch the list on failure', () async {
    createOrganizationUseCase.response = Either.fallback(
      CricketConflictFailure(statusCode: 409, message: 'Name taken'),
    );

    final result = await controller.createOrganization('Duplicate');

    expect(result, isFalse);
    expect(controller.organizations, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/organization/presentation/controllers/organizations_list_controller_test.dart`
Expected: FAIL — `organizations_list_controller.dart` doesn't exist.

- [ ] **Step 3: Write minimal implementation**

`lib/features/organization/presentation/controllers/organizations_list_controller.dart`:

```dart
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_req.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_my_organizations.dart';
import 'package:get/get.dart';

/// Every org the caller owns or belongs to, plus the ability to create a
/// new one. No pagination — an organization list is expected to stay small
/// (a scorer's own clubs), unlike match history or a team's past results.
class OrganizationsListController extends GetxController {
  final GetMyOrganizationsUseCase getMyOrganizationsUseCase;
  final CreateOrganizationUseCase createOrganizationUseCase;

  OrganizationsListController({
    required this.getMyOrganizationsUseCase,
    required this.createOrganizationUseCase,
  });

  final organizations = <OrganizationSummaryRes>[].obs;
  final isLoading = true.obs;
  final loadError = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadOrganizations();
  }

  Future<void> loadOrganizations() async {
    isLoading.value = true;
    loadError.value = null;

    final response = await getMyOrganizationsUseCase();

    isLoading.value = false;

    if (response.isResult) {
      organizations.assignAll(response.result.data?.organizations ?? []);
    } else {
      loadError.value = response.fallback.message;
    }
  }

  /// Returns whether creation succeeded — the screen uses this to decide
  /// whether to close the create-organization sheet or show its own error.
  Future<bool> createOrganization(String name) async {
    final response = await createOrganizationUseCase(
      params: CreateOrganizationReq(name: name),
    );

    if (!response.isResult) return false;

    final created = response.result.data;
    if (created != null) {
      organizations.insert(
        0,
        OrganizationSummaryRes(
          id: created.id,
          name: created.name,
          myRole: 'owner',
          memberCount: created.members.length,
          teamCount: created.teams.length,
        ),
      );
    }
    return true;
  }
}
```

`lib/features/organization/presentation/bindings/organizations_list_binding.dart`:

```dart
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_my_organizations.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organizations_list_controller.dart';
import 'package:get/get.dart';

class OrganizationsListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrganizationsListController>(
      () => OrganizationsListController(
        getMyOrganizationsUseCase: Get.find<GetMyOrganizationsUseCase>(),
        createOrganizationUseCase: Get.find<CreateOrganizationUseCase>(),
      ),
    );
  }
}
```

`lib/features/organization/presentation/pages/organizations_list_screen.dart` — deliberately plain, per this plan's Global Constraints (Task 8 does the design pass):

```dart
import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organizations_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrganizationsListScreen extends GetView<OrganizationsListController> {
  const OrganizationsListScreen({super.key});

  Future<void> _showCreateSheet(BuildContext context) async {
    final nameController = TextEditingController();
    final created = await CustomBottomSheet.wrapBottomSheet<bool>(
      headlineText: TranslationKeys.createOrganization.tr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CricketTextField(
            controller: nameController,
            hintText: TranslationKeys.organizationName.tr,
            labelText: TranslationKeys.organizationName.tr,
            isRequired: true,
          ),
          const SizedBox(height: 20),
          CricketButton(
            buttonText: TranslationKeys.create.tr,
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final success = await controller.createOrganization(name);
              if (success) {
                Get.back<bool>(result: true);
              } else {
                CricketSnackbar.showErrorMessage(
                  TranslationKeys.somethingWentWrong.tr,
                );
              }
            },
          ),
        ],
      ),
    );
    if (created == true) {
      CricketSnackbar.showSuccessMessage(TranslationKeys.organizationCreated.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.organizations.tr),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.organizations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final error = controller.loadError.value;
          if (error != null && controller.organizations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CricketText(text: error, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  CricketButton(
                    buttonText: TranslationKeys.retry.tr,
                    onPressed: controller.loadOrganizations,
                    width: 160,
                  ),
                ],
              ),
            );
          }

          if (controller.organizations.isEmpty) {
            return Center(child: CricketText(text: TranslationKeys.noOrganizationsYet.tr));
          }

          return RefreshIndicator(
            onRefresh: controller.loadOrganizations,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.organizations.length,
              itemBuilder: (context, index) {
                final org = controller.organizations[index];
                return _OrganizationRow(org: org);
              },
            ),
          );
        }),
      ),
    );
  }
}

class _OrganizationRow extends StatelessWidget {
  const _OrganizationRow({required this.org});

  final OrganizationSummaryRes org;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: CricketText(text: org.name),
      subtitle: CricketText(
        text: '${org.memberCount} members · ${org.teamCount} teams',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Get.toNamed<dynamic>(
        AppRoutes.organizationDetailPath(org.id),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/organization/presentation/controllers/organizations_list_controller_test.dart`
Expected: PASS, 4 tests.

- [ ] **Step 5: Commit** — deferred to Task 6 (see that task's Step 5); `app_pages.dart` from Task 4 doesn't compile until `OrganizationDetailScreen`/`OrganizationDetailBinding` also exist.

---

## Task 6: `OrganizationDetailScreen` (baseline — plain, functional)

**Files:**
- Create: `lib/features/organization/presentation/controllers/organization_detail_controller.dart`
- Create: `lib/features/organization/presentation/bindings/organization_detail_binding.dart`
- Create: `lib/features/organization/presentation/pages/organization_detail_screen.dart`
- Test: `test/features/organization/presentation/controllers/organization_detail_controller_test.dart`

**Interfaces:**
- Consumes: `GetOrganizationUseCase`, `AddOrganizationMemberUseCase`, `RemoveOrganizationMemberUseCase`, `CreateOrganizationTeamUseCase`, `DeleteOrganizationUseCase` (Task 3).
- Produces: `OrganizationDetailController` (`orgId`, `detail`, `isLoading`, `loadError`, `loadDetail()`, `addMember(email)`, `removeMember(userId)`, `createTeam(name, shortName)`, `deleteOrganization()`, `isOwner` getter, `currentUserId` — needed to render "leave" vs "remove" per member row and to gate owner-only actions client-side (the server is still the real authority; this only avoids showing a button that would 403)).

**Design note — deliberately out of scope for this screen:** attaching an *existing* standalone team to an org (`PATCH /v1/team/:teamId/organization` with a non-null id) has no UI here. The user's brief asked for "add teams," which this screen covers via `POST /organization/:orgId/teams` (create a new team under the org) — attaching an already-scored standalone team is a materially different flow (needs a team picker across every team the caller owns) and isn't part of the explicit ask. `UpdateTeamOrganizationUseCase` (Task 3) exists and is reachable via curl; wiring a picker UI to it is a natural fast-follow, not this plan's job.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/organization/presentation/controllers/organization_detail_controller_test.dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/request/add_organization_member_req.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_team_req.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/add_organization_member.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization_team.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/delete_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/remove_organization_member.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organization_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

OrganizationDetailRes _detail({String myUserId = 'user-1'}) => OrganizationDetailRes(
  id: 'org-1',
  name: 'Riverside CC',
  owner: OrganizationUserRef(id: 'user-1', name: 'Asha'),
  members: [
    OrganizationMemberRes(id: 'user-1', name: 'Asha', role: 'owner'),
    OrganizationMemberRes(id: 'user-2', name: 'Vikram', role: 'member'),
  ],
  teams: const [],
);

class _FakeGetOrganizationUseCase implements GetOrganizationUseCase {
  Either<CricketResponse<OrganizationDetailRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<OrganizationDetailRes>, CricketFailure>> call({
    GetOrganizationParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeAddOrganizationMemberUseCase implements AddOrganizationMemberUseCase {
  Either<CricketResponse<OrganizationMemberRes>, CricketFailure>? response;
  AddOrganizationMemberParams? lastParams;

  @override
  Future<Either<CricketResponse<OrganizationMemberRes>, CricketFailure>> call({
    AddOrganizationMemberParams? params,
  }) async {
    lastParams = params;
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeRemoveOrganizationMemberUseCase implements RemoveOrganizationMemberUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    RemoveOrganizationMemberParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeCreateOrganizationTeamUseCase implements CreateOrganizationTeamUseCase {
  Either<CricketResponse<OrganizationTeamRef>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<OrganizationTeamRef>, CricketFailure>> call({
    CreateOrganizationTeamParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeDeleteOrganizationUseCase implements DeleteOrganizationUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    DeleteOrganizationParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  late _FakeGetOrganizationUseCase getOrganizationUseCase;
  late _FakeAddOrganizationMemberUseCase addMemberUseCase;
  late _FakeRemoveOrganizationMemberUseCase removeMemberUseCase;
  late _FakeCreateOrganizationTeamUseCase createTeamUseCase;
  late _FakeDeleteOrganizationUseCase deleteOrganizationUseCase;
  late OrganizationDetailController controller;

  setUp(() {
    Get.testMode = true;
    getOrganizationUseCase = _FakeGetOrganizationUseCase();
    addMemberUseCase = _FakeAddOrganizationMemberUseCase();
    removeMemberUseCase = _FakeRemoveOrganizationMemberUseCase();
    createTeamUseCase = _FakeCreateOrganizationTeamUseCase();
    deleteOrganizationUseCase = _FakeDeleteOrganizationUseCase();
    controller = OrganizationDetailController(
      orgId: 'org-1',
      currentUserId: 'user-1',
      getOrganizationUseCase: getOrganizationUseCase,
      addOrganizationMemberUseCase: addMemberUseCase,
      removeOrganizationMemberUseCase: removeMemberUseCase,
      createOrganizationTeamUseCase: createTeamUseCase,
      deleteOrganizationUseCase: deleteOrganizationUseCase,
    );
  });

  tearDown(Get.reset);

  test('loadDetail populates detail and isOwner is true for the owner', () async {
    getOrganizationUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _detail()),
    );

    await controller.loadDetail();

    expect(controller.detail.value?.name, 'Riverside CC');
    expect(controller.isOwner, isTrue);
  });

  test('isOwner is false for a member viewer', () {
    controller = OrganizationDetailController(
      orgId: 'org-1',
      currentUserId: 'user-2',
      getOrganizationUseCase: getOrganizationUseCase,
      addOrganizationMemberUseCase: addMemberUseCase,
      removeOrganizationMemberUseCase: removeMemberUseCase,
      createOrganizationTeamUseCase: createTeamUseCase,
      deleteOrganizationUseCase: deleteOrganizationUseCase,
    );
    controller.detail.value = _detail();

    expect(controller.isOwner, isFalse);
  });

  test('addMember sends the typed email and refreshes on success', () async {
    getOrganizationUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _detail()),
    );
    await controller.loadDetail();

    addMemberUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: OrganizationMemberRes(id: 'user-3', name: 'Raj', role: 'member'),
      ),
    );
    getOrganizationUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: OrganizationDetailRes(
          id: 'org-1',
          name: 'Riverside CC',
          owner: OrganizationUserRef(id: 'user-1', name: 'Asha'),
          members: [
            OrganizationMemberRes(id: 'user-1', name: 'Asha', role: 'owner'),
            OrganizationMemberRes(id: 'user-2', name: 'Vikram', role: 'member'),
            OrganizationMemberRes(id: 'user-3', name: 'Raj', role: 'member'),
          ],
          teams: const [],
        ),
      ),
    );

    final result = await controller.addMember('raj@example.com');

    expect(result, isTrue);
    expect(addMemberUseCase.lastParams?.orgId, 'org-1');
    expect(addMemberUseCase.lastParams?.req.email, 'raj@example.com');
    expect(controller.detail.value?.members.length, 3);
  });

  test('addMember returns false on failure without refreshing', () async {
    addMemberUseCase.response = Either.fallback(
      CricketNotFoundErrorFailure(statusCode: 404, message: 'User not found'),
    );

    final result = await controller.addMember('nobody@example.com');

    expect(result, isFalse);
  });

  test('createTeam sends name and shortName', () async {
    createTeamUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: OrganizationTeamRef(id: 'team-1', name: 'Riverside U19', shortName: 'RU19'),
      ),
    );
    getOrganizationUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _detail()),
    );

    final result = await controller.createTeam('Riverside U19', 'RU19');

    expect(result, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/organization/presentation/controllers/organization_detail_controller_test.dart`
Expected: FAIL — `organization_detail_controller.dart` doesn't exist.

- [ ] **Step 3: Write minimal implementation**

`lib/features/organization/presentation/controllers/organization_detail_controller.dart`:

```dart
import 'package:cricket_scorer/features/organization/data/models/request/add_organization_member_req.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_team_req.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/add_organization_member.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization_team.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/delete_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/remove_organization_member.dart';
import 'package:get/get.dart';

class OrganizationDetailController extends GetxController {
  final String orgId;

  /// The signed-in scorer's own id — compared against `detail.owner.id` for
  /// [isOwner] and against each member row to decide "leave" vs "remove".
  /// Client-side only, to decide which buttons to show; the server remains
  /// the real authority on every action (see docs/api.md).
  final String currentUserId;

  final GetOrganizationUseCase getOrganizationUseCase;
  final AddOrganizationMemberUseCase addOrganizationMemberUseCase;
  final RemoveOrganizationMemberUseCase removeOrganizationMemberUseCase;
  final CreateOrganizationTeamUseCase createOrganizationTeamUseCase;
  final DeleteOrganizationUseCase deleteOrganizationUseCase;

  OrganizationDetailController({
    required this.orgId,
    required this.currentUserId,
    required this.getOrganizationUseCase,
    required this.addOrganizationMemberUseCase,
    required this.removeOrganizationMemberUseCase,
    required this.createOrganizationTeamUseCase,
    required this.deleteOrganizationUseCase,
  });

  final detail = Rxn<OrganizationDetailRes>();
  final isLoading = true.obs;
  final loadError = Rxn<String>();

  bool get isOwner => detail.value?.owner.id == currentUserId;

  @override
  void onInit() {
    super.onInit();
    loadDetail();
  }

  Future<void> loadDetail() async {
    isLoading.value = true;
    loadError.value = null;

    final response = await getOrganizationUseCase(
      params: GetOrganizationParams(orgId: orgId),
    );

    isLoading.value = false;

    if (response.isResult) {
      detail.value = response.result.data;
    } else {
      loadError.value = response.fallback.message;
    }
  }

  Future<bool> addMember(String email) async {
    final response = await addOrganizationMemberUseCase(
      params: AddOrganizationMemberParams(
        orgId: orgId,
        req: AddOrganizationMemberReq(email: email),
      ),
    );

    if (!response.isResult) return false;
    await loadDetail();
    return true;
  }

  Future<bool> removeMember(String userId) async {
    final response = await removeOrganizationMemberUseCase(
      params: RemoveOrganizationMemberParams(orgId: orgId, userId: userId),
    );

    if (!response.isResult) return false;
    await loadDetail();
    return true;
  }

  Future<bool> createTeam(String name, String? shortName) async {
    final response = await createOrganizationTeamUseCase(
      params: CreateOrganizationTeamParams(
        orgId: orgId,
        req: CreateOrganizationTeamReq(name: name, shortName: shortName),
      ),
    );

    if (!response.isResult) return false;
    await loadDetail();
    return true;
  }

  Future<bool> deleteOrganization() async {
    final response = await deleteOrganizationUseCase(
      params: DeleteOrganizationParams(orgId: orgId),
    );
    return response.isResult;
  }
}
```

`lib/features/organization/presentation/bindings/organization_detail_binding.dart` — needs the signed-in user's id, read from cache exactly the way `language_service.dart` already does (decode the `userDetails` `SharedPreferenceService` entry, written by `login_controller.dart` on login, via `User.fromJson` — `User.id` and the stored `LoggedInUser`'s id both map from the JSON key `_id`, so this cross-decode already works today for `language_service.dart`'s own read of the same key). `get()` is synchronous (`dynamic get(String key)`, not a `Future`), which is exactly what a `Bindings.dependencies()` override needs — it cannot `await` a network call before returning:

```dart
import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:cricket_scorer/features/auth/data/models/user.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/add_organization_member.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization_team.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/delete_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/remove_organization_member.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organization_detail_controller.dart';
import 'package:get/get.dart';
import 'dart:convert';

// Same cache read language_service.dart's own sync already relies on: the
// stored value is a LoggedInUser's JSON (written by login_controller.dart),
// decoded here via User.fromJson — both map their id from the same `_id`
// JSON key, so the cross-decode is exactly what that existing call site
// already depends on working.
String _currentUserId() {
  final userJson =
      SharedPreferenceService.sharedPrefService.get(SharedPrefKey.userDetails)
          as String?;
  if (userJson == null) return '';
  final user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  return user.id ?? '';
}

class OrganizationDetailBinding extends Bindings {
  @override
  void dependencies() {
    final orgId = Get.parameters['orgId']?.trim() ?? '';
    Get.lazyPut<OrganizationDetailController>(
      () => OrganizationDetailController(
        orgId: orgId,
        currentUserId: _currentUserId(),
        getOrganizationUseCase: Get.find<GetOrganizationUseCase>(),
        addOrganizationMemberUseCase: Get.find<AddOrganizationMemberUseCase>(),
        removeOrganizationMemberUseCase:
            Get.find<RemoveOrganizationMemberUseCase>(),
        createOrganizationTeamUseCase:
            Get.find<CreateOrganizationTeamUseCase>(),
        deleteOrganizationUseCase: Get.find<DeleteOrganizationUseCase>(),
      ),
      tag: orgId,
    );
  }
}
```

`lib/features/organization/presentation/pages/organization_detail_screen.dart` — plain, per Global Constraints:

```dart
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organization_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrganizationDetailScreen extends StatefulWidget {
  const OrganizationDetailScreen({super.key});

  @override
  State<OrganizationDetailScreen> createState() =>
      _OrganizationDetailScreenState();
}

class _OrganizationDetailScreenState extends State<OrganizationDetailScreen> {
  late final String _orgId = Get.parameters['orgId']?.trim() ?? '';
  late final OrganizationDetailController controller =
      Get.find<OrganizationDetailController>(tag: _orgId);

  Future<void> _showAddMemberSheet() async {
    final emailController = TextEditingController();
    final added = await CustomBottomSheet.wrapBottomSheet<bool>(
      headlineText: TranslationKeys.addMember.tr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CricketTextField(
            controller: emailController,
            hintText: TranslationKeys.memberEmail.tr,
            labelText: TranslationKeys.memberEmail.tr,
            keyboardType: TextInputType.emailAddress,
            isRequired: true,
          ),
          const SizedBox(height: 20),
          CricketButton(
            buttonText: TranslationKeys.add.tr,
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;
              final success = await controller.addMember(email);
              if (success) {
                Get.back<bool>(result: true);
              } else {
                CricketSnackbar.showErrorMessage(
                  TranslationKeys.somethingWentWrong.tr,
                );
              }
            },
          ),
        ],
      ),
    );
    if (added == true) {
      CricketSnackbar.showSuccessMessage(TranslationKeys.memberAdded.tr);
    }
  }

  Future<void> _showAddTeamSheet() async {
    final nameController = TextEditingController();
    final shortNameController = TextEditingController();
    final added = await CustomBottomSheet.wrapBottomSheet<bool>(
      headlineText: TranslationKeys.addTeam.tr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CricketTextField(
            controller: nameController,
            hintText: TranslationKeys.teamName.tr,
            labelText: TranslationKeys.teamName.tr,
            isRequired: true,
          ),
          const SizedBox(height: 12),
          CricketTextField(
            controller: shortNameController,
            hintText: TranslationKeys.teamShortName.tr,
            labelText: TranslationKeys.teamShortName.tr,
          ),
          const SizedBox(height: 20),
          CricketButton(
            buttonText: TranslationKeys.add.tr,
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final shortName = shortNameController.text.trim();
              final success = await controller.createTeam(
                name,
                shortName.isEmpty ? null : shortName,
              );
              if (success) {
                Get.back<bool>(result: true);
              } else {
                CricketSnackbar.showErrorMessage(
                  TranslationKeys.somethingWentWrong.tr,
                );
              }
            },
          ),
        ],
      ),
    );
    if (added == true) {
      CricketSnackbar.showSuccessMessage(TranslationKeys.teamAdded.tr);
    }
  }

  Future<void> _confirmRemoveMember(OrganizationMemberRes member, bool isSelf) async {
    final confirmed = await CustomBottomSheet.warningBottomSheet<bool>(
      title: isSelf
          ? TranslationKeys.leaveOrganizationConfirmTitle.tr
          : TranslationKeys.removeMemberConfirmTitle.tr,
      message: isSelf
          ? TranslationKeys.leaveOrganizationConfirmMessage.tr
          : TranslationKeys.removeMemberConfirmMessage.tr,
      confirmButtonName: isSelf
          ? TranslationKeys.leaveOrganization.tr
          : TranslationKeys.removeMember.tr,
    );
    if (confirmed != true) return;

    final success = await controller.removeMember(member.id);
    if (!success) {
      CricketSnackbar.showErrorMessage(TranslationKeys.somethingWentWrong.tr);
    }
  }

  Future<void> _confirmDeleteOrganization() async {
    final confirmed = await CustomBottomSheet.warningBottomSheet<bool>(
      title: TranslationKeys.deleteOrganizationConfirmTitle.tr,
      message: TranslationKeys.deleteOrganizationConfirmMessage.tr,
      confirmButtonName: TranslationKeys.deleteOrganization.tr,
    );
    if (confirmed != true) return;

    final success = await controller.deleteOrganization();
    if (success) {
      Get.back<dynamic>();
    } else {
      CricketSnackbar.showErrorMessage(TranslationKeys.somethingWentWrong.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: TranslationKeys.organizationDetail.tr,
        actions: [
          Obx(() {
            if (!controller.isOwner) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDeleteOrganization,
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final loading = controller.isLoading.value;
          final error = controller.loadError.value;
          final detail = controller.detail.value;

          if (loading && detail == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null && detail == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CricketText(text: error, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  CricketButton(
                    buttonText: TranslationKeys.retry.tr,
                    onPressed: controller.loadDetail,
                    width: 160,
                  ),
                ],
              ),
            );
          }
          if (detail == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: controller.loadDetail,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CricketText(
                  text: detail.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CricketText(
                      text: TranslationKeys.members.tr,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (controller.isOwner)
                      TextButton(
                        onPressed: _showAddMemberSheet,
                        child: CricketText(text: TranslationKeys.addMember.tr),
                      ),
                  ],
                ),
                for (final member in detail.members)
                  ListTile(
                    title: CricketText(text: member.name),
                    subtitle: CricketText(text: member.role),
                    trailing: (controller.isOwner && member.id != controller.currentUserId) ||
                            member.id == controller.currentUserId
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: member.role == 'owner'
                                ? null
                                : () => _confirmRemoveMember(
                                      member,
                                      member.id == controller.currentUserId,
                                    ),
                          )
                        : null,
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CricketText(
                      text: TranslationKeys.teams.tr,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (controller.isOwner)
                      TextButton(
                        onPressed: _showAddTeamSheet,
                        child: CricketText(text: TranslationKeys.addTeam.tr),
                      ),
                  ],
                ),
                if (detail.teams.isEmpty)
                  CricketText(text: TranslationKeys.noTeamsYet.tr)
                else
                  for (final team in detail.teams)
                    ListTile(
                      title: CricketText(text: team.name),
                      subtitle: team.shortName != null
                          ? CricketText(text: team.shortName!)
                          : null,
                    ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/organization/presentation/controllers/organization_detail_controller_test.dart`
Expected: PASS, 5 tests.

Now that both screens/bindings from Tasks 5 and 6 exist, confirm the whole app compiles (this is also Task 4's own deferred verification):
Run: `flutter analyze`
Expected: `No issues found!`
Run: `flutter test`
Expected: `All tests passed!`

- [ ] **Step 5: Commit** (Tasks 4, 5, and 6 together — the routes file from Task 4 only compiles once these screens exist)

```bash
git add lib/config/routes/app_routes.dart lib/config/routes/app_pages.dart lib/features/organization/presentation test/features/organization/presentation
git commit -m "feat: add organizations list and detail screens, plain baseline"
```

---

## Task 7: Home screen entry point

**Files:**
- Modify: `lib/features/home/presentation/pages/home_page.dart`

**Interfaces:** none — this task only adds a navigation trigger to an existing screen.

- [ ] **Step 1: No test** — a single `IconButton`'s `onPressed` navigating to an already-tested route has no independent logic to unit-test; this is covered by Task 9's on-device verification instead, matching how the existing `IconButton`s in this same app bar (profile, logout, language) have no dedicated tests either.

- [ ] **Step 3: Write the implementation**

Add one more `IconButton` to `HomePage`'s `CustomAppBar.actions`, alongside the existing three:

```dart
          IconButton(
            icon: const Icon(Icons.groups_outlined),
            onPressed: () => Get.toNamed<dynamic>(AppRoutes.organizations),
          ),
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/presentation/pages/home_page.dart
git commit -m "feat: add Organizations entry point to the Home app bar"
```

---

## Task 8: Frontend design pass (REQUIRED — do not skip)

**Files:**
- Modify: `lib/features/organization/presentation/pages/organizations_list_screen.dart`
- Modify: `lib/features/organization/presentation/pages/organization_detail_screen.dart`
- Possibly create: `lib/features/organization/presentation/widget/*.dart` for any extracted shared row/card widgets, following `match_history_card.dart`'s precedent of extracting a reusable card once a shape repeats.

**Process:**

- [ ] **Step 1: Invoke `frontend-design`**, briefing it with:
  - The two screens built in Tasks 5–6 (plain `ListTile`/`ListView` baseline, functionally complete).
  - The existing visual language to match: `team_profile_screen.dart`'s `_TeamHeader` (monogram avatar + name, `CircleAvatar` with `context.colors.chipBackground`), its `_RosterRow` (role pill using `context.colors.statusInfo`/`statusWarning`/`statusSuccess`), `match_history_card.dart` (the shared card widget for list rows), `home_page.dart`'s match-history list layout, and `create_match_screen.dart`'s `_TeamChipRow` (`FilterChip` pattern).
  - The explicit ask: these two screens should read as belonging to the same app as team-profile and match history, not a bolted-on generic Material page — same reasoning the team-profile screen's own review already established once for this codebase.
  - Specific elements needing real design attention: the organization row on the list screen (currently a bare `ListTile`), the member/team rows on the detail screen (bare `ListTile`s with no visual distinction between an owner and a member, no monogram/avatar treatment matching `_TeamHeader`'s), and the create/add-member/add-team bottom sheets (currently just a text field + button stacked with no visual hierarchy).
- [ ] **Step 2: Apply the resulting design** to both screens (and any extracted widgets) directly — this is real code, not a separate artifact.
- [ ] **Step 3: Re-run the full test suite** to confirm the design pass didn't change controller behavior (widget restructuring should never touch controller logic):
  Run: `flutter test`
  Expected: `All tests passed!`, same count as after Task 7.
- [ ] **Step 4: Run analyze**:
  Run: `flutter analyze`
  Expected: `No issues found!`
- [ ] **Step 5: Commit**

```bash
git add lib/features/organization/presentation
git commit -m "style: apply design pass to organization screens"
```

---

## Task 9: Translation keys

**Files:**
- Modify: `lib/core/translations/translation_keys.dart`
- Create/update (outside this repo's version control at run time — see below): a CMS bulk-update payload.

- [ ] **Step 1: No test** — `TranslationKeys` is a class of `static const String` key constants; there is no behavior to test, only presence, and every call site in Tasks 5–8 already fails to compile if a key referenced there is missing (which is the actual test — `flutter analyze` in Task 8's Step 4 already proves every key used exists).

- [ ] **Step 3: Write the implementation**

Add to `lib/core/translations/translation_keys.dart`, in a new section after "Team profile":

```dart
  // Organizations
  static const String organizations = 'organizations';
  static const String organizationDetail = 'organization_detail';
  static const String createOrganization = 'create_organization';
  static const String organizationName = 'organization_name';
  static const String organizationCreated = 'organization_created';
  static const String noOrganizationsYet = 'no_organizations_yet';
  static const String members = 'members';
  static const String addMember = 'add_member';
  static const String memberEmail = 'member_email';
  static const String memberAdded = 'member_added';
  static const String teams = 'teams';
  static const String addTeam = 'add_team';
  static const String teamName = 'team_name';
  static const String teamShortName = 'team_short_name';
  static const String teamAdded = 'team_added';
  static const String noTeamsYet = 'no_teams_yet';
  static const String add = 'add';
  static const String leaveOrganization = 'leave_organization';
  static const String leaveOrganizationConfirmTitle =
      'leave_organization_confirm_title';
  static const String leaveOrganizationConfirmMessage =
      'leave_organization_confirm_message';
  static const String removeMember = 'remove_member';
  static const String removeMemberConfirmTitle = 'remove_member_confirm_title';
  static const String removeMemberConfirmMessage =
      'remove_member_confirm_message';
  static const String deleteOrganization = 'delete_organization';
  static const String deleteOrganizationConfirmTitle =
      'delete_organization_confirm_title';
  static const String deleteOrganizationConfirmMessage =
      'delete_organization_confirm_message';
```

Check first whether `create`, `retry`, `cancel`, `somethingWentWrong` already exist as keys (they're used throughout the rest of this plan) — they almost certainly do, given how many other screens already use them; do not redeclare a key that already exists elsewhere in this file.

Then produce the CMS payload (this is a manual step against a running backend, not something `flutter test` verifies) — a JSON array in the same shape `docs/translations-bulk-update.json` (workspace root, from an earlier feature) used:

```json
[
  { "key": "organizations", "translations": { "en": "Organizations", "hi": "संगठन", "mr": "संस्था" } },
  { "key": "organization_detail", "translations": { "en": "Organization", "hi": "संगठन", "mr": "संस्था" } },
  { "key": "create_organization", "translations": { "en": "Create organization", "hi": "संगठन बनाएं", "mr": "संस्था तयार करा" } },
  { "key": "organization_name", "translations": { "en": "Organization name", "hi": "संगठन का नाम", "mr": "संस्थेचे नाव" } },
  { "key": "organization_created", "translations": { "en": "Organization created", "hi": "संगठन बनाया गया", "mr": "संस्था तयार झाली" } },
  { "key": "no_organizations_yet", "translations": { "en": "No organizations yet", "hi": "अभी तक कोई संगठन नहीं", "mr": "अद्याप कोणतीही संस्था नाही" } },
  { "key": "members", "translations": { "en": "Members", "hi": "सदस्य", "mr": "सदस्य" } },
  { "key": "add_member", "translations": { "en": "Add member", "hi": "सदस्य जोड़ें", "mr": "सदस्य जोडा" } },
  { "key": "member_email", "translations": { "en": "Member's email", "hi": "सदस्य का ईमेल", "mr": "सदस्याचा ईमेल" } },
  { "key": "member_added", "translations": { "en": "Member added", "hi": "सदस्य जोड़ा गया", "mr": "सदस्य जोडला गेला" } },
  { "key": "teams", "translations": { "en": "Teams", "hi": "टीमें", "mr": "टीम्स" } },
  { "key": "add_team", "translations": { "en": "Add team", "hi": "टीम जोड़ें", "mr": "टीम जोडा" } },
  { "key": "team_name", "translations": { "en": "Team name", "hi": "टीम का नाम", "mr": "टीमचे नाव" } },
  { "key": "team_short_name", "translations": { "en": "Short name", "hi": "संक्षिप्त नाम", "mr": "संक्षिप्त नाव" } },
  { "key": "team_added", "translations": { "en": "Team added", "hi": "टीम जोड़ी गई", "mr": "टीम जोडली गेली" } },
  { "key": "no_teams_yet", "translations": { "en": "No teams yet", "hi": "अभी तक कोई टीम नहीं", "mr": "अद्याप कोणतीही टीम नाही" } },
  { "key": "add", "translations": { "en": "Add", "hi": "जोड़ें", "mr": "जोडा" } },
  { "key": "leave_organization", "translations": { "en": "Leave", "hi": "छोड़ें", "mr": "सोडा" } },
  { "key": "leave_organization_confirm_title", "translations": { "en": "Leave this organization?", "hi": "क्या इस संगठन को छोड़ना है?", "mr": "ही संस्था सोडायची का?" } },
  { "key": "leave_organization_confirm_message", "translations": { "en": "You'll lose access to its teams unless you're added back.", "hi": "जब तक आपको दोबारा नहीं जोड़ा जाता, आप इसकी टीमों तक पहुंच खो देंगे।", "mr": "तुम्हाला परत जोडल्याशिवाय त्याच्या टीम्सचा प्रवेश मिळणार नाही." } },
  { "key": "remove_member", "translations": { "en": "Remove", "hi": "हटाएं", "mr": "काढा" } },
  { "key": "remove_member_confirm_title", "translations": { "en": "Remove this member?", "hi": "क्या इस सदस्य को हटाना है?", "mr": "हा सदस्य काढायचा का?" } },
  { "key": "remove_member_confirm_message", "translations": { "en": "They'll lose access to this organization's teams.", "hi": "वे इस संगठन की टीमों तक पहुंच खो देंगे।", "mr": "त्यांना या संस्थेच्या टीम्सचा प्रवेश मिळणार नाही." } },
  { "key": "delete_organization", "translations": { "en": "Delete organization", "hi": "संगठन हटाएं", "mr": "संस्था हटवा" } },
  { "key": "delete_organization_confirm_title", "translations": { "en": "Delete this organization?", "hi": "क्या इस संगठन को हटाना है?", "mr": "ही संस्था हटवायची का?" } },
  { "key": "delete_organization_confirm_message", "translations": { "en": "Its teams will become standalone again. This can't be undone.", "hi": "इसकी टीमें फिर से स्वतंत्र हो जाएंगी। यह पूर्ववत नहीं किया जा सकता।", "mr": "त्याच्या टीम्स पुन्हा स्वतंत्र होतील. हे पूर्ववत करता येणार नाही." } }
]
```

Upload with (matching this repo's own documented convention):

```bash
curl -s -X POST http://localhost:9000/api/v1/translations/bulk-update \
  -H "Authorization: Bearer $ACCESS_TOKEN" -H "Content-Type: application/json" \
  -d @organizations-translations.json
```

- [ ] **Step 4: Verify**

Run: `flutter analyze`
Expected: `No issues found!` (proves every `TranslationKeys.x` referenced across Tasks 5–8 resolves to a real constant).

On-device (Task 10), after the CMS upload above, confirm the new screens render real copy, not raw keys like `organizations` or `no_teams_yet` — that would mean the CMS step was skipped or the key names drifted from what's in `translation_keys.dart`.

- [ ] **Step 5: Commit**

```bash
git add lib/core/translations/translation_keys.dart
git commit -m "feat: add organization translation keys"
```

---

## Task 10: On-device verification (superpowers:verification-before-completion)

Not a code task — this is the gate before calling Phase 3 done. Run on a real device or the iOS Simulator, against a locally running backend with the Task 9 CMS upload already applied.

- [ ] Launch the app fresh. Confirm the new groups icon appears in the Home app bar.
- [ ] Tap it → Organizations list loads (empty state renders real copy, not a raw key).
- [ ] Tap the FAB → create-organization sheet opens, type a name, submit → sheet closes, success snackbar shows real copy, new org appears at the top of the list.
- [ ] Tap into the new org → detail screen loads: name, an "Add member" action (owner), an "Add team" action (owner), empty members-other-than-self and empty-teams states render real copy.
- [ ] Add a team (name + short name) → appears in the teams list.
- [ ] Add a member by email (an existing second test account) → appears in the members list with role "member".
- [ ] Log in as that second account → Organizations list shows the org (role "member", no delete icon in its detail screen, no "Add member"/"Add team" actions visible).
- [ ] From that second account, create a match: pick the org's team via the existing "reuse an existing team" chip picker on `CreateMatchScreen` — confirm it appears there (this requires `GetMyTeamsUseCase`'s response to include it, which Task 1/3 already wire up automatically since `GET /v1/team` already returns org teams for members — no `CreateMatchController` change was needed or made in this plan).
- [ ] As the second account, open that team's profile (via match history) — confirm it loads (proving `findOwnedTeam`'s widened access works end-to-end from the UI, not just the API).
- [ ] Back on the owner account, remove the second account from the org — confirm it disappears from the member list, and re-check `GET /v1/team` (via the picker) no longer includes that team for the removed account.
- [ ] **The ad-hoc guarantee, explicitly**: with no organization involved at all, create a brand-new match by typing two fresh team names (the exact flow that existed before this feature). Confirm: the flow looks and behaves identically to before — same screen, same fields, same confirmation, no new prompts, no new fields, no organization-related UI appears anywhere in this path. This is the one check this plan cannot skip or approximate — it's the whole point of Global Constraint #1.
- [ ] Report the outcome of every checkbox above with actual observation (a screenshot or a described on-screen result), not an assumption that it "should work" — per `superpowers:verification-before-completion`.
