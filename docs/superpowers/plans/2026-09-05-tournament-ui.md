# Tournament Management UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Flutter/GetX frontend for the Tournament CRUD + team-enrollment backend (`cricket-scorer-backend`, already merged to `development`): an org owner can create/rename/change format/change status/delete a tournament and enroll/remove teams from it; any org member can view it.

**Architecture:** New `lib/features/tournament/` feature folder mirroring `lib/features/organization/`'s clean-architecture layering exactly (data/domain/presentation). Tournaments are reached from a new section on the existing `OrganizationDetailScreen` (mirroring its "Teams" section), landing on a new `TournamentDetailScreen` reached via a GetX path-parameter route, mirroring `TeamProfileScreen`'s own routing/tag-based-controller convention.

**Tech Stack:** Flutter/GetX, `json_serializable`/`build_runner` for DTOs, `flutter_test` for controller/DTO/widget tests (no golden tests in this codebase).

**Spec:** Design decisions were resolved via `AskUserQuestion` during brainstorming (no separate spec file, given this closely mirrors the existing Organization/TeamProfile screens):
- **Placement**: a new "Tournaments" section inside `OrganizationDetailScreen`, not a separate top-level screen.
- **Edit UI**: one combined "Edit tournament" bottom sheet (name + format + status), not granular per-field controls.
- **Picker style**: choice chips for format/status, matching this app's existing role/status-pill visual language — not a dropdown.
- **Team enrollment UI**: a tap-a-name "Enroll team" sheet mirroring `assign_scorer_sheet.dart` exactly, not a multi-select checklist.
- **Owner determination**: the backend's `GET /v1/tournament/:tournamentId` response only returns `organization: {id, name}`, no owner. `TournamentDetailController` additionally fetches the organization's own detail (already returns `owner`) via the existing `GetOrganizationUseCase`, both to compute `isOwner` and to source the "eligible teams" list for enrollment (`org.teams` minus `tournament.teams`) — no new backend endpoint needed.
- **Translations**: unlike the pre-existing Organization feature (which declared `TranslationKeys` but never populated `en.dart`/`hi.dart`/`mr.dart` — a known, separately-tracked gap, not fixed by this plan), every new key here gets real values in all three files, plus a CMS `bulk-update` upload, per the root `CLAUDE.md`'s translation-flow requirement.

## Global Constraints

- Follow `organization` feature's exact layering: `data/` (endpoint, DTOs, api service, repository impl) → `domain/` (repository interface, use cases) → `presentation/` (controller, binding, pages, widget).
- DTOs use `@JsonSerializable()` + generated `.g.dart` via `dart run build_runner build --delete-conflicting-outputs`, except `UpdateTournamentReq` (see Task 1 — its `toJson` must omit absent fields, which generated code doesn't do, so it's written by hand).
- Routing: GetX path parameters only (`Get.parameters['tournamentId']`), never `Get.arguments` — matching every existing detail-screen route in this app.
- Controllers registered with `Get.lazyPut<T>(..., tag: id)`; screens resolve with `Get.find<T>(tag: id)` — the tagging is what lets navigating between two different tournaments each get an independent controller instance (the exact bug class `TeamProfileController`'s own tagging fixed).
- Use cases/repositories registered in a new `lib/core/di/injection/tournament_injection.dart`, `Get.lazyPut<T>(() => ..., fenix: true)`, appended to `injection_container.dart` after `OrganizationInjection.init()`.
- Bottom sheets: `CustomBottomSheet.wrapBottomSheet<T>(headlineText:, child:)` for create/edit forms, `CustomBottomSheet.warningBottomSheet<T>(title:, message:, confirmButtonName:)` for destructive confirmations — never a raw `showDialog`/`showModalBottomSheet`.
- Success snackbar fires from the **caller** after the sheet returns `true`, never from inside the sheet's own button handler — matching every existing sheet in this app.
- No shared `MonogramAvatar`/`RolePill` widget exists in this codebase by design — copy the small private `_monogram()`/pill-`Container` helpers inline into new widgets rather than searching for or creating a shared one.
- Every new `TranslationKeys` entry gets a real value added to `en.dart`, `hi.dart`, and `mr.dart` in the same task, plus a CMS `POST /api/v1/translations/bulk-update` call before this plan is considered done (Task 9) — do not repeat the Organization feature's gap.
- Do not touch anything under `cricket-scorer-backend/` — this plan is frontend-only.

---

### Task 1: Tournament data layer (DTOs, endpoint, API service, repository, use cases)

**Files:**
- Create: `lib/features/tournament/data/tournament_endpoint.dart`
- Create: `lib/features/tournament/data/models/request/create_tournament_req.dart` (+ `.g.dart`)
- Create: `lib/features/tournament/data/models/request/update_tournament_req.dart` (hand-written, no `.g.dart`)
- Create: `lib/features/tournament/data/models/request/enroll_tournament_team_req.dart` (+ `.g.dart`)
- Create: `lib/features/tournament/data/models/response/tournament_detail_res.dart` (+ `.g.dart`)
- Create: `lib/features/tournament/data/data_sources/remote/tournament_api_service.dart`
- Create: `lib/features/tournament/domain/repositories/tournament_repository.dart`
- Create: `lib/features/tournament/data/repositories/tournament_repository_impl.dart`
- Create: `lib/features/tournament/domain/usecases/create_tournament.dart`
- Create: `lib/features/tournament/domain/usecases/get_tournament.dart`
- Create: `lib/features/tournament/domain/usecases/update_tournament.dart`
- Create: `lib/features/tournament/domain/usecases/delete_tournament.dart`
- Create: `lib/features/tournament/domain/usecases/enroll_tournament_team.dart`
- Create: `lib/features/tournament/domain/usecases/remove_tournament_team.dart`
- Create: `lib/core/di/injection/tournament_injection.dart`
- Modify: `lib/core/di/injection_container.dart`
- Test: `test/features/tournament/data/models/tournament_detail_res_test.dart`

**Interfaces:**
- Produces: `TournamentRepository` with `createTournament(orgId, req)`, `getTournament(tournamentId)`, `updateTournament(tournamentId, req)`, `deleteTournament(tournamentId)`, `enrollTeam(tournamentId, teamId)`, `removeTeam(tournamentId, teamId)` — every method but `getTournament` returns `Either<CricketResponse<void>, CricketFailure>` (the caller always reloads full detail afterward rather than trusting a partial response body, matching `OrganizationRepository.removeMember`/`deleteOrganization`'s own `void` shape). `getTournament` returns `Either<CricketResponse<TournamentDetailRes>, CricketFailure>`.
- Consumes (Task 4 onward): the six use case classes below, `TournamentDetailRes`/`TournamentOrganizationRef`/`TournamentTeamRef` from the response DTO.

- [ ] **Step 1: Write the failing DTO test**

Create `test/features/tournament/data/models/tournament_detail_res_test.dart`:

```dart
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'TournamentDetailRes.fromJson parses organization and teams',
    () {
      final json = {
        'id': 'tournament-1',
        'name': 'Summer T20',
        'format': 'knockout',
        'status': 'upcoming',
        'organization': {'id': 'org-1', 'name': 'Riverside Cricket Club'},
        'teams': [
          {
            'id': 'team-1',
            'name': 'Riverside U19',
            'shortName': 'RU19',
            'joinedAt': '2026-09-05T10:05:00.000Z',
          },
        ],
        'createdAt': '2026-09-05T10:00:00.000Z',
      };

      final res = TournamentDetailRes.fromJson(json);

      expect(res.id, 'tournament-1');
      expect(res.name, 'Summer T20');
      expect(res.format, 'knockout');
      expect(res.status, 'upcoming');
      expect(res.organization.name, 'Riverside Cricket Club');
      expect(res.teams.single.shortName, 'RU19');
      expect(res.teams.single.joinedAt, DateTime.parse('2026-09-05T10:05:00.000Z'));
    },
  );

  test('TournamentDetailRes.fromJson handles a team with no shortName', () {
    final json = {
      'id': 'tournament-1',
      'name': 'Summer T20',
      'format': 'league',
      'status': 'ongoing',
      'organization': {'id': 'org-1', 'name': 'Riverside Cricket Club'},
      'teams': [
        {
          'id': 'team-1',
          'name': 'Riverside U19',
          'shortName': null,
          'joinedAt': '2026-09-05T10:05:00.000Z',
        },
      ],
      'createdAt': '2026-09-05T10:00:00.000Z',
    };

    final res = TournamentDetailRes.fromJson(json);

    expect(res.teams.single.shortName, isNull);
  });

  test('TournamentDetailRes.fromJson handles an empty teams list', () {
    final json = {
      'id': 'tournament-1',
      'name': 'Summer T20',
      'format': 'round_robin',
      'status': 'upcoming',
      'organization': {'id': 'org-1', 'name': 'Riverside Cricket Club'},
      'teams': <Map<String, dynamic>>[],
      'createdAt': '2026-09-05T10:00:00.000Z',
    };

    final res = TournamentDetailRes.fromJson(json);

    expect(res.teams, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/tournament/data/models/tournament_detail_res_test.dart`
Expected: FAIL — `Target of URI doesn't exist` (the file doesn't exist yet).

- [ ] **Step 3: Write the response DTOs**

Create `lib/features/tournament/data/models/response/tournament_detail_res.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'tournament_detail_res.g.dart';

/// `{id, name}` — the tournament's owning organization, as returned by
/// `GET /v1/tournament/:tournamentId`. Deliberately lighter than
/// `OrganizationDetailRes` (no owner, no members) — see
/// `TournamentDetailController` for how `isOwner` is derived by separately
/// fetching the full organization via this id.
@JsonSerializable()
class TournamentOrganizationRef {
  final String id;
  final String name;

  TournamentOrganizationRef({required this.id, required this.name});

  factory TournamentOrganizationRef.fromJson(Map<String, dynamic> json) =>
      _$TournamentOrganizationRefFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentOrganizationRefToJson(this);
}

/// One row of `TournamentDetailRes.teams` — an enrolled team, with the
/// timestamp it joined. Distinct from `OrganizationTeamRef` (no `joinedAt`)
/// even though both are `{id, name, shortName}` otherwise — matches this
/// codebase's established pattern of each feature owning its own
/// team-reference shape rather than sharing one across features.
@JsonSerializable()
class TournamentTeamRef {
  final String id;
  final String name;
  final String? shortName;
  final DateTime joinedAt;

  TournamentTeamRef({
    required this.id,
    required this.name,
    this.shortName,
    required this.joinedAt,
  });

  factory TournamentTeamRef.fromJson(Map<String, dynamic> json) =>
      _$TournamentTeamRefFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentTeamRefToJson(this);
}

/// `GET /v1/tournament/:tournamentId` — see docs/api.md.
@JsonSerializable(explicitToJson: true)
class TournamentDetailRes {
  final String id;
  final String name;

  /// `knockout` | `round_robin` | `league`.
  final String format;

  /// `upcoming` | `ongoing` | `completed`.
  final String status;
  final TournamentOrganizationRef organization;
  final List<TournamentTeamRef> teams;
  final DateTime createdAt;

  TournamentDetailRes({
    required this.id,
    required this.name,
    required this.format,
    required this.status,
    required this.organization,
    required this.teams,
    required this.createdAt,
  });

  factory TournamentDetailRes.fromJson(Map<String, dynamic> json) =>
      _$TournamentDetailResFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentDetailResToJson(this);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run:
```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/tournament/data/models/tournament_detail_res_test.dart
```
Expected: PASS — all 3 tests green (the `build_runner` run generates `tournament_detail_res.g.dart`).

- [ ] **Step 5: Write the remaining request DTOs**

Create `lib/features/tournament/data/models/request/create_tournament_req.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'create_tournament_req.g.dart';

@JsonSerializable()
class CreateTournamentReq {
  final String name;

  /// `knockout` | `round_robin` | `league`.
  final String format;

  CreateTournamentReq({required this.name, required this.format});

  factory CreateTournamentReq.fromJson(Map<String, dynamic> json) =>
      _$CreateTournamentReqFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTournamentReqToJson(this);
}
```

Create `lib/features/tournament/data/models/request/enroll_tournament_team_req.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'enroll_tournament_team_req.g.dart';

@JsonSerializable()
class EnrollTournamentTeamReq {
  final String teamId;

  EnrollTournamentTeamReq({required this.teamId});

  factory EnrollTournamentTeamReq.fromJson(Map<String, dynamic> json) =>
      _$EnrollTournamentTeamReqFromJson(json);

  Map<String, dynamic> toJson() => _$EnrollTournamentTeamReqToJson(this);
}
```

Create `lib/features/tournament/data/models/request/update_tournament_req.dart` (hand-written — see why below):

```dart
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
```

- [ ] **Step 6: Write the endpoint, API service, repository, and use cases**

Create `lib/features/tournament/data/tournament_endpoint.dart`:

```dart
class TournamentEndpoint {
  const TournamentEndpoint();

  String createUnderOrg(String orgId) => '/v1/organization/$orgId/tournaments';

  String detail(String tournamentId) => '/v1/tournament/$tournamentId';

  String update(String tournamentId) => '/v1/tournament/$tournamentId';

  String delete(String tournamentId) => '/v1/tournament/$tournamentId';

  String addTeam(String tournamentId) => '/v1/tournament/$tournamentId/teams';

  String removeTeam(String tournamentId, String teamId) =>
      '/v1/tournament/$tournamentId/teams/$teamId';
}
```

Create `lib/features/tournament/data/data_sources/remote/tournament_api_service.dart`:

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/create_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/enroll_tournament_team_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/tournament_endpoint.dart';

class TournamentApiService {
  final ApiClient apiClient;
  final TournamentEndpoint tournamentEndpoint;

  TournamentApiService({required this.apiClient, required this.tournamentEndpoint});

  Future<Either<ApiResponseModel, CricketFailure>> createTournament({
    required String orgId,
    required CreateTournamentReq? params,
  }) async {
    return await apiClient.post(
      endpoint: tournamentEndpoint.createUnderOrg(orgId),
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> getTournament({
    required String tournamentId,
  }) async {
    return await apiClient.get(endpoint: tournamentEndpoint.detail(tournamentId));
  }

  Future<Either<ApiResponseModel, CricketFailure>> updateTournament({
    required String tournamentId,
    required UpdateTournamentReq params,
  }) async {
    return await apiClient.patch(
      endpoint: tournamentEndpoint.update(tournamentId),
      data: params.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> deleteTournament({
    required String tournamentId,
  }) async {
    return await apiClient.delete(endpoint: tournamentEndpoint.delete(tournamentId));
  }

  Future<Either<ApiResponseModel, CricketFailure>> enrollTeam({
    required String tournamentId,
    required EnrollTournamentTeamReq? params,
  }) async {
    return await apiClient.post(
      endpoint: tournamentEndpoint.addTeam(tournamentId),
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> removeTeam({
    required String tournamentId,
    required String teamId,
  }) async {
    return await apiClient.delete(
      endpoint: tournamentEndpoint.removeTeam(tournamentId, teamId),
    );
  }
}
```

**Note for this step**: check `lib/core/network/api_client_service.dart`'s `ApiClient` class for the exact method name/signature it uses for a `PATCH` request (`organization`/`match` features' repos already call `apiClient.patch(...)` for `PATCH /v1/team/:teamId/organization` and `PATCH /v1/match/:matchId/scorer` — confirm the parameter name matches, e.g. `endpoint`/`data`, before writing this file).

Create `lib/features/tournament/domain/repositories/tournament_repository.dart`:

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/create_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/enroll_tournament_team_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';

abstract class TournamentRepository {
  /// `POST /v1/organization/:orgId/tournaments` — owner-only.
  Future<Either<CricketResponse<void>, CricketFailure>> createTournament({
    required String orgId,
    required CreateTournamentReq? params,
  });

  /// `GET /v1/tournament/:tournamentId` — any org member.
  Future<Either<CricketResponse<TournamentDetailRes>, CricketFailure>>
  getTournament({required String tournamentId});

  /// `PATCH /v1/tournament/:tournamentId` — owner-only.
  Future<Either<CricketResponse<void>, CricketFailure>> updateTournament({
    required String tournamentId,
    required UpdateTournamentReq params,
  });

  /// `DELETE /v1/tournament/:tournamentId` — owner-only.
  Future<Either<CricketResponse<void>, CricketFailure>> deleteTournament({
    required String tournamentId,
  });

  /// `POST /v1/tournament/:tournamentId/teams` — owner-only, team must
  /// already belong to the tournament's own organization.
  Future<Either<CricketResponse<void>, CricketFailure>> enrollTeam({
    required String tournamentId,
    required EnrollTournamentTeamReq? params,
  });

  /// `DELETE /v1/tournament/:tournamentId/teams/:teamId` — owner-only.
  Future<Either<CricketResponse<void>, CricketFailure>> removeTeam({
    required String tournamentId,
    required String teamId,
  });
}
```

Create `lib/features/tournament/data/repositories/tournament_repository_impl.dart`:

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/data_sources/remote/tournament_api_service.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/create_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/enroll_tournament_team_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class TournamentRepositoryImpl implements TournamentRepository {
  final TournamentApiService tournamentApiService;

  TournamentRepositoryImpl({required this.tournamentApiService});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> createTournament({
    required String orgId,
    required CreateTournamentReq? params,
  }) async {
    final response = await tournamentApiService.createTournament(
      orgId: orgId,
      params: params,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: null, message: response.result.message),
      );
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<TournamentDetailRes>, CricketFailure>>
  getTournament({required String tournamentId}) async {
    final response = await tournamentApiService.getTournament(
      tournamentId: tournamentId,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: TournamentDetailRes.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> updateTournament({
    required String tournamentId,
    required UpdateTournamentReq params,
  }) async {
    final response = await tournamentApiService.updateTournament(
      tournamentId: tournamentId,
      params: params,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: null, message: response.result.message),
      );
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> deleteTournament({
    required String tournamentId,
  }) async {
    final response = await tournamentApiService.deleteTournament(
      tournamentId: tournamentId,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: null, message: response.result.message),
      );
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> enrollTeam({
    required String tournamentId,
    required EnrollTournamentTeamReq? params,
  }) async {
    final response = await tournamentApiService.enrollTeam(
      tournamentId: tournamentId,
      params: params,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: null, message: response.result.message),
      );
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> removeTeam({
    required String tournamentId,
    required String teamId,
  }) async {
    final response = await tournamentApiService.removeTeam(
      tournamentId: tournamentId,
      teamId: teamId,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: null, message: response.result.message),
      );
    }
    return Either.fallback(response.fallback);
  }
}
```

Create the six use cases — each follows `GetOrganizationUseCase`'s exact `UseCase<Res, Params>` shape. `lib/features/tournament/domain/usecases/create_tournament.dart`:

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/create_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class CreateTournamentParams {
  final String orgId;
  final CreateTournamentReq req;

  CreateTournamentParams({required this.orgId, required this.req});
}

abstract class CreateTournamentUseCase
    implements UseCase<CricketResponse<void>, CreateTournamentParams> {}

class CreateTournamentUseCaseImpl implements CreateTournamentUseCase {
  final TournamentRepository tournamentRepository;

  CreateTournamentUseCaseImpl({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    CreateTournamentParams? params,
  }) async {
    return await tournamentRepository.createTournament(
      orgId: params!.orgId,
      params: params.req,
    );
  }
}
```

**Before writing this and the other five use cases**: read `lib/features/organization/domain/usecases/get_organization.dart` in full first — confirm whether this codebase's `UseCase<Res, Params>` convention is a single concrete class per use case (`class GetOrganizationUseCase implements UseCase<...>`) or an abstract-plus-impl pair as sketched above. Match whichever the existing organization use cases actually do; do not introduce a new pattern. (The abstract-plus-impl split shown here is illustrative of the params/call shape only — the research pass that fed this plan did not confirm which of the two structures `get_organization.dart` itself uses.)

The remaining five use cases follow the identical shape once that's confirmed:

`lib/features/tournament/domain/usecases/get_tournament.dart` — `GetTournamentParams {tournamentId}`, calls `tournamentRepository.getTournament(tournamentId: ...)`, returns `Either<CricketResponse<TournamentDetailRes>, CricketFailure>`.

`lib/features/tournament/domain/usecases/update_tournament.dart` — `UpdateTournamentParams {tournamentId, req}`, calls `tournamentRepository.updateTournament(tournamentId: ..., params: req)`.

`lib/features/tournament/domain/usecases/delete_tournament.dart` — `DeleteTournamentParams {tournamentId}`, calls `tournamentRepository.deleteTournament(tournamentId: ...)`.

`lib/features/tournament/domain/usecases/enroll_tournament_team.dart` — `EnrollTournamentTeamParams {tournamentId, teamId}`, builds `EnrollTournamentTeamReq(teamId: teamId)` internally and calls `tournamentRepository.enrollTeam(tournamentId: ..., params: ...)`.

`lib/features/tournament/domain/usecases/remove_tournament_team.dart` — `RemoveTournamentTeamParams {tournamentId, teamId}`, calls `tournamentRepository.removeTeam(tournamentId: ..., teamId: teamId)`.

- [ ] **Step 7: Register the DI**

Create `lib/core/di/injection/tournament_injection.dart`:

```dart
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/features/tournament/data/data_sources/remote/tournament_api_service.dart';
import 'package:cricket_scorer/features/tournament/data/tournament_endpoint.dart';
import 'package:cricket_scorer/features/tournament/data/repositories/tournament_repository_impl.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/create_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/update_tournament.dart';
import 'package:get/get.dart';

class TournamentInjection {
  TournamentInjection._();

  static void init() {
    const tournamentEndpoint = TournamentEndpoint();

    Get.lazyPut<TournamentApiService>(
      () => TournamentApiService(
        apiClient: Get.find<ApiClient>(),
        tournamentEndpoint: tournamentEndpoint,
      ),
      fenix: true,
    );

    Get.lazyPut<TournamentRepository>(
      () => TournamentRepositoryImpl(
        tournamentApiService: Get.find<TournamentApiService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<CreateTournamentUseCase>(
      () => CreateTournamentUseCaseImpl(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetTournamentUseCase>(
      () => GetTournamentUseCaseImpl(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<UpdateTournamentUseCase>(
      () => UpdateTournamentUseCaseImpl(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<DeleteTournamentUseCase>(
      () => DeleteTournamentUseCaseImpl(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<EnrollTournamentTeamUseCase>(
      () => EnrollTournamentTeamUseCaseImpl(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<RemoveTournamentTeamUseCase>(
      () => RemoveTournamentTeamUseCaseImpl(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );
  }
}
```

(Use case class names above assume the abstract-plus-impl pattern from Step 6 — rename to match whatever single-class convention Step 6 actually confirmed and used.)

In `lib/core/di/injection_container.dart`, add the import and call, after `OrganizationInjection.init();`:

```dart
import 'package:cricket_scorer/core/di/injection/tournament_injection.dart';
// ...
OrganizationInjection.init();
TournamentInjection.init();
```

- [ ] **Step 8: Run analyzer and the DTO test**

Run:
```bash
flutter analyze
flutter test test/features/tournament/data/models/tournament_detail_res_test.dart
```
Expected: 0 analyzer issues, 3/3 tests passing.

- [ ] **Step 9: Commit**

```bash
git add lib/features/tournament lib/core/di/injection/tournament_injection.dart lib/core/di/injection_container.dart test/features/tournament
git commit -m "feat: add Tournament data layer (DTOs, repository, use cases, DI)"
```

---

### Task 2: Widen Organization's own layer with a tournaments summary + create action

**Files:**
- Modify: `lib/features/organization/data/models/response/organization_detail_res.dart`
- Modify: `lib/features/organization/presentation/controllers/organization_detail_controller.dart`
- Modify: `lib/features/organization/presentation/bindings/organization_detail_binding.dart`
- Test: `test/features/organization/data/models/organization_detail_res_test.dart`
- Test: `test/features/organization/presentation/controllers/organization_detail_controller_test.dart`

**Interfaces:**
- Consumes: `CreateTournamentUseCase`, `CreateTournamentReq` (Task 1).
- Produces: `OrganizationDetailRes.tournaments` (`List<OrganizationTournamentRef>`) — consumed by Task 3's UI. `OrganizationDetailController.createTournament(name, format)` — consumed by Task 3's create sheet.

- [ ] **Step 1: Write the failing tests**

In `test/features/organization/data/models/organization_detail_res_test.dart`, add a new test (the two existing tests are untouched):

```dart
  test('OrganizationDetailRes.fromJson parses tournaments', () {
    final json = {
      'id': 'org-1',
      'name': 'Riverside Cricket Club',
      'owner': {'id': 'user-1', 'name': 'Asha'},
      'members': <Map<String, dynamic>>[],
      'teams': <Map<String, dynamic>>[],
      'tournaments': [
        {
          'id': 'tournament-1',
          'name': 'Summer T20',
          'format': 'knockout',
          'status': 'upcoming',
          'teamCount': 2,
        },
      ],
    };

    final res = OrganizationDetailRes.fromJson(json);

    expect(res.tournaments.single.name, 'Summer T20');
    expect(res.tournaments.single.teamCount, 2);
  });
```

In `test/features/organization/presentation/controllers/organization_detail_controller_test.dart`: widen the `_detail()` helper to pass `tournaments: const []` (a new required field — see Step 3 — will otherwise fail to compile), add a `_FakeCreateTournamentUseCase` class (same `noSuchMethod`-fallback shape as the file's other fakes), thread it through every `OrganizationDetailController(...)` construction in the file, and add:

```dart
  test('createTournament sends name and format and refreshes on success', () async {
    createTournamentUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: null),
    );
    getOrganizationUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _detail()),
    );

    final result = await controller.createTournament('Summer T20', 'knockout');

    expect(result, isTrue);
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/organization/`
Expected: FAIL to compile — `tournaments` isn't a parameter of `OrganizationDetailRes`, `CreateTournamentUseCase`/`createTournament` don't exist on the controller.

- [ ] **Step 3: Widen `OrganizationDetailRes`**

In `lib/features/organization/data/models/response/organization_detail_res.dart`, add a new class and field:

```dart
/// One row of `OrganizationDetailRes.tournaments` — deliberately the same
/// summary shape `GET /v1/tournament/:tournamentId`'s own list-adjacent
/// data omits (no team roster here, just a count) — see docs/api.md's
/// widened `GET /v1/organization/:orgId` response.
@JsonSerializable()
class OrganizationTournamentRef {
  final String id;
  final String name;
  final String format;
  final String status;
  final int teamCount;

  OrganizationTournamentRef({
    required this.id,
    required this.name,
    required this.format,
    required this.status,
    required this.teamCount,
  });

  factory OrganizationTournamentRef.fromJson(Map<String, dynamic> json) =>
      _$OrganizationTournamentRefFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationTournamentRefToJson(this);
}
```

Add `tournaments` to `OrganizationDetailRes`:

```dart
  final List<OrganizationTeamRef> teams;
  final List<OrganizationTournamentRef> tournaments;
```

(add the field, its constructor parameter as `required this.tournaments`, and it flows through `fromJson`/`toJson` automatically once `build_runner` regenerates — no manual JSON wiring needed since the field name matches the JSON key exactly).

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 4: Widen the controller and binding**

In `lib/features/organization/presentation/controllers/organization_detail_controller.dart`, add the import, field, constructor param, and method:

```dart
import 'package:cricket_scorer/features/tournament/data/models/request/create_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/create_tournament.dart';
```

```dart
  final CreateTournamentUseCase createTournamentUseCase;
```

(add to the constructor's required named params, alongside the existing five use cases)

```dart
  Future<bool> createTournament(String name, String format) async {
    final response = await createTournamentUseCase(
      params: CreateTournamentParams(
        orgId: orgId,
        req: CreateTournamentReq(name: name, format: format),
      ),
    );

    if (!response.isResult) return false;
    await loadDetail();
    return true;
  }
```

In `lib/features/organization/presentation/bindings/organization_detail_binding.dart`, add the import and the new constructor argument:

```dart
import 'package:cricket_scorer/features/tournament/domain/usecases/create_tournament.dart';
```
```dart
        createTournamentUseCase: Get.find<CreateTournamentUseCase>(),
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/features/organization/`
Expected: PASS — all tests in both files green.

- [ ] **Step 6: Run analyzer**

Run: `flutter analyze`
Expected: 0 issues.

- [ ] **Step 7: Commit**

```bash
git add lib/features/organization test/features/organization
git commit -m "feat: widen OrganizationDetailRes/Controller with tournaments"
```

---

### Task 3: Tournaments section + create sheet on OrganizationDetailScreen

**Files:**
- Create: `lib/features/tournament/presentation/widget/format_status_chips.dart`
- Modify: `lib/features/organization/presentation/pages/organization_detail_screen.dart`
- Modify: `lib/config/routes/app_routes.dart`

**Interfaces:**
- Consumes: `OrganizationDetailController.createTournament` (Task 2), `AppRoutes.tournamentDetailPath` (defined in this task, used by Task 5's screen registration).
- Produces: `FormatChoiceChips` widget (also consumed by Task 6's edit sheet) and `StatusChoiceChips` widget (consumed by Task 6 only — not shown at creation, since a new tournament always starts `upcoming`).

- [ ] **Step 1: Add the tournament route constant**

In `lib/config/routes/app_routes.dart`, add after `organizationDetailPath`:

```dart
  /// Registered with a GetX path parameter, same shape as
  /// [organizationDetail]. Never navigate with this constant directly —
  /// use [tournamentDetailPath].
  static const String tournamentDetail = '/tournament/:tournamentId';

  static String tournamentDetailPath(String tournamentId) =>
      '/tournament/$tournamentId';
```

- [ ] **Step 2: Write the format/status choice-chip widgets**

Create `lib/features/tournament/presentation/widget/format_status_chips.dart`:

```dart
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const List<String> tournamentFormats = ['knockout', 'round_robin', 'league'];
const List<String> tournamentStatuses = ['upcoming', 'ongoing', 'completed'];

String tournamentFormatLabel(String format) => switch (format) {
  'knockout' => TranslationKeys.formatKnockout.tr,
  'round_robin' => TranslationKeys.formatRoundRobin.tr,
  'league' => TranslationKeys.formatLeague.tr,
  _ => format,
};

String tournamentStatusLabel(String status) => switch (status) {
  'upcoming' => TranslationKeys.statusUpcoming.tr,
  'ongoing' => TranslationKeys.statusOngoing.tr,
  'completed' => TranslationKeys.statusCompleted.tr,
  _ => status,
};

/// The same three semantic-status colors `_RosterRow`'s role pill and
/// match-result badges already draw from — `ongoing` reuses `statusWarning`
/// (this app's "live" color everywhere else), not a fourth new color.
Color tournamentStatusColor(BuildContext context, String status) =>
    switch (status) {
      'upcoming' => context.colors.statusInfo,
      'ongoing' => context.colors.statusWarning,
      'completed' => context.colors.statusSuccess,
      _ => context.colorScheme.onSurfaceVariant,
    };

/// A row of tappable format pills — used at both creation (no initial
/// selection required beyond the caller's own default) and in the edit
/// sheet (pre-selected to the tournament's current format).
class FormatChoiceChips extends StatelessWidget {
  const FormatChoiceChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final format in tournamentFormats)
          ChoiceChip(
            label: CricketText(text: tournamentFormatLabel(format)),
            selected: selected == format,
            selectedColor: context.colors.chipSelected,
            backgroundColor: context.colors.chipBackground,
            onSelected: (_) => onSelected(format),
          ),
      ],
    );
  }
}

/// Same shape as [FormatChoiceChips], for `status` — only ever shown in the
/// edit sheet (Task 6), never at creation.
class StatusChoiceChips extends StatelessWidget {
  const StatusChoiceChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final status in tournamentStatuses)
          ChoiceChip(
            label: CricketText(text: tournamentStatusLabel(status)),
            selected: selected == status,
            selectedColor: context.colors.chipSelected,
            backgroundColor: context.colors.chipBackground,
            onSelected: (_) => onSelected(status),
          ),
      ],
    );
  }
}
```

- [ ] **Step 3: Add the Tournaments section and create sheet to OrganizationDetailScreen**

In `lib/features/organization/presentation/pages/organization_detail_screen.dart`, add imports:

```dart
import 'package:cricket_scorer/features/tournament/presentation/widget/format_status_chips.dart';
```

Add a new private field to `_OrganizationDetailScreenState` holding the create sheet's selected format (a `String` isn't reactive state worth an `Rx` here — it's local to one sheet's lifetime, rebuilt via `StatefulBuilder` same as any other sheet-local selection in this codebase would be):

```dart
  Future<void> _showAddTournamentSheet() async {
    final nameController = TextEditingController();
    var selectedFormat = tournamentFormats.first;

    final created = await CustomBottomSheet.wrapBottomSheet<bool>(
      headlineText: TranslationKeys.addTournament.tr,
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CricketTextField(
              controller: nameController,
              hintText: TranslationKeys.tournamentName.tr,
              labelText: TranslationKeys.tournamentName.tr,
              prefixIcon: const Icon(Icons.emoji_events_outlined),
              isRequired: true,
            ),
            16.h,
            FormatChoiceChips(
              selected: selectedFormat,
              onSelected: (format) =>
                  setSheetState(() => selectedFormat = format),
            ),
            20.h,
            CricketButton(
              buttonText: TranslationKeys.create.tr,
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final success = await controller.createTournament(
                  name,
                  selectedFormat,
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
      ),
    );
    if (created == true) {
      CricketSnackbar.showSuccessMessage(TranslationKeys.tournamentCreated.tr);
    }
  }
```

Add a `_TournamentRow` widget (sibling to the existing `_TeamRow`):

```dart
class _TournamentRow extends StatelessWidget {
  const _TournamentRow({required this.tournament});

  final OrganizationTournamentRef tournament;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: 8.radius,
        onTap: () => Get.toNamed<dynamic>(
          AppRoutes.tournamentDetailPath(tournament.id),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: CricketText(
                  text: tournament.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.secondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: tournamentStatusColor(
                    context,
                    tournament.status,
                  ).withValues(alpha: 0.12),
                  borderRadius: 8.radius,
                ),
                child: CricketText(
                  text: tournamentStatusLabel(tournament.status),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: tournamentStatusColor(context, tournament.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              8.w,
              Icon(
                Icons.chevron_right,
                size: 18,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Insert a Tournaments section into the `build()` method's `ListView`, right after the existing Teams section (after the `if (detail.teams.isEmpty) ... else for (final team in detail.teams) ...` block):

```dart
                24.h,
                _SectionHeader(
                  title: TranslationKeys.tournaments.tr,
                  actionLabel: controller.isOwner
                      ? TranslationKeys.addTournament.tr
                      : null,
                  onAction: _showAddTournamentSheet,
                ),
                8.h,
                if (detail.tournaments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CricketText(
                      text: TranslationKeys.noTournamentsYet.tr,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (final tournament in detail.tournaments) ...[
                    _TournamentRow(tournament: tournament),
                    4.h,
                  ],
```

- [ ] **Step 4: Run analyzer**

Run: `flutter analyze`
Expected: 0 issues.

- [ ] **Step 5: Manual verification (no automated test for this step — screen-level rendering, covered by Task 9's on-device pass)**

This step intentionally has no widget test — `OrganizationDetailScreen` itself has none in this codebase (confirmed: only its controller and DTO are tested), consistent with `TeamProfileScreen`'s own testing boundary. Defer visual verification to Task 9.

- [ ] **Step 6: Commit**

```bash
git add lib/features/tournament/presentation/widget/format_status_chips.dart lib/features/organization/presentation/pages/organization_detail_screen.dart lib/config/routes/app_routes.dart
git commit -m "feat: add Tournaments section and create sheet to OrganizationDetailScreen"
```

---

### Task 4: TournamentDetailController + Binding

**Files:**
- Create: `lib/features/tournament/presentation/controllers/tournament_detail_controller.dart`
- Create: `lib/features/tournament/presentation/bindings/tournament_detail_binding.dart`
- Test: `test/features/tournament/presentation/controllers/tournament_detail_controller_test.dart`

**Interfaces:**
- Consumes: all six `Tournament*UseCase`s (Task 1), `GetOrganizationUseCase` (existing, from `organization` feature), `currentUserId()` (existing, `lib/core/utils/current_user.dart`).
- Produces: `TournamentDetailController` with `detail` (`Rxn<TournamentDetailRes>`), `organizationDetail` (`Rxn<OrganizationDetailRes>`), `isLoading`, `loadError`, `isOwner` getter, `eligibleTeams` getter, `loadDetail()`, `updateTournament(name?, format?, status?)`, `deleteTournament()`, `enrollTeam(teamId)`, `removeTeam(teamId)` — all consumed by Task 5's screen and Task 6's sheets.

- [ ] **Step 1: Write the failing tests**

Create `test/features/tournament/presentation/controllers/tournament_detail_controller_test.dart`:

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/create_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/update_tournament.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

TournamentDetailRes _tournament({List<TournamentTeamRef> teams = const []}) =>
    TournamentDetailRes(
      id: 'tournament-1',
      name: 'Summer T20',
      format: 'knockout',
      status: 'upcoming',
      organization: TournamentOrganizationRef(id: 'org-1', name: 'Riverside CC'),
      teams: teams,
      createdAt: DateTime.parse('2026-09-05T10:00:00.000Z'),
    );

OrganizationDetailRes _org({List<OrganizationTeamRef> teams = const []}) =>
    OrganizationDetailRes(
      id: 'org-1',
      name: 'Riverside CC',
      owner: OrganizationUserRef(id: 'owner-1', name: 'Asha'),
      members: const [],
      teams: teams,
      tournaments: const [],
    );

class _FakeGetTournamentUseCase implements GetTournamentUseCase {
  Either<CricketResponse<TournamentDetailRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<TournamentDetailRes>, CricketFailure>> call({
    GetTournamentParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

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

class _FakeUpdateTournamentUseCase implements UpdateTournamentUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;
  UpdateTournamentParams? lastParams;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    UpdateTournamentParams? params,
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

class _FakeDeleteTournamentUseCase implements DeleteTournamentUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    DeleteTournamentParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeEnrollTournamentTeamUseCase implements EnrollTournamentTeamUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;
  EnrollTournamentTeamParams? lastParams;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    EnrollTournamentTeamParams? params,
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

class _FakeRemoveTournamentTeamUseCase implements RemoveTournamentTeamUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    RemoveTournamentTeamParams? params,
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
  late _FakeGetTournamentUseCase getTournamentUseCase;
  late _FakeGetOrganizationUseCase getOrganizationUseCase;
  late _FakeUpdateTournamentUseCase updateTournamentUseCase;
  late _FakeDeleteTournamentUseCase deleteTournamentUseCase;
  late _FakeEnrollTournamentTeamUseCase enrollTeamUseCase;
  late _FakeRemoveTournamentTeamUseCase removeTeamUseCase;
  late TournamentDetailController controller;

  TournamentDetailController build(String userId) => TournamentDetailController(
    tournamentId: 'tournament-1',
    currentUserId: userId,
    getTournamentUseCase: getTournamentUseCase,
    getOrganizationUseCase: getOrganizationUseCase,
    updateTournamentUseCase: updateTournamentUseCase,
    deleteTournamentUseCase: deleteTournamentUseCase,
    enrollTournamentTeamUseCase: enrollTeamUseCase,
    removeTournamentTeamUseCase: removeTeamUseCase,
  );

  setUp(() {
    Get.testMode = true;
    getTournamentUseCase = _FakeGetTournamentUseCase();
    getOrganizationUseCase = _FakeGetOrganizationUseCase();
    updateTournamentUseCase = _FakeUpdateTournamentUseCase();
    deleteTournamentUseCase = _FakeDeleteTournamentUseCase();
    enrollTeamUseCase = _FakeEnrollTournamentTeamUseCase();
    removeTeamUseCase = _FakeRemoveTournamentTeamUseCase();
    controller = build('owner-1');
  });

  tearDown(Get.reset);

  test(
    'loadDetail populates detail and organizationDetail, isOwner true for the owner',
    () async {
      getTournamentUseCase.response = Either.result(
        CricketResponse(message: 'ok', data: _tournament()),
      );
      getOrganizationUseCase.response = Either.result(
        CricketResponse(message: 'ok', data: _org()),
      );

      await controller.loadDetail();

      expect(controller.detail.value?.name, 'Summer T20');
      expect(controller.organizationDetail.value?.name, 'Riverside CC');
      expect(controller.isOwner, isTrue);
    },
  );

  test('isOwner is false for a non-owner member viewer', () async {
    controller = build('member-1');
    getTournamentUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _tournament()),
    );
    getOrganizationUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _org()),
    );

    await controller.loadDetail();

    expect(controller.isOwner, isFalse);
  });

  test('eligibleTeams excludes teams already enrolled in the tournament', () async {
    getTournamentUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: _tournament(
          teams: [
            TournamentTeamRef(
              id: 'team-1',
              name: 'Riverside U19',
              joinedAt: DateTime.now(),
            ),
          ],
        ),
      ),
    );
    getOrganizationUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: _org(
          teams: [
            OrganizationTeamRef(id: 'team-1', name: 'Riverside U19'),
            OrganizationTeamRef(id: 'team-2', name: 'Riverside U16'),
          ],
        ),
      ),
    );

    await controller.loadDetail();

    expect(controller.eligibleTeams.map((t) => t.id), ['team-2']);
  });

  test('updateTournament sends only the changed fields and refreshes', () async {
    getTournamentUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _tournament()),
    );
    getOrganizationUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _org()),
    );
    await controller.loadDetail();

    updateTournamentUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: null),
    );

    final result = await controller.updateTournament(status: 'ongoing');

    expect(result, isTrue);
    expect(updateTournamentUseCase.lastParams?.req.status, 'ongoing');
    expect(updateTournamentUseCase.lastParams?.req.name, isNull);
  });

  test('deleteTournament returns the use case result directly', () async {
    deleteTournamentUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: null),
    );

    final result = await controller.deleteTournament();

    expect(result, isTrue);
  });

  test('enrollTeam sends teamId and refreshes on success', () async {
    getTournamentUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _tournament()),
    );
    getOrganizationUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _org()),
    );
    await controller.loadDetail();

    enrollTeamUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: null),
    );

    final result = await controller.enrollTeam('team-2');

    expect(result, isTrue);
    expect(enrollTeamUseCase.lastParams?.teamId, 'team-2');
  });

  test('removeTeam returns false on failure without refreshing', () async {
    removeTeamUseCase.response = Either.fallback(
      CricketServerErrorFailure(statusCode: 500, message: 'Server error'),
    );

    final result = await controller.removeTeam('team-1');

    expect(result, isFalse);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/tournament/presentation/controllers/tournament_detail_controller_test.dart`
Expected: FAIL to compile — `TournamentDetailController` doesn't exist yet.

- [ ] **Step 3: Write the controller**

Create `lib/features/tournament/presentation/controllers/tournament_detail_controller.dart`:

```dart
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/create_tournament.dart' show CreateTournamentUseCase;
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/update_tournament.dart';
import 'package:get/get.dart';

/// One tournament's detail plus the owning organization's own detail — the
/// latter fetched purely to answer "is the viewer the owner" and "which of
/// this org's teams aren't enrolled yet," since
/// `GET /v1/tournament/:tournamentId` itself returns neither (see
/// docs/api.md — it only returns `organization: {id, name}`, no owner).
class TournamentDetailController extends GetxController {
  final String tournamentId;
  final String currentUserId;

  final GetTournamentUseCase getTournamentUseCase;
  final GetOrganizationUseCase getOrganizationUseCase;
  final UpdateTournamentUseCase updateTournamentUseCase;
  final DeleteTournamentUseCase deleteTournamentUseCase;
  final EnrollTournamentTeamUseCase enrollTournamentTeamUseCase;
  final RemoveTournamentTeamUseCase removeTournamentTeamUseCase;

  TournamentDetailController({
    required this.tournamentId,
    required this.currentUserId,
    required this.getTournamentUseCase,
    required this.getOrganizationUseCase,
    required this.updateTournamentUseCase,
    required this.deleteTournamentUseCase,
    required this.enrollTournamentTeamUseCase,
    required this.removeTournamentTeamUseCase,
  });

  final detail = Rxn<TournamentDetailRes>();
  final organizationDetail = Rxn<OrganizationDetailRes>();
  final isLoading = true.obs;
  final loadError = Rxn<String>();

  bool get isOwner => organizationDetail.value?.owner.id == currentUserId;

  /// The org's teams not already enrolled in this tournament — the source
  /// list for the "Enroll team" sheet.
  List<OrganizationTeamRef> get eligibleTeams {
    final orgTeams = organizationDetail.value?.teams ?? const [];
    final enrolledIds = detail.value?.teams.map((t) => t.id).toSet() ?? const {};
    return orgTeams.where((t) => !enrolledIds.contains(t.id)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadDetail();
  }

  Future<void> loadDetail() async {
    isLoading.value = true;
    loadError.value = null;

    final response = await getTournamentUseCase(
      params: GetTournamentParams(tournamentId: tournamentId),
    );

    if (!response.isResult) {
      isLoading.value = false;
      loadError.value = response.fallback.message;
      return;
    }

    detail.value = response.result.data;

    final orgResponse = await getOrganizationUseCase(
      params: GetOrganizationParams(orgId: detail.value!.organization.id),
    );
    if (orgResponse.isResult) {
      organizationDetail.value = orgResponse.result.data;
    }

    isLoading.value = false;
  }

  Future<bool> updateTournament({String? name, String? format, String? status}) async {
    final response = await updateTournamentUseCase(
      params: UpdateTournamentParams(
        tournamentId: tournamentId,
        req: UpdateTournamentReq(name: name, format: format, status: status),
      ),
    );

    if (!response.isResult) return false;
    await loadDetail();
    return true;
  }

  Future<bool> deleteTournament() async {
    final response = await deleteTournamentUseCase(
      params: DeleteTournamentParams(tournamentId: tournamentId),
    );
    return response.isResult;
  }

  Future<bool> enrollTeam(String teamId) async {
    final response = await enrollTournamentTeamUseCase(
      params: EnrollTournamentTeamParams(
        tournamentId: tournamentId,
        teamId: teamId,
      ),
    );

    if (!response.isResult) return false;
    await loadDetail();
    return true;
  }

  Future<bool> removeTeam(String teamId) async {
    final response = await removeTournamentTeamUseCase(
      params: RemoveTournamentTeamParams(
        tournamentId: tournamentId,
        teamId: teamId,
      ),
    );

    if (!response.isResult) return false;
    await loadDetail();
    return true;
  }
}
```

(Drop the unused `CreateTournamentUseCase` import shown above if the analyzer flags it — this controller doesn't create tournaments, only `OrganizationDetailController` does; it was left out of the final import list intentionally, listed above only as a reminder not to accidentally wire tournament-creation into the wrong controller.)

- [ ] **Step 4: Write the binding**

Create `lib/features/tournament/presentation/bindings/tournament_detail_binding.dart`:

```dart
import 'package:cricket_scorer/core/utils/current_user.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/update_tournament.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:get/get.dart';

class TournamentDetailBinding extends Bindings {
  @override
  void dependencies() {
    final tournamentId = Get.parameters['tournamentId']?.trim() ?? '';
    Get.lazyPut<TournamentDetailController>(
      () => TournamentDetailController(
        tournamentId: tournamentId,
        currentUserId: currentUserId(),
        getTournamentUseCase: Get.find<GetTournamentUseCase>(),
        getOrganizationUseCase: Get.find<GetOrganizationUseCase>(),
        updateTournamentUseCase: Get.find<UpdateTournamentUseCase>(),
        deleteTournamentUseCase: Get.find<DeleteTournamentUseCase>(),
        enrollTournamentTeamUseCase: Get.find<EnrollTournamentTeamUseCase>(),
        removeTournamentTeamUseCase: Get.find<RemoveTournamentTeamUseCase>(),
      ),
      tag: tournamentId,
    );
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/features/tournament/presentation/controllers/tournament_detail_controller_test.dart`
Expected: PASS — all 7 tests green.

- [ ] **Step 6: Run analyzer**

Run: `flutter analyze`
Expected: 0 issues.

- [ ] **Step 7: Commit**

```bash
git add lib/features/tournament/presentation/controllers lib/features/tournament/presentation/bindings test/features/tournament/presentation/controllers
git commit -m "feat: add TournamentDetailController and binding"
```

---

### Task 5: TournamentDetailScreen + route registration

**Files:**
- Create: `lib/features/tournament/presentation/pages/tournament_detail_screen.dart`
- Modify: `lib/config/routes/app_pages.dart`

**Interfaces:**
- Consumes: `TournamentDetailController` (Task 4), `showEditTournamentSheet`/`showEnrollTeamSheet` (Task 6 — this screen calls them, so Task 5 and Task 6 must land together or Task 5 will not compile; if executing strictly in order, write Task 5's screen body referencing these two functions by their Task-6 signatures below, then complete Task 6 immediately after before running `flutter analyze`).

- [ ] **Step 1: Write the screen**

Create `lib/features/tournament/presentation/pages/tournament_detail_screen.dart`:

```dart
import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/enroll_team_sheet.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/edit_tournament_sheet.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/format_status_chips.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A tournament's detail plus its enrolled-team roster — reached by
/// tapping a tournament row on `OrganizationDetailScreen`. Shares that
/// screen's and `TeamProfileScreen`'s section/row vocabulary.
class TournamentDetailScreen extends StatefulWidget {
  const TournamentDetailScreen({super.key});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  late final String _tournamentId = Get.parameters['tournamentId']?.trim() ?? '';
  late final TournamentDetailController controller =
      Get.find<TournamentDetailController>(tag: _tournamentId);

  Future<void> _confirmRemoveTeam(TournamentTeamRef team) async {
    final confirmed = await CustomBottomSheet.warningBottomSheet<bool>(
      title: TranslationKeys.removeTeamConfirmTitle.tr,
      message: TranslationKeys.removeTeamConfirmMessage.tr,
      confirmButtonName: TranslationKeys.removeTeam.tr,
    );
    if (confirmed != true) return;

    final success = await controller.removeTeam(team.id);
    if (success) {
      CricketSnackbar.showSuccessMessage(
        TranslationKeys.teamRemovedFromTournament.tr,
      );
    } else {
      CricketSnackbar.showErrorMessage(TranslationKeys.somethingWentWrong.tr);
    }
  }

  Future<void> _confirmDeleteTournament() async {
    final confirmed = await CustomBottomSheet.warningBottomSheet<bool>(
      title: TranslationKeys.deleteTournamentConfirmTitle.tr,
      message: TranslationKeys.deleteTournamentConfirmMessage.tr,
      confirmButtonName: TranslationKeys.deleteTournament.tr,
    );
    if (confirmed != true) return;

    final success = await controller.deleteTournament();
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
        title: TranslationKeys.tournamentDetail.tr,
        actions: [
          Obx(() {
            if (!controller.isOwner) return const SizedBox.shrink();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => showEditTournamentSheet(controller: controller),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _confirmDeleteTournament,
                ),
              ],
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final loading = controller.isLoading.value;
          final error = controller.loadError.value;
          final data = controller.detail.value;

          if (loading && data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null && data == null) {
            return Center(
              child: Padding(
                padding: 24.p,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 56,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    16.h,
                    CricketText(text: error, textAlign: TextAlign.center),
                    24.h,
                    CricketButton(
                      buttonText: TranslationKeys.retry.tr,
                      onPressed: controller.loadDetail,
                      width: 160,
                    ),
                  ],
                ),
              ),
            );
          }
          if (data == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: controller.loadDetail,
            child: ListView(
              padding: 16.p,
              children: [
                CricketText(
                  text: data.name,
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                8.h,
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.chipBackground,
                        borderRadius: 8.radius,
                      ),
                      child: CricketText(
                        text: tournamentFormatLabel(data.format),
                        style: context.textTheme.labelSmall,
                      ),
                    ),
                    8.w,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tournamentStatusColor(
                          context,
                          data.status,
                        ).withValues(alpha: 0.12),
                        borderRadius: 8.radius,
                      ),
                      child: CricketText(
                        text: tournamentStatusLabel(data.status),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: tournamentStatusColor(context, data.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                4.h,
                CricketText(
                  text: data.organization.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                24.h,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CricketText(
                      text: TranslationKeys.teams.tr,
                      style: context.textTheme.titleSmall,
                    ),
                    if (controller.isOwner)
                      TextButton.icon(
                        onPressed: () =>
                            showEnrollTeamSheet(controller: controller),
                        icon: const Icon(Icons.add, size: 18),
                        label: CricketText(text: TranslationKeys.enrollTeam.tr),
                      ),
                  ],
                ),
                8.h,
                if (data.teams.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CricketText(
                      text: TranslationKeys.noTeamsInTournament.tr,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (final team in data.teams) ...[
                    _EnrolledTeamRow(
                      team: team,
                      canRemove: controller.isOwner,
                      onRemove: () => _confirmRemoveTeam(team),
                    ),
                    4.h,
                  ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _EnrolledTeamRow extends StatelessWidget {
  const _EnrolledTeamRow({
    required this.team,
    required this.canRemove,
    required this.onRemove,
  });

  final TournamentTeamRef team;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: 8.radius,
        onTap: () => Get.toNamed<dynamic>(AppRoutes.teamProfilePath(team.id)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: CricketText(
                  text: team.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.secondary,
                  ),
                ),
              ),
              if (team.shortName != null) ...[
                CricketText(
                  text: team.shortName!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                8.w,
              ],
              if (canRemove)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onRemove,
                )
              else
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: context.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Register the route**

In `lib/config/routes/app_pages.dart`, add the imports:

```dart
import 'package:cricket_scorer/features/tournament/presentation/bindings/tournament_detail_binding.dart';
import 'package:cricket_scorer/features/tournament/presentation/pages/tournament_detail_screen.dart';
```

Add a new `GetPage` after the `organizationDetail` one:

```dart
    GetPage(
      name: AppRoutes.tournamentDetail,
      page: () => const TournamentDetailScreen(),
      binding: TournamentDetailBinding(),
    ),
```

- [ ] **Step 3: Complete Task 6 before running the analyzer**

This screen imports `showEditTournamentSheet`/`showEnrollTeamSheet` from files Task 6 creates — it will not compile until Task 6 lands. Proceed directly to Task 6, then return here.

- [ ] **Step 4: Run analyzer (after Task 6 is complete)**

Run: `flutter analyze`
Expected: 0 issues.

- [ ] **Step 5: Commit**

```bash
git add lib/features/tournament/presentation/pages lib/config/routes/app_pages.dart
git commit -m "feat: add TournamentDetailScreen and register its route"
```

---

### Task 6: Edit-tournament and enroll-team bottom sheets

**Files:**
- Create: `lib/features/tournament/presentation/widget/edit_tournament_sheet.dart`
- Create: `lib/features/tournament/presentation/widget/enroll_team_sheet.dart`
- Test: `test/features/tournament/presentation/widget/edit_tournament_sheet_test.dart`
- Test: `test/features/tournament/presentation/widget/enroll_team_sheet_test.dart`

**Interfaces:**
- Consumes: `TournamentDetailController` (Task 4), `FormatChoiceChips`/`StatusChoiceChips` (Task 3).
- Produces: `showEditTournamentSheet({required TournamentDetailController controller})`, `showEnrollTeamSheet({required TournamentDetailController controller})` — both consumed by Task 5's screen.

**Before writing the tests below**: read `test/features/scoring/presentation/widget/assign_scorer_sheet_test.dart` in full — its `tapAndAwaitSnackbar`/`drainSnackbar` helpers (frame-by-frame `pump(Duration(milliseconds: 16))` loops, never `pumpAndSettle()`) exist because `GetX`'s `SnackbarController` races the bottom sheet's own pop animation when the snackbar fires from the continuation after `Get.back()`. Both sheets in this task have the exact same shape (`Get.back()` then a snackbar), so both test files below need the identical helpers — copy them in rather than re-deriving the timing empirically again.

- [ ] **Step 1: Write the failing tests**

Create `test/features/tournament/presentation/widget/edit_tournament_sheet_test.dart`:

```dart
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/edit_tournament_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

// Reuses this controller directly (not a fake use-case set) since the sheet
// only ever calls `controller.updateTournament(...)` — a thin fake
// subclass overriding just that one method is simpler and more honest
// about what this widget test actually exercises than wiring six fake use
// cases through the real controller.
class _FakeTournamentDetailController extends TournamentDetailController {
  _FakeTournamentDetailController()
    : super(
        tournamentId: 'tournament-1',
        currentUserId: 'owner-1',
        getTournamentUseCase: _UnusedGetTournamentUseCase(),
        getOrganizationUseCase: _UnusedGetOrganizationUseCase(),
        updateTournamentUseCase: _UnusedUpdateTournamentUseCase(),
        deleteTournamentUseCase: _UnusedDeleteTournamentUseCase(),
        enrollTournamentTeamUseCase: _UnusedEnrollTournamentTeamUseCase(),
        removeTournamentTeamUseCase: _UnusedRemoveTournamentTeamUseCase(),
      ) {
    detail.value = TournamentDetailRes(
      id: 'tournament-1',
      name: 'Summer T20',
      format: 'knockout',
      status: 'upcoming',
      organization: TournamentOrganizationRef(id: 'org-1', name: 'Riverside CC'),
      teams: const [],
      createdAt: DateTime.now(),
    );
  }

  bool updateCalled = false;
  String? lastName, lastFormat, lastStatus;
  bool shouldSucceed = true;

  @override
  Future<bool> updateTournament({String? name, String? format, String? status}) async {
    updateCalled = true;
    lastName = name;
    lastFormat = format;
    lastStatus = status;
    return shouldSucceed;
  }
}

// noSuchMethod-only fakes — never called, since _FakeTournamentDetailController
// overrides every method this sheet actually exercises.
class _UnusedGetTournamentUseCase implements GetTournamentUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedGetOrganizationUseCase implements GetOrganizationUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedUpdateTournamentUseCase implements UpdateTournamentUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedDeleteTournamentUseCase implements DeleteTournamentUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedEnrollTournamentTeamUseCase implements EnrollTournamentTeamUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedRemoveTournamentTeamUseCase implements RemoveTournamentTeamUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _FakeTournamentDetailController controller;

  Future<void> pumpOpenButton(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showEditTournamentSheet(controller: controller),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  // See this file's header comment — same GetX snackbar-after-pop race
  // assign_scorer_sheet_test.dart works around, same fix.
  Future<void> tapAndAwaitSnackbar(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Future<void> drainSnackbar(WidgetTester tester) async {
    for (var i = 0; i < 220; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  setUp(() {
    Get.testMode = true;
    controller = _FakeTournamentDetailController();
  });

  tearDown(Get.reset);

  testWidgets('opens prefilled with the current name, format, and status', (
    tester,
  ) async {
    await pumpOpenButton(tester);

    expect(find.text('Summer T20'), findsOneWidget);
  });

  testWidgets('submitting sends the edited fields and shows a success snackbar', (
    tester,
  ) async {
    await pumpOpenButton(tester);

    await tester.enterText(find.byType(TextField), 'Winter T20');
    await tapAndAwaitSnackbar(tester, find.text('save'));

    expect(controller.updateCalled, isTrue);
    expect(controller.lastName, 'Winter T20');
    expect(controller.lastFormat, 'knockout');
    expect(controller.lastStatus, 'upcoming');
    expect(find.text('tournament_updated'), findsOneWidget);
    await drainSnackbar(tester);
  });

  testWidgets('shows an error snackbar and stays open on failure', (
    tester,
  ) async {
    controller.shouldSucceed = false;
    await pumpOpenButton(tester);

    await tapAndAwaitSnackbar(tester, find.text('save'));

    expect(find.text('something_went_wrong'), findsOneWidget);
  });
}
```

**Note**: the `find.text('save')` above assumes the sheet's submit button reads `TranslationKeys.save.tr` — check whether `save` already exists as a key (it likely doesn't; `create`/`add` do per the research). If it doesn't exist, add a new `save = 'save'` key in Task 8 rather than reusing `create`, since "Save" is the correct verb for editing an existing thing versus creating a new one — and update this test's finder to match whatever key you actually add.

Create `test/features/tournament/presentation/widget/enroll_team_sheet_test.dart`:

```dart
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/enroll_team_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

// Same fake-controller reasoning as edit_tournament_sheet_test.dart.
class _FakeTournamentDetailController extends TournamentDetailController {
  _FakeTournamentDetailController({List<OrganizationTeamRef> eligible = const []})
    : _eligible = eligible,
      super(
        tournamentId: 'tournament-1',
        currentUserId: 'owner-1',
        getTournamentUseCase: _UnusedGetTournamentUseCase(),
        getOrganizationUseCase: _UnusedGetOrganizationUseCase(),
        updateTournamentUseCase: _UnusedUpdateTournamentUseCase(),
        deleteTournamentUseCase: _UnusedDeleteTournamentUseCase(),
        enrollTournamentTeamUseCase: _UnusedEnrollTournamentTeamUseCase(),
        removeTournamentTeamUseCase: _UnusedRemoveTournamentTeamUseCase(),
      );

  final List<OrganizationTeamRef> _eligible;

  @override
  List<OrganizationTeamRef> get eligibleTeams => _eligible;

  String? enrolledTeamId;
  bool shouldSucceed = true;

  @override
  Future<bool> enrollTeam(String teamId) async {
    enrolledTeamId = teamId;
    return shouldSucceed;
  }
}

class _UnusedGetTournamentUseCase implements GetTournamentUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedGetOrganizationUseCase implements GetOrganizationUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedUpdateTournamentUseCase implements UpdateTournamentUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedDeleteTournamentUseCase implements DeleteTournamentUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedEnrollTournamentTeamUseCase implements EnrollTournamentTeamUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedRemoveTournamentTeamUseCase implements RemoveTournamentTeamUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  Future<void> pumpOpenButton(
    WidgetTester tester,
    _FakeTournamentDetailController controller,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showEnrollTeamSheet(controller: controller),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Future<void> tapAndAwaitSnackbar(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Future<void> drainSnackbar(WidgetTester tester) async {
    for (var i = 0; i < 220; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  testWidgets('an empty eligible list shows the no-eligible-teams message', (
    tester,
  ) async {
    final controller = _FakeTournamentDetailController(eligible: const []);

    await pumpOpenButton(tester, controller);

    expect(find.text('no_eligible_teams'), findsOneWidget);
  });

  testWidgets('tapping a team name enrolls it and shows a success snackbar', (
    tester,
  ) async {
    final controller = _FakeTournamentDetailController(
      eligible: [OrganizationTeamRef(id: 'team-2', name: 'Riverside U16')],
    );

    await pumpOpenButton(tester, controller);
    expect(find.text('Riverside U16'), findsOneWidget);

    await tapAndAwaitSnackbar(tester, find.text('Riverside U16'));

    expect(controller.enrolledTeamId, 'team-2');
    expect(find.text('team_enrolled'), findsOneWidget);
    await drainSnackbar(tester);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/tournament/presentation/widget/`
Expected: FAIL to compile — neither sheet file exists yet.

- [ ] **Step 3: Write the edit-tournament sheet**

Create `lib/features/tournament/presentation/widget/edit_tournament_sheet.dart`:

```dart
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/format_status_chips.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Renaming/re-formatting/re-statusing an existing tournament — a single
/// combined sheet, prefilled, mirroring `showAssignScorerSheet`'s
/// standalone-function shape.
Future<void> showEditTournamentSheet({
  required TournamentDetailController controller,
}) async {
  final tournament = controller.detail.value;
  if (tournament == null) return;

  final nameController = TextEditingController(text: tournament.name);
  var selectedFormat = tournament.format;
  var selectedStatus = tournament.status;

  final updated = await CustomBottomSheet.wrapBottomSheet<bool>(
    headlineText: TranslationKeys.editTournament.tr,
    child: StatefulBuilder(
      builder: (context, setSheetState) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CricketTextField(
              controller: nameController,
              hintText: TranslationKeys.tournamentName.tr,
              labelText: TranslationKeys.tournamentName.tr,
              prefixIcon: const Icon(Icons.emoji_events_outlined),
              isRequired: true,
            ),
            16.h,
            CricketText(text: TranslationKeys.format.tr),
            8.h,
            FormatChoiceChips(
              selected: selectedFormat,
              onSelected: (format) =>
                  setSheetState(() => selectedFormat = format),
            ),
            16.h,
            CricketText(text: TranslationKeys.status.tr),
            8.h,
            StatusChoiceChips(
              selected: selectedStatus,
              onSelected: (status) =>
                  setSheetState(() => selectedStatus = status),
            ),
            20.h,
            CricketButton(
              buttonText: TranslationKeys.save.tr,
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final success = await controller.updateTournament(
                  name: name,
                  format: selectedFormat,
                  status: selectedStatus,
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
      ),
    ),
  );

  if (updated == true) {
    CricketSnackbar.showSuccessMessage(TranslationKeys.tournamentUpdated.tr);
  }
}
```

- [ ] **Step 4: Write the enroll-team sheet**

Create `lib/features/tournament/presentation/widget/enroll_team_sheet.dart`:

```dart
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Tap-a-name team enrollment — mirrors `showAssignScorerSheet`'s pattern
/// exactly: list the eligible candidates, tapping one acts immediately and
/// closes the sheet.
Future<void> showEnrollTeamSheet({
  required TournamentDetailController controller,
}) async {
  final eligible = controller.eligibleTeams;
  if (eligible.isEmpty) {
    CricketSnackbar.showErrorMessage(TranslationKeys.noEligibleTeams.tr);
    return;
  }

  final enrolled = await CustomBottomSheet.wrapBottomSheet<bool>(
    headlineText: TranslationKeys.enrollTeam.tr,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final team in eligible)
            _EligibleTeamRow(
              team: team,
              onTap: () async {
                final success = await controller.enrollTeam(team.id);
                if (success) Get.back<bool>(result: true);
              },
            ),
        ],
      ),
    ),
  );

  if (enrolled == true) {
    CricketSnackbar.showSuccessMessage(TranslationKeys.teamEnrolled.tr);
  }
}

class _EligibleTeamRow extends StatelessWidget {
  const _EligibleTeamRow({required this.team, required this.onTap});

  final OrganizationTeamRef team;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: 8.radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: CricketText(
                  text: team.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.secondary,
                  ),
                ),
              ),
              if (team.shortName != null)
                CricketText(
                  text: team.shortName!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/features/tournament/presentation/widget/`
Expected: PASS — all tests in both files green.

- [ ] **Step 6: Return to Task 5 and run its analyzer step**

Run: `flutter analyze`
Expected: 0 issues (this confirms Task 5's screen now compiles against these two sheets).

- [ ] **Step 7: Commit**

```bash
git add lib/features/tournament/presentation/widget test/features/tournament/presentation/widget
git commit -m "feat: add edit-tournament and enroll-team bottom sheets"
```

---

### Task 7: Translation keys, values, and CMS upload

**Files:**
- Modify: `lib/core/translations/translation_keys.dart`
- Modify: `lib/core/translations/en.dart`
- Modify: `lib/core/translations/hi.dart`
- Modify: `lib/core/translations/mr.dart`

**Interfaces:**
- Produces: every `TranslationKeys.xxx` referenced by Tasks 3, 5, 6 above, now with real string values in all three languages, plus a live CMS record (Step 4) so a synced client renders them instead of raw keys.

- [ ] **Step 1: Add the key declarations**

In `lib/core/translations/translation_keys.dart`, add after the existing `currentScorer` line (the last line before the closing `}`):

```dart

  // Tournaments
  static const String tournaments = 'tournaments';
  static const String tournamentDetail = 'tournament_detail';
  static const String addTournament = 'add_tournament';
  static const String tournamentName = 'tournament_name';
  static const String tournamentCreated = 'tournament_created';
  static const String noTournamentsYet = 'no_tournaments_yet';
  static const String formatKnockout = 'format_knockout';
  static const String formatRoundRobin = 'format_round_robin';
  static const String formatLeague = 'format_league';
  static const String statusUpcoming = 'status_upcoming';
  static const String statusOngoing = 'status_ongoing';
  static const String statusCompleted = 'status_completed';
  static const String format = 'format';
  static const String status = 'status';
  static const String save = 'save';
  static const String editTournament = 'edit_tournament';
  static const String tournamentUpdated = 'tournament_updated';
  static const String deleteTournament = 'delete_tournament';
  static const String deleteTournamentConfirmTitle =
      'delete_tournament_confirm_title';
  static const String deleteTournamentConfirmMessage =
      'delete_tournament_confirm_message';
  static const String enrollTeam = 'enroll_team';
  static const String noEligibleTeams = 'no_eligible_teams';
  static const String teamEnrolled = 'team_enrolled';
  static const String noTeamsInTournament = 'no_teams_in_tournament';
  static const String removeTeam = 'remove_team';
  static const String removeTeamConfirmTitle = 'remove_team_confirm_title';
  static const String removeTeamConfirmMessage = 'remove_team_confirm_message';
  static const String teamRemovedFromTournament =
      'team_removed_from_tournament';
```

- [ ] **Step 2: Add English values**

In `lib/core/translations/en.dart`, add before the closing `};`:

```dart

  TranslationKeys.tournaments: 'Tournaments',
  TranslationKeys.tournamentDetail: 'Tournament',
  TranslationKeys.addTournament: 'Add tournament',
  TranslationKeys.tournamentName: 'Tournament name',
  TranslationKeys.tournamentCreated: 'Tournament created',
  TranslationKeys.noTournamentsYet: 'No tournaments yet',
  TranslationKeys.formatKnockout: 'Knockout',
  TranslationKeys.formatRoundRobin: 'Round robin',
  TranslationKeys.formatLeague: 'League',
  TranslationKeys.statusUpcoming: 'Upcoming',
  TranslationKeys.statusOngoing: 'Ongoing',
  TranslationKeys.statusCompleted: 'Completed',
  TranslationKeys.format: 'Format',
  TranslationKeys.status: 'Status',
  TranslationKeys.save: 'Save',
  TranslationKeys.editTournament: 'Edit tournament',
  TranslationKeys.tournamentUpdated: 'Tournament updated',
  TranslationKeys.deleteTournament: 'Delete tournament',
  TranslationKeys.deleteTournamentConfirmTitle: 'Delete this tournament?',
  TranslationKeys.deleteTournamentConfirmMessage:
      'This cannot be undone. Enrolled teams are not affected.',
  TranslationKeys.enrollTeam: 'Enroll team',
  TranslationKeys.noEligibleTeams:
      'Every team in this organization is already enrolled',
  TranslationKeys.teamEnrolled: 'Team enrolled',
  TranslationKeys.noTeamsInTournament: 'No teams enrolled yet',
  TranslationKeys.removeTeam: 'Remove team',
  TranslationKeys.removeTeamConfirmTitle: 'Remove this team?',
  TranslationKeys.removeTeamConfirmMessage:
      'The team can be enrolled again later.',
  TranslationKeys.teamRemovedFromTournament: 'Team removed from tournament',
```

- [ ] **Step 3: Add Hindi and Marathi values**

In `lib/core/translations/hi.dart`, add before the closing `};`:

```dart

  TranslationKeys.tournaments: 'टूर्नामेंट',
  TranslationKeys.tournamentDetail: 'टूर्नामेंट',
  TranslationKeys.addTournament: 'टूर्नामेंट जोड़ें',
  TranslationKeys.tournamentName: 'टूर्नामेंट का नाम',
  TranslationKeys.tournamentCreated: 'टूर्नामेंट बनाया गया',
  TranslationKeys.noTournamentsYet: 'अभी तक कोई टूर्नामेंट नहीं',
  TranslationKeys.formatKnockout: 'नॉकआउट',
  TranslationKeys.formatRoundRobin: 'राउंड रॉबिन',
  TranslationKeys.formatLeague: 'लीग',
  TranslationKeys.statusUpcoming: 'आगामी',
  TranslationKeys.statusOngoing: 'जारी',
  TranslationKeys.statusCompleted: 'समाप्त',
  TranslationKeys.format: 'प्रारूप',
  TranslationKeys.status: 'स्थिति',
  TranslationKeys.save: 'सहेजें',
  TranslationKeys.editTournament: 'टूर्नामेंट संपादित करें',
  TranslationKeys.tournamentUpdated: 'टूर्नामेंट अपडेट किया गया',
  TranslationKeys.deleteTournament: 'टूर्नामेंट हटाएं',
  TranslationKeys.deleteTournamentConfirmTitle: 'यह टूर्नामेंट हटाएं?',
  TranslationKeys.deleteTournamentConfirmMessage:
      'इसे पूर्ववत नहीं किया जा सकता। नामांकित टीमें प्रभावित नहीं होंगी।',
  TranslationKeys.enrollTeam: 'टीम जोड़ें',
  TranslationKeys.noEligibleTeams:
      'इस संगठन की सभी टीमें पहले से ही नामांकित हैं',
  TranslationKeys.teamEnrolled: 'टीम नामांकित हुई',
  TranslationKeys.noTeamsInTournament: 'अभी तक कोई टीम नामांकित नहीं',
  TranslationKeys.removeTeam: 'टीम हटाएं',
  TranslationKeys.removeTeamConfirmTitle: 'यह टीम हटाएं?',
  TranslationKeys.removeTeamConfirmMessage: 'टीम को बाद में फिर से जोड़ा जा सकता है।',
  TranslationKeys.teamRemovedFromTournament: 'टीम टूर्नामेंट से हटाई गई',
```

In `lib/core/translations/mr.dart`, add before the closing `};`:

```dart

  TranslationKeys.tournaments: 'स्पर्धा',
  TranslationKeys.tournamentDetail: 'स्पर्धा',
  TranslationKeys.addTournament: 'स्पर्धा जोडा',
  TranslationKeys.tournamentName: 'स्पर्धेचे नाव',
  TranslationKeys.tournamentCreated: 'स्पर्धा तयार झाली',
  TranslationKeys.noTournamentsYet: 'अजून कोणतीही स्पर्धा नाही',
  TranslationKeys.formatKnockout: 'नॉकआउट',
  TranslationKeys.formatRoundRobin: 'राउंड रॉबिन',
  TranslationKeys.formatLeague: 'लीग',
  TranslationKeys.statusUpcoming: 'आगामी',
  TranslationKeys.statusOngoing: 'सुरू',
  TranslationKeys.statusCompleted: 'पूर्ण',
  TranslationKeys.format: 'प्रकार',
  TranslationKeys.status: 'स्थिती',
  TranslationKeys.save: 'जतन करा',
  TranslationKeys.editTournament: 'स्पर्धा संपादित करा',
  TranslationKeys.tournamentUpdated: 'स्पर्धा अद्ययावत केली',
  TranslationKeys.deleteTournament: 'स्पर्धा हटवा',
  TranslationKeys.deleteTournamentConfirmTitle: 'ही स्पर्धा हटवायची?',
  TranslationKeys.deleteTournamentConfirmMessage:
      'हे पूर्ववत करता येणार नाही. नोंदणीकृत संघांवर परिणाम होणार नाही.',
  TranslationKeys.enrollTeam: 'संघ जोडा',
  TranslationKeys.noEligibleTeams: 'या संस्थेतील सर्व संघ आधीच नोंदणीकृत आहेत',
  TranslationKeys.teamEnrolled: 'संघ नोंदणीकृत झाला',
  TranslationKeys.noTeamsInTournament: 'अजून कोणताही संघ नोंदणीकृत नाही',
  TranslationKeys.removeTeam: 'संघ काढा',
  TranslationKeys.removeTeamConfirmTitle: 'हा संघ काढायचा?',
  TranslationKeys.removeTeamConfirmMessage: 'हा संघ नंतर पुन्हा जोडता येईल.',
  TranslationKeys.teamRemovedFromTournament: 'संघ स्पर्धेतून काढला',
```

- [ ] **Step 4: Run analyzer and the full test suite**

Run:
```bash
flutter analyze
flutter test
```
Expected: 0 analyzer issues, all tests passing (this is the point where every test written in Tasks 1–6 that referenced a `TranslationKeys` constant now has a real backing value, though the tests themselves already passed before this step since `.tr` degrades gracefully to the raw key in a bare widget test with no translations loaded — see the existing `assign_scorer_sheet_test.dart` comment on this).

- [ ] **Step 5: Upload to the CMS**

The workspace root `CLAUDE.md` states this is mandatory, not optional: `Get.addTranslations` merges at the language level, so any key missing from the CMS renders as the raw key once translations sync, even though it exists in `en.dart`. Ask the user whether the backend dev server (`cricket-scorer-backend`, `npm run dev`) is already running before this step — do not start it yourself (per this session's own standing instruction never to start/stop that server).

With the server running and a valid admin-authenticated access token (`verifyJwt` on `POST /api/v1/translations/bulk-update`), send one bulk-update call covering every key added in Steps 1–3, in the shape `[{key, translations: {en, hi, mr}}, ...]` — 27 entries, one per key above. Confirm success via the endpoint's own response, then spot-check `GET /api/v1/translations/all` includes at least `tournaments`/`enrollTeam` with all three language values populated.

- [ ] **Step 6: Commit**

```bash
git add lib/core/translations
git commit -m "feat: add Tournament translation keys (en/hi/mr) and CMS upload"
```

---

### Task 8: frontend-design pass

Once Tasks 1–7 are complete and functionally verified, invoke the `frontend-design` skill on the new Tournament UI surfaces: the Tournaments section + create sheet on `OrganizationDetailScreen`, `TournamentDetailScreen`, the edit-tournament sheet, and the enroll-team sheet. Ground it in the same visual vocabulary the delegated-scoring design pass used (`OrganizationDetailScreen`'s monogram/pill/bottom-sheet language) — this plan's own widget code above is functionally complete but written to match existing patterns mechanically, not aesthetically reviewed. Expect this pass to refine spacing, the format/status chip styling, and the tournament header layout without changing the underlying widget tree's data flow.

- [ ] **Step 1: Invoke `frontend-design`** on the four surfaces listed above, on branch `feat-tournament-ui` (created in Task 1), following that skill's plan → review-against-brief → implement process.
- [ ] **Step 2: Re-run `flutter analyze` and `flutter test`** after the design pass. Expected: 0 issues, all tests still passing (a pure visual pass should not break any controller/widget-behavior test written in Tasks 1–6; if it does, the test was asserting on presentation detail rather than behavior — fix the test, don't skip it).
- [ ] **Step 3: Commit** the design-pass changes separately from the mechanical implementation commits above.

---

### Task 9: On-device verification

- [ ] **Step 1**: Ask the user whether to use a physical device, an already-running emulator/simulator, or whether to boot one — per this session's own standing instruction, never boot a device without asking first. Also confirm the backend dev server is reachable from that device (LAN IP, not `localhost`, per the workspace root `CLAUDE.md`).
- [ ] **Step 2: Golden path** — as an org owner: open `OrganizationDetailScreen`, create a tournament, verify it appears in the Tournaments section with the right format/status pill, open its detail screen, edit its name/format/status via the edit sheet, enroll a team via the enroll sheet, remove that team, delete the tournament, confirm it's gone from the org's list.
- [ ] **Step 3: Negative case** — log in as a plain org member (not the owner) added via the existing "Add member" flow, open the same organization, confirm the "Add tournament" action is absent from the Tournaments section, open an existing tournament's detail screen, confirm the edit/delete app-bar icons and the "Enroll team" action are all absent — capture a screenshot as evidence, matching this project's own established bar for verifying client-side authorization display (not just trusting the already-tested backend).
- [ ] **Step 4**: Report the full test count (`flutter analyze` + `flutter test` output) and the on-device evidence before considering this plan complete.

---

## Self-Review Notes

- **Spec coverage**: every `AskUserQuestion` decision (placement, edit UI, picker style, enrollment UI, owner-determination via a second fetch, translation completeness) has a corresponding task. The pre-existing Organization translation gap is explicitly *not* touched, per the plan header.
- **Placeholder scan**: no TBD/TODO. Two spots are flagged as needing a live-codebase check rather than a placeholder value: (a) Task 1 Step 6's `UseCase` abstract-vs-concrete shape, which must match whatever `get_organization.dart` already does rather than guessing; (b) Task 1 Step 6's `ApiClient.patch(...)` signature, which must match whatever `updateTeamOrganization`'s existing repository call already uses. Both are called out explicitly as "confirm against the existing file before writing this" rather than silently assumed.
- **Type consistency**: `TournamentDetailRes`/`TournamentOrganizationRef`/`TournamentTeamRef` field names and nullability are used identically across the DTO (Task 1), the controller and its test (Task 4), the screen (Task 5), and both sheets (Task 6). `OrganizationTournamentRef`/`OrganizationDetailRes.tournaments` likewise match between Task 2's DTO change and Task 3's UI. The `UpdateTournamentReq`'s omit-null-fields `toJson()` is exercised directly by Task 4's controller test (`lastParams?.req.name, isNull`) rather than only asserted in a comment.
