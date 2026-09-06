# Tournament Fixtures UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Flutter/GetX UI for tournament fixture generation on top of the already-shipped backend (`cricket-scorer-backend`, merged to `development` at `c01f931`): a "Fixtures" section on `TournamentDetailScreen` that generates a schedule, displays it round-by-round, starts a scheduled fixture into the existing live-scoring flow, and lets the owner manually resolve a tied/no-result/abandoned fixture.

**Architecture:** Extends the existing Tournament feature's data layer (`TournamentEndpoint`/`TournamentApiService`/`TournamentRepository`) with four fixture methods rather than introducing a parallel Fixture-specific service — fixtures are tournament detail, the same way team-roster management already lives there. `TournamentDetailController` gains fixtures state and three action methods, none of which call `CricketSnackbar` directly (they return the specific backend message instead) — this keeps the controller testable with plain `test()` blocks the way its existing suite already is, since a GetX snackbar call needs a mounted navigator a bare unit test doesn't have. Two new bottom sheets (`start_fixture_match_sheet.dart`, `resolve_fixture_sheet.dart`) mirror this app's own existing sheet patterns exactly (`edit_tournament_sheet.dart`'s form-in-a-sheet shape; `enroll_team_sheet.dart`'s tap-a-name shape). Starting a fixture reuses the existing live-scoring screen untouched — `Get.toNamed(AppRoutes.scoreBall, arguments: CreateMatchRes)`, the exact call `CreateMatchController` already makes today.

**Tech Stack:** Flutter, GetX, `json_serializable`/`build_runner`, `flutter_test`.

**Spec:** `docs/api.md`'s `## Fixture` section (workspace root) is the backend contract this UI consumes — read it alongside this plan for exact field names, status values, and error codes. The design decisions behind this plan's screen layout were brainstormed and approved in chat (not written to a separate spec file, since this is a bounded extension of the already-built Tournament UI, not a new subsystem).

## Global Constraints

- GetX path-parameter routing stays as-is for `TournamentDetailScreen` — no new route or binding is needed; fixtures live on the tournament-detail screen that already exists.
- `TournamentDetailController`'s new methods must never call `CricketSnackbar` — return the message (or a small result type) and let the screen/sheet show it, so the existing plain-`test()`-block unit test suite keeps working unmodified in shape.
- Reuse existing translation keys wherever the English word is already used for the same concept elsewhere in this app (`overs`, `enterOvers`, `tossOptional`, `tossWinner`, `tossDecision`, `bat`, `bowl`, `statusCompleted`, `save`, `somethingWentWrong`, `retry`) — add new keys only for genuinely new UI strings, in all three of `en.dart`/`hi.dart`/`mr.dart` plus `translation_keys.dart`.
- Once fixtures exist for a tournament, `TournamentDetailScreen` hides the "Enroll team" action and the remove-team icons — mirroring the backend's roster lock (`409 TOURNAMENT_FIXTURES_LOCKED`) proactively rather than waiting for that error.

---

### Task 1: Fixture response model

**Files:**
- Create: `lib/features/tournament/data/models/response/fixture_res.dart`
- Test: `test/features/tournament/data/models/fixture_res_test.dart`

**Interfaces:**
- Produces: `FixtureTeamRef {id, name, shortName}`, `FixtureWinnerRef {id, name}`, `FixtureRes {id, round, order, teamA, teamB, isBye, status, winner, matchId}` — all `@JsonSerializable`. Every later task that touches a fixture uses this shape.

- [ ] **Step 1: Write the model and its generated part together**

Create `lib/features/tournament/data/models/response/fixture_res.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'fixture_res.g.dart';

/// A fixture's `teamA`/`teamB` — null for `teamB` only on a bye fixture.
@JsonSerializable()
class FixtureTeamRef {
  final String id;
  final String name;
  final String? shortName;

  FixtureTeamRef({required this.id, required this.name, this.shortName});

  factory FixtureTeamRef.fromJson(Map<String, dynamic> json) =>
      _$FixtureTeamRefFromJson(json);

  Map<String, dynamic> toJson() => _$FixtureTeamRefToJson(this);
}

/// A resolved fixture's winner — lighter than [FixtureTeamRef] (no
/// `shortName`), matching what `docs/api.md` actually returns for `winner`.
@JsonSerializable()
class FixtureWinnerRef {
  final String id;
  final String name;

  FixtureWinnerRef({required this.id, required this.name});

  factory FixtureWinnerRef.fromJson(Map<String, dynamic> json) =>
      _$FixtureWinnerRefFromJson(json);

  Map<String, dynamic> toJson() => _$FixtureWinnerRefToJson(this);
}

/// One row of `GET .../fixtures`' or `POST .../fixtures`' `fixtures` array —
/// see `docs/api.md`'s Fixture section.
@JsonSerializable(explicitToJson: true)
class FixtureRes {
  final String id;
  final int round;
  final int order;
  final FixtureTeamRef teamA;

  /// Null only when [isBye] is true.
  final FixtureTeamRef? teamB;
  final bool isBye;

  /// `scheduled` | `bye` | `completed` | `unresolved`.
  final String status;

  /// Null until the fixture resolves.
  final FixtureWinnerRef? winner;

  /// Null until `POST .../fixtures/:fixtureId/start-match` creates the
  /// real match for this fixture.
  final String? matchId;

  FixtureRes({
    required this.id,
    required this.round,
    required this.order,
    required this.teamA,
    this.teamB,
    required this.isBye,
    required this.status,
    this.winner,
    this.matchId,
  });

  factory FixtureRes.fromJson(Map<String, dynamic> json) =>
      _$FixtureResFromJson(json);

  Map<String, dynamic> toJson() => _$FixtureResToJson(this);
}
```

- [ ] **Step 2: Write the test**

Create `test/features/tournament/data/models/fixture_res_test.dart`:

```dart
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FixtureRes.fromJson parses a scheduled fixture with no winner', () {
    final json = {
      'id': 'fixture-1',
      'round': 1,
      'order': 0,
      'teamA': {'id': 'team-1', 'name': 'Harbor CC', 'shortName': 'HCC'},
      'teamB': {'id': 'team-2', 'name': 'Lakeside XI', 'shortName': null},
      'isBye': false,
      'status': 'scheduled',
      'winner': null,
      'matchId': null,
    };

    final fixture = FixtureRes.fromJson(json);

    expect(fixture.teamA.name, 'Harbor CC');
    expect(fixture.teamB?.name, 'Lakeside XI');
    expect(fixture.isBye, isFalse);
    expect(fixture.winner, isNull);
    expect(fixture.matchId, isNull);
  });

  test('FixtureRes.fromJson parses a bye fixture with teamB null', () {
    final json = {
      'id': 'fixture-2',
      'round': 1,
      'order': 1,
      'teamA': {'id': 'team-3', 'name': 'Riverside U19', 'shortName': null},
      'teamB': null,
      'isBye': true,
      'status': 'bye',
      'winner': {'id': 'team-3', 'name': 'Riverside U19'},
      'matchId': null,
    };

    final fixture = FixtureRes.fromJson(json);

    expect(fixture.teamB, isNull);
    expect(fixture.isBye, isTrue);
    expect(fixture.winner?.id, 'team-3');
  });

  test('FixtureRes.fromJson parses a completed fixture with a matchId', () {
    final json = {
      'id': 'fixture-3',
      'round': 1,
      'order': 2,
      'teamA': {'id': 'team-4', 'name': 'Eastgate CC', 'shortName': null},
      'teamB': {'id': 'team-5', 'name': 'Northside Warriors', 'shortName': null},
      'isBye': false,
      'status': 'completed',
      'winner': {'id': 'team-4', 'name': 'Eastgate CC'},
      'matchId': 'match-9',
    };

    final fixture = FixtureRes.fromJson(json);

    expect(fixture.status, 'completed');
    expect(fixture.winner?.name, 'Eastgate CC');
    expect(fixture.matchId, 'match-9');
  });
}
```

- [ ] **Step 3: Generate the `.g.dart` part and run the test**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/features/tournament/data/models/fixture_res_test.dart`
Expected: PASS, 3 tests

- [ ] **Step 4: Commit**

```bash
git add lib/features/tournament/data/models/response/fixture_res.dart lib/features/tournament/data/models/response/fixture_res.g.dart test/features/tournament/data/models/fixture_res_test.dart
git commit -m "feat: add FixtureRes response model"
```

---

### Task 2: Request models and data-layer methods

**Files:**
- Create: `lib/features/tournament/data/models/request/start_fixture_match_req.dart` (+ `.g.dart`)
- Create: `lib/features/tournament/data/models/request/resolve_fixture_req.dart` (+ `.g.dart`)
- Modify: `lib/features/tournament/data/tournament_endpoint.dart`
- Modify: `lib/features/tournament/data/data_sources/remote/tournament_api_service.dart`
- Modify: `lib/features/tournament/domain/repositories/tournament_repository.dart`
- Modify: `lib/features/tournament/data/repositories/tournament_repository_impl.dart`

**Interfaces:**
- Consumes: `FixtureRes` (Task 1).
- Produces: `TournamentRepository.generateFixtures/getFixtures/startFixtureMatch/resolveFixture` — Task 4's usecases call these by name with these exact parameter shapes.

- [ ] **Step 1: Write the request models**

Create `lib/features/tournament/data/models/request/start_fixture_match_req.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'start_fixture_match_req.g.dart';

@JsonSerializable(includeIfNull: false)
class StartFixtureMatchReq {
  final int totalOvers;

  /// `teamA` / `teamB`. Both this and [tossDecision] are either both null
  /// (toss skipped) or both set — the sheet enforces that before this ever
  /// gets built, matching `POST /v1/match`'s own rule.
  final String? tossWinner;

  /// `bat` / `bowl`.
  final String? tossDecision;

  StartFixtureMatchReq({
    required this.totalOvers,
    this.tossWinner,
    this.tossDecision,
  });

  factory StartFixtureMatchReq.fromJson(Map<String, dynamic> json) =>
      _$StartFixtureMatchReqFromJson(json);

  Map<String, dynamic> toJson() => _$StartFixtureMatchReqToJson(this);
}
```

Create `lib/features/tournament/data/models/request/resolve_fixture_req.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'resolve_fixture_req.g.dart';

@JsonSerializable()
class ResolveFixtureReq {
  final String winner;

  ResolveFixtureReq({required this.winner});

  factory ResolveFixtureReq.fromJson(Map<String, dynamic> json) =>
      _$ResolveFixtureReqFromJson(json);

  Map<String, dynamic> toJson() => _$ResolveFixtureReqToJson(this);
}
```

- [ ] **Step 2: Generate the `.g.dart` parts**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: Extend the endpoint class**

Modify `lib/features/tournament/data/tournament_endpoint.dart` — add four methods to the existing `TournamentEndpoint` class:

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

  String fixtures(String tournamentId) =>
      '/v1/tournament/$tournamentId/fixtures';

  String resolveFixture(String tournamentId, String fixtureId) =>
      '/v1/tournament/$tournamentId/fixtures/$fixtureId';

  String startFixtureMatch(String tournamentId, String fixtureId) =>
      '/v1/tournament/$tournamentId/fixtures/$fixtureId/start-match';
}
```

- [ ] **Step 4: Extend the API service**

Modify `lib/features/tournament/data/data_sources/remote/tournament_api_service.dart` — add the imports and four methods:

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/create_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/enroll_tournament_team_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/resolve_fixture_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/start_fixture_match_req.dart';
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

  Future<Either<ApiResponseModel, CricketFailure>> generateFixtures({
    required String tournamentId,
  }) async {
    return await apiClient.post(
      endpoint: tournamentEndpoint.fixtures(tournamentId),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> getFixtures({
    required String tournamentId,
  }) async {
    return await apiClient.get(
      endpoint: tournamentEndpoint.fixtures(tournamentId),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> startFixtureMatch({
    required String tournamentId,
    required String fixtureId,
    required StartFixtureMatchReq params,
  }) async {
    return await apiClient.post(
      endpoint: tournamentEndpoint.startFixtureMatch(tournamentId, fixtureId),
      data: params.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> resolveFixture({
    required String tournamentId,
    required String fixtureId,
    required ResolveFixtureReq params,
  }) async {
    return await apiClient.patch(
      endpoint: tournamentEndpoint.resolveFixture(tournamentId, fixtureId),
      data: params.toJson(),
    );
  }
}
```

- [ ] **Step 5: Extend the repository interface**

Modify `lib/features/tournament/domain/repositories/tournament_repository.dart` — add the import and four method signatures:

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/create_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/enroll_tournament_team_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/start_fixture_match_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
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

  /// `POST /v1/tournament/:tournamentId/fixtures` — owner-only. Generates
  /// the full schedule (round_robin/league) or the next round (knockout).
  Future<Either<CricketResponse<void>, CricketFailure>> generateFixtures({
    required String tournamentId,
  });

  /// `GET /v1/tournament/:tournamentId/fixtures` — any org member.
  Future<Either<CricketResponse<List<FixtureRes>>, CricketFailure>>
  getFixtures({required String tournamentId});

  /// `POST /v1/tournament/:tournamentId/fixtures/:fixtureId/start-match` —
  /// any org member. Returns the same shape `POST /v1/match` does.
  Future<Either<CricketResponse<CreateMatchRes>, CricketFailure>>
  startFixtureMatch({
    required String tournamentId,
    required String fixtureId,
    required StartFixtureMatchReq params,
  });

  /// `PATCH /v1/tournament/:tournamentId/fixtures/:fixtureId` — owner-only.
  Future<Either<CricketResponse<void>, CricketFailure>> resolveFixture({
    required String tournamentId,
    required String fixtureId,
    required ResolveFixtureReq params,
  });
}
```

- [ ] **Step 6: Extend the repository implementation**

Modify `lib/features/tournament/data/repositories/tournament_repository_impl.dart` — add the imports and four method bodies:

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/tournament/data/data_sources/remote/tournament_api_service.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/create_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/enroll_tournament_team_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/start_fixture_match_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/resolve_fixture_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
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

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> generateFixtures({
    required String tournamentId,
  }) async {
    final response = await tournamentApiService.generateFixtures(
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
  Future<Either<CricketResponse<List<FixtureRes>>, CricketFailure>>
  getFixtures({required String tournamentId}) async {
    final response = await tournamentApiService.getFixtures(
      tournamentId: tournamentId,
    );
    if (response.isResult) {
      final data = response.result.data as Map<String, dynamic>;
      final fixturesJson = data['fixtures'] as List<dynamic>;
      return Either.result(
        CricketResponse(
          data: fixturesJson
              .map((json) => FixtureRes.fromJson(json as Map<String, dynamic>))
              .toList(),
          message: response.result.message,
        ),
      );
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<CreateMatchRes>, CricketFailure>>
  startFixtureMatch({
    required String tournamentId,
    required String fixtureId,
    required StartFixtureMatchReq params,
  }) async {
    final response = await tournamentApiService.startFixtureMatch(
      tournamentId: tournamentId,
      fixtureId: fixtureId,
      params: params,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: CreateMatchRes.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> resolveFixture({
    required String tournamentId,
    required String fixtureId,
    required ResolveFixtureReq params,
  }) async {
    final response = await tournamentApiService.resolveFixture(
      tournamentId: tournamentId,
      fixtureId: fixtureId,
      params: params,
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

- [ ] **Step 7: Verify it compiles**

Run: `flutter analyze lib/features/tournament`
Expected: no errors (a repository/service/endpoint layer has no behavior of its own to unit-test beyond what Task 1's model test and Task 5's controller test already exercise through fakes)

- [ ] **Step 8: Commit**

```bash
git add lib/features/tournament/data/models/request/start_fixture_match_req.dart lib/features/tournament/data/models/request/start_fixture_match_req.g.dart lib/features/tournament/data/models/request/resolve_fixture_req.dart lib/features/tournament/data/models/request/resolve_fixture_req.g.dart lib/features/tournament/data/tournament_endpoint.dart lib/features/tournament/data/data_sources/remote/tournament_api_service.dart lib/features/tournament/domain/repositories/tournament_repository.dart lib/features/tournament/data/repositories/tournament_repository_impl.dart
git commit -m "feat: add fixture data-layer methods to the tournament repository"
```

---

### Task 3: Usecases and dependency injection

**Files:**
- Create: `lib/features/tournament/domain/usecases/generate_fixtures.dart`
- Create: `lib/features/tournament/domain/usecases/get_fixtures.dart`
- Create: `lib/features/tournament/domain/usecases/start_fixture_match.dart`
- Create: `lib/features/tournament/domain/usecases/resolve_fixture.dart`
- Modify: `lib/core/di/injection/tournament_injection.dart`

**Interfaces:**
- Consumes: `TournamentRepository`'s four new methods (Task 2).
- Produces: `GenerateFixturesUseCase`/`GenerateFixturesParams`, `GetFixturesUseCase`/`GetFixturesParams`, `StartFixtureMatchUseCase`/`StartFixtureMatchParams`, `ResolveFixtureUseCase`/`ResolveFixtureParams` — Task 5's controller constructor takes all four.

- [ ] **Step 1: Write the four usecases**

Create `lib/features/tournament/domain/usecases/generate_fixtures.dart`:

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class GenerateFixturesParams {
  final String tournamentId;

  GenerateFixturesParams({required this.tournamentId});
}

class GenerateFixturesUseCase
    implements
        UseCase<Either<CricketResponse<void>, CricketFailure>,
            GenerateFixturesParams> {
  final TournamentRepository tournamentRepository;

  GenerateFixturesUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    GenerateFixturesParams? params,
  }) {
    return tournamentRepository.generateFixtures(
      tournamentId: params!.tournamentId,
    );
  }
}
```

Create `lib/features/tournament/domain/usecases/get_fixtures.dart`:

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class GetFixturesParams {
  final String tournamentId;

  GetFixturesParams({required this.tournamentId});
}

class GetFixturesUseCase
    implements
        UseCase<Either<CricketResponse<List<FixtureRes>>, CricketFailure>,
            GetFixturesParams> {
  final TournamentRepository tournamentRepository;

  GetFixturesUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<List<FixtureRes>>, CricketFailure>> call({
    GetFixturesParams? params,
  }) {
    return tournamentRepository.getFixtures(tournamentId: params!.tournamentId);
  }
}
```

Create `lib/features/tournament/domain/usecases/start_fixture_match.dart`:

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/start_fixture_match_req.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class StartFixtureMatchParams {
  final String tournamentId;
  final String fixtureId;
  final int totalOvers;
  final String? tossWinner;
  final String? tossDecision;

  StartFixtureMatchParams({
    required this.tournamentId,
    required this.fixtureId,
    required this.totalOvers,
    this.tossWinner,
    this.tossDecision,
  });
}

class StartFixtureMatchUseCase
    implements
        UseCase<Either<CricketResponse<CreateMatchRes>, CricketFailure>,
            StartFixtureMatchParams> {
  final TournamentRepository tournamentRepository;

  StartFixtureMatchUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<CreateMatchRes>, CricketFailure>> call({
    StartFixtureMatchParams? params,
  }) {
    return tournamentRepository.startFixtureMatch(
      tournamentId: params!.tournamentId,
      fixtureId: params.fixtureId,
      params: StartFixtureMatchReq(
        totalOvers: params.totalOvers,
        tossWinner: params.tossWinner,
        tossDecision: params.tossDecision,
      ),
    );
  }
}
```

Create `lib/features/tournament/domain/usecases/resolve_fixture.dart`:

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/resolve_fixture_req.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class ResolveFixtureParams {
  final String tournamentId;
  final String fixtureId;
  final String winnerTeamId;

  ResolveFixtureParams({
    required this.tournamentId,
    required this.fixtureId,
    required this.winnerTeamId,
  });
}

class ResolveFixtureUseCase
    implements
        UseCase<Either<CricketResponse<void>, CricketFailure>,
            ResolveFixtureParams> {
  final TournamentRepository tournamentRepository;

  ResolveFixtureUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    ResolveFixtureParams? params,
  }) {
    return tournamentRepository.resolveFixture(
      tournamentId: params!.tournamentId,
      fixtureId: params.fixtureId,
      params: ResolveFixtureReq(winner: params.winnerTeamId),
    );
  }
}
```

- [ ] **Step 2: Wire dependency injection**

Modify `lib/core/di/injection/tournament_injection.dart` — add the four imports and four `Get.lazyPut` registrations:

```dart
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/features/tournament/data/data_sources/remote/tournament_api_service.dart';
import 'package:cricket_scorer/features/tournament/data/tournament_endpoint.dart';
import 'package:cricket_scorer/features/tournament/data/repositories/tournament_repository_impl.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/create_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/generate_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resolve_fixture.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_fixture_match.dart';
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
      () => CreateTournamentUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetTournamentUseCase>(
      () => GetTournamentUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<UpdateTournamentUseCase>(
      () => UpdateTournamentUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<DeleteTournamentUseCase>(
      () => DeleteTournamentUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<EnrollTournamentTeamUseCase>(
      () => EnrollTournamentTeamUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<RemoveTournamentTeamUseCase>(
      () => RemoveTournamentTeamUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GenerateFixturesUseCase>(
      () => GenerateFixturesUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetFixturesUseCase>(
      () => GetFixturesUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<StartFixtureMatchUseCase>(
      () => StartFixtureMatchUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ResolveFixtureUseCase>(
      () => ResolveFixtureUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );
  }
}
```

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze lib/features/tournament lib/core/di`
Expected: no errors

- [ ] **Step 4: Commit**

```bash
git add lib/features/tournament/domain/usecases/generate_fixtures.dart lib/features/tournament/domain/usecases/get_fixtures.dart lib/features/tournament/domain/usecases/start_fixture_match.dart lib/features/tournament/domain/usecases/resolve_fixture.dart lib/core/di/injection/tournament_injection.dart
git commit -m "feat: add fixture usecases and wire dependency injection"
```

---

### Task 4: Fixture status labels and locale keys

**Files:**
- Create: `lib/features/tournament/presentation/widget/fixture_status_chip.dart`
- Modify: `lib/core/translations/translation_keys.dart`
- Modify: `lib/core/translations/en.dart`
- Modify: `lib/core/translations/hi.dart`
- Modify: `lib/core/translations/mr.dart`

**Interfaces:**
- Produces: `fixtureStatusLabel(String status): String`, `fixtureStatusColor(BuildContext, String status): Color` — Task 6's fixture row uses both.

- [ ] **Step 1: Add the new translation keys**

Modify `lib/core/translations/translation_keys.dart` — add these constants near the existing Tournament section (after `teamRemovedFromTournament`):

```dart
  static const String fixtures = 'fixtures';
  static const String generateFixtures = 'generate_fixtures';
  static const String generateNextRound = 'generate_next_round';
  static const String noFixturesYet = 'no_fixtures_yet';
  static const String round = 'round';
  static const String byeLabel = 'bye_label';
  static const String fixtureStatusScheduled = 'fixture_status_scheduled';
  static const String fixtureStatusUnresolved = 'fixture_status_unresolved';
  static const String startMatch = 'start_match';
  static const String declareWinner = 'declare_winner';
  static const String vsLabel = 'vs_label';
  static const String fixturesGenerated = 'fixtures_generated';
  static const String fixtureResolved = 'fixture_resolved';
```

- [ ] **Step 2: Add English values**

Modify `lib/core/translations/en.dart` — add near the existing Tournament block (after `TranslationKeys.teamRemovedFromTournament`'s entry):

```dart
  TranslationKeys.fixtures: 'Fixtures',
  TranslationKeys.generateFixtures: 'Generate fixtures',
  TranslationKeys.generateNextRound: 'Generate next round',
  TranslationKeys.noFixturesYet: 'No fixtures yet',
  TranslationKeys.round: 'Round',
  TranslationKeys.byeLabel: 'Bye',
  TranslationKeys.fixtureStatusScheduled: 'Scheduled',
  TranslationKeys.fixtureStatusUnresolved: 'Unresolved',
  TranslationKeys.startMatch: 'Start match',
  TranslationKeys.declareWinner: 'Declare winner',
  TranslationKeys.vsLabel: 'vs',
  TranslationKeys.fixturesGenerated: 'Fixtures generated',
  TranslationKeys.fixtureResolved: 'Fixture resolved',
```

- [ ] **Step 3: Add Hindi values**

Modify `lib/core/translations/hi.dart` — add the same keys in the same location:

```dart
  TranslationKeys.fixtures: 'फिक्स्चर',
  TranslationKeys.generateFixtures: 'फिक्स्चर बनाएं',
  TranslationKeys.generateNextRound: 'अगला राउंड बनाएं',
  TranslationKeys.noFixturesYet: 'अभी तक कोई फिक्स्चर नहीं',
  TranslationKeys.round: 'राउंड',
  TranslationKeys.byeLabel: 'बाई',
  TranslationKeys.fixtureStatusScheduled: 'निर्धारित',
  TranslationKeys.fixtureStatusUnresolved: 'अनिर्णीत',
  TranslationKeys.startMatch: 'मैच शुरू करें',
  TranslationKeys.declareWinner: 'विजेता घोषित करें',
  TranslationKeys.vsLabel: 'बनाम',
  TranslationKeys.fixturesGenerated: 'फिक्स्चर बनाए गए',
  TranslationKeys.fixtureResolved: 'फिक्स्चर तय किया गया',
```

- [ ] **Step 4: Add Marathi values**

Modify `lib/core/translations/mr.dart` — add the same keys in the same location:

```dart
  TranslationKeys.fixtures: 'फिक्स्चर',
  TranslationKeys.generateFixtures: 'फिक्स्चर तयार करा',
  TranslationKeys.generateNextRound: 'पुढील फेरी तयार करा',
  TranslationKeys.noFixturesYet: 'अजून फिक्स्चर नाहीत',
  TranslationKeys.round: 'फेरी',
  TranslationKeys.byeLabel: 'बाय',
  TranslationKeys.fixtureStatusScheduled: 'नियोजित',
  TranslationKeys.fixtureStatusUnresolved: 'अनिर्णित',
  TranslationKeys.startMatch: 'सामना सुरू करा',
  TranslationKeys.declareWinner: 'विजेता जाहीर करा',
  TranslationKeys.vsLabel: 'विरुद्ध',
  TranslationKeys.fixturesGenerated: 'फिक्स्चर तयार झाले',
  TranslationKeys.fixtureResolved: 'फिक्स्चर निकाली काढला',
```

- [ ] **Step 5: Write the status label/color helpers**

Create `lib/features/tournament/presentation/widget/fixture_status_chip.dart`:

```dart
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// `scheduled` reuses no existing label (fixtures are the only thing with
/// this exact status); `completed` reuses the same English word every other
/// completed-thing label in this app already uses
/// (`TranslationKeys.statusCompleted`) rather than a redundant fixture-only
/// key for an identical string.
String fixtureStatusLabel(String status) => switch (status) {
  'scheduled' => TranslationKeys.fixtureStatusScheduled.tr,
  'bye' => TranslationKeys.byeLabel.tr,
  'completed' => TranslationKeys.statusCompleted.tr,
  'unresolved' => TranslationKeys.fixtureStatusUnresolved.tr,
  _ => status,
};

/// `unresolved` draws on `statusDanger` — the one fixture state that needs
/// the owner's attention (a tie, no-result, or abandonment nothing else in
/// this app resolves automatically). `bye` gets no color of its own; it's
/// informational, not a state anyone acts on.
Color fixtureStatusColor(BuildContext context, String status) =>
    switch (status) {
      'scheduled' => context.colors.statusInfo,
      'completed' => context.colors.statusSuccess,
      'unresolved' => context.colors.statusDanger,
      _ => context.colorScheme.onSurfaceVariant,
    };
```

- [ ] **Step 6: Verify it compiles**

Run: `flutter analyze lib/features/tournament lib/core/translations`
Expected: no errors

- [ ] **Step 7: Commit**

```bash
git add lib/features/tournament/presentation/widget/fixture_status_chip.dart lib/core/translations/translation_keys.dart lib/core/translations/en.dart lib/core/translations/hi.dart lib/core/translations/mr.dart
git commit -m "feat: add fixture status labels and translations"
```

---

### Task 5: Controller — fixtures state and actions

**Files:**
- Modify: `lib/features/tournament/presentation/controllers/tournament_detail_controller.dart`
- Modify: `lib/features/tournament/presentation/bindings/tournament_detail_binding.dart`
- Modify: `test/features/tournament/presentation/controllers/tournament_detail_controller_test.dart`

**Interfaces:**
- Consumes: `GetFixturesUseCase`, `GenerateFixturesUseCase`, `StartFixtureMatchUseCase`, `ResolveFixtureUseCase` (Task 3).
- Produces: `TournamentDetailController.fixtures` (`RxList<FixtureRes>`), `.latestRoundFixtures`, `.canGenerateNextRound`, `.fixturesGenerated`, `.generateFixtures()`, `.startFixtureMatch(...)`, `.resolveFixture(...)`, and the `StartFixtureMatchOutcome` result type. Task 6/7/8's UI reads all of these.

- [ ] **Step 1: Write the controller changes**

Modify `lib/features/tournament/presentation/controllers/tournament_detail_controller.dart` — full replacement:

```dart
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/generate_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resolve_fixture.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_fixture_match.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/update_tournament.dart';
import 'package:get/get.dart';

/// Returned by [TournamentDetailController.startFixtureMatch] — carries
/// either the created match (for the sheet to navigate on) or the specific
/// backend error message (for the sheet to show), never both.
class StartFixtureMatchOutcome {
  final CreateMatchRes? match;
  final String? errorMessage;

  const StartFixtureMatchOutcome.success(this.match) : errorMessage = null;

  const StartFixtureMatchOutcome.failure(this.errorMessage) : match = null;
}

/// One tournament's detail plus the owning organization's own detail — the
/// latter fetched purely to answer "is the viewer the owner" and "which of
/// this org's teams aren't enrolled yet," since
/// `GET /v1/tournament/:tournamentId` itself returns neither (see
/// docs/api.md — it only returns `organization: {id, name}`, no owner).
///
/// None of this controller's methods call `CricketSnackbar` directly —
/// a GetX snackbar needs a mounted navigator, which a plain `test()` block
/// (as opposed to `testWidgets()`) doesn't have. Every action instead
/// returns the specific backend message (or a small result type carrying
/// one) and leaves showing it to the screen/sheet that called it.
class TournamentDetailController extends GetxController {
  final String tournamentId;
  final String currentUserId;

  final GetTournamentUseCase getTournamentUseCase;
  final GetOrganizationUseCase getOrganizationUseCase;
  final UpdateTournamentUseCase updateTournamentUseCase;
  final DeleteTournamentUseCase deleteTournamentUseCase;
  final EnrollTournamentTeamUseCase enrollTournamentTeamUseCase;
  final RemoveTournamentTeamUseCase removeTournamentTeamUseCase;
  final GetFixturesUseCase getFixturesUseCase;
  final GenerateFixturesUseCase generateFixturesUseCase;
  final StartFixtureMatchUseCase startFixtureMatchUseCase;
  final ResolveFixtureUseCase resolveFixtureUseCase;

  TournamentDetailController({
    required this.tournamentId,
    required this.currentUserId,
    required this.getTournamentUseCase,
    required this.getOrganizationUseCase,
    required this.updateTournamentUseCase,
    required this.deleteTournamentUseCase,
    required this.enrollTournamentTeamUseCase,
    required this.removeTournamentTeamUseCase,
    required this.getFixturesUseCase,
    required this.generateFixturesUseCase,
    required this.startFixtureMatchUseCase,
    required this.resolveFixtureUseCase,
  });

  final detail = Rxn<TournamentDetailRes>();
  final organizationDetail = Rxn<OrganizationDetailRes>();
  final isLoading = true.obs;
  final loadError = Rxn<String>();
  final fixtures = <FixtureRes>[].obs;

  bool get isOwner => organizationDetail.value?.owner.id == currentUserId;

  /// The org's teams not already enrolled in this tournament — the source
  /// list for the "Enroll team" sheet.
  List<OrganizationTeamRef> get eligibleTeams {
    final orgTeams = organizationDetail.value?.teams ?? const [];
    final enrolledIds = detail.value?.teams.map((t) => t.id).toSet() ?? const {};
    return orgTeams.where((t) => !enrolledIds.contains(t.id)).toList();
  }

  /// Once any fixture exists, the backend locks the roster
  /// (`TOURNAMENT_FIXTURES_LOCKED`) — the screen hides enroll/remove
  /// actions to match, rather than surfacing that as an error.
  bool get fixturesGenerated => fixtures.isNotEmpty;

  int get _maxFixtureRound =>
      fixtures.isEmpty ? 0 : fixtures.map((f) => f.round).reduce((a, b) => a > b ? a : b);

  List<FixtureRes> get latestRoundFixtures =>
      fixtures.where((f) => f.round == _maxFixtureRound).toList();

  /// True only for a knockout whose current round is fully resolved and
  /// isn't already the final (a 1-fixture round) — the one case
  /// `POST .../fixtures` can be called again. round_robin/league generate
  /// their whole schedule in one call and are never re-callable.
  bool get canGenerateNextRound {
    if (detail.value?.format != 'knockout') return false;
    if (fixtures.isEmpty) return false;
    final latest = latestRoundFixtures;
    if (latest.length <= 1) return false;
    return latest.every((f) => f.status == 'bye' || f.status == 'completed');
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

    await _loadFixtures();

    isLoading.value = false;
  }

  Future<void> _loadFixtures() async {
    final response = await getFixturesUseCase(
      params: GetFixturesParams(tournamentId: tournamentId),
    );
    if (response.isResult) {
      fixtures.assignAll(response.result.data!);
    }
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

  /// Returns null on success, the backend's specific error message
  /// otherwise (e.g. "Not enough teams enrolled...", "Every fixture in the
  /// current round must be resolved...") — these are meaningful business
  /// rules the scorer needs to see verbatim, not a generic failure.
  Future<String?> generateFixtures() async {
    final response = await generateFixturesUseCase(
      params: GenerateFixturesParams(tournamentId: tournamentId),
    );
    if (!response.isResult) return response.fallback.message;
    await _loadFixtures();
    return null;
  }

  Future<StartFixtureMatchOutcome> startFixtureMatch(
    String fixtureId, {
    required int totalOvers,
    String? tossWinner,
    String? tossDecision,
  }) async {
    final response = await startFixtureMatchUseCase(
      params: StartFixtureMatchParams(
        tournamentId: tournamentId,
        fixtureId: fixtureId,
        totalOvers: totalOvers,
        tossWinner: tossWinner,
        tossDecision: tossDecision,
      ),
    );
    if (!response.isResult) {
      return StartFixtureMatchOutcome.failure(response.fallback.message);
    }
    await _loadFixtures();
    return StartFixtureMatchOutcome.success(response.result.data);
  }

  Future<String?> resolveFixture(String fixtureId, String winnerTeamId) async {
    final response = await resolveFixtureUseCase(
      params: ResolveFixtureParams(
        tournamentId: tournamentId,
        fixtureId: fixtureId,
        winnerTeamId: winnerTeamId,
      ),
    );
    if (!response.isResult) return response.fallback.message;
    await _loadFixtures();
    return null;
  }
}
```

- [ ] **Step 2: Wire the new usecases into the binding**

Modify `lib/features/tournament/presentation/bindings/tournament_detail_binding.dart` — the current file only imports `GetOrganizationUseCase` from the organization feature (no other organization usecases), so add just the four new tournament usecase imports and constructor args:

```dart
import 'package:cricket_scorer/core/utils/current_user.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/generate_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resolve_fixture.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_fixture_match.dart';
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
        getFixturesUseCase: Get.find<GetFixturesUseCase>(),
        generateFixturesUseCase: Get.find<GenerateFixturesUseCase>(),
        startFixtureMatchUseCase: Get.find<StartFixtureMatchUseCase>(),
        resolveFixtureUseCase: Get.find<ResolveFixtureUseCase>(),
      ),
      tag: tournamentId,
    );
  }
}
```

- [ ] **Step 2b: Update the two existing tests that subclass `TournamentDetailController` directly**

`TournamentDetailController`'s constructor now takes four more required named parameters. `test/features/tournament/presentation/widget/edit_tournament_sheet_test.dart` and `test/features/tournament/presentation/widget/enroll_team_sheet_test.dart` both define a `_FakeTournamentDetailController extends TournamentDetailController` with a fixed 6-argument `super(...)` call using `_Unused*UseCase` no-op fakes — both will fail to compile once Task 5's Step 1 lands. In **both** files:

Add these four imports alongside the existing ones:

```dart
import 'package:cricket_scorer/features/tournament/domain/usecases/generate_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resolve_fixture.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_fixture_match.dart';
```

Add these four no-op fake classes alongside the existing `_Unused*UseCase` ones:

```dart
class _UnusedGetFixturesUseCase implements GetFixturesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedGenerateFixturesUseCase implements GenerateFixturesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedStartFixtureMatchUseCase implements StartFixtureMatchUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedResolveFixtureUseCase implements ResolveFixtureUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
```

And extend the `_FakeTournamentDetailController`'s `super(...)` call in both files with:

```dart
        getFixturesUseCase: _UnusedGetFixturesUseCase(),
        generateFixturesUseCase: _UnusedGenerateFixturesUseCase(),
        startFixtureMatchUseCase: _UnusedStartFixtureMatchUseCase(),
        resolveFixtureUseCase: _UnusedResolveFixtureUseCase(),
```

(right after the existing `removeTournamentTeamUseCase: _UnusedRemoveTournamentTeamUseCase(),` line, before the closing `);` of the constructor call — in `enroll_team_sheet_test.dart` this is inside the `super(...)` positional block ending at line 28; in `edit_tournament_sheet_test.dart` it's the block ending at line 30, immediately before the `) {` that opens the constructor body setting `detail.value`).

- [ ] **Step 3: Extend the controller test with fakes for the four new usecases**

Modify `test/features/tournament/presentation/controllers/tournament_detail_controller_test.dart` — add four fake usecase classes (same shape as the existing `_FakeCreateTournamentUseCase`) and wire them into every `TournamentDetailController(...)` construction in the file, then add new tests. The full new/changed content:

Add these imports at the top, alongside the existing ones:

```dart
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/generate_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resolve_fixture.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_fixture_match.dart';
```

Add these four fake classes, alongside the existing `_FakeCreateTournamentUseCase`:

```dart
class _FakeGetFixturesUseCase implements GetFixturesUseCase {
  Either<CricketResponse<List<FixtureRes>>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<List<FixtureRes>>, CricketFailure>> call({
    GetFixturesParams? params,
  }) async {
    final result = response;
    if (result == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeGenerateFixturesUseCase implements GenerateFixturesUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    GenerateFixturesParams? params,
  }) async {
    final result = response;
    if (result == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeStartFixtureMatchUseCase implements StartFixtureMatchUseCase {
  Either<CricketResponse<CreateMatchRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<CreateMatchRes>, CricketFailure>> call({
    StartFixtureMatchParams? params,
  }) async {
    final result = response;
    if (result == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeResolveFixtureUseCase implements ResolveFixtureUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    ResolveFixtureParams? params,
  }) async {
    final result = response;
    if (result == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}
```

In `main()`, declare the four new fakes alongside the existing `late` declarations, construct them in `setUp`, and pass them into every `OrganizationDetailController`/`TournamentDetailController(...)` — wait, this file constructs `TournamentDetailController`, not `OrganizationDetailController` (that's a different test file also touched in the earlier Tournament UI phase) — pass the four new fakes into every `TournamentDetailController(...)` construction in this file:

```dart
  late _FakeGetFixturesUseCase getFixturesUseCase;
  late _FakeGenerateFixturesUseCase generateFixturesUseCase;
  late _FakeStartFixtureMatchUseCase startFixtureMatchUseCase;
  late _FakeResolveFixtureUseCase resolveFixtureUseCase;
```

```dart
    getFixturesUseCase = _FakeGetFixturesUseCase()
      ..response = Either.result(
        CricketResponse(message: 'ok', data: const <FixtureRes>[]),
      );
    generateFixturesUseCase = _FakeGenerateFixturesUseCase();
    startFixtureMatchUseCase = _FakeStartFixtureMatchUseCase();
    resolveFixtureUseCase = _FakeResolveFixtureUseCase();
```

Setting a default empty-list response on `getFixturesUseCase` directly in `setUp` (rather than per-test) means every existing test's `loadDetail()` call — which now also calls `_loadFixtures()` — keeps working unchanged, since `_loadFixtures()` needs *some* response or it throws `UnimplementedError`. Then add `getFixturesUseCase: getFixturesUseCase, generateFixturesUseCase: generateFixturesUseCase, startFixtureMatchUseCase: startFixtureMatchUseCase, resolveFixtureUseCase: resolveFixtureUseCase,` to the two `TournamentDetailController(...)` constructions already in the file (the one in `setUp` and the one in the `'isOwner is false for a member viewer'` test).

Then append these new tests at the end of `main()`, before the closing `});`:

```dart
  test('loadDetail also populates fixtures', () async {
    getOrganizationUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _detail()),
    );
    getFixturesUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: [
          FixtureRes(
            id: 'fixture-1',
            round: 1,
            order: 0,
            teamA: FixtureTeamRef(id: 'team-1', name: 'Harbor CC'),
            teamB: FixtureTeamRef(id: 'team-2', name: 'Lakeside XI'),
            isBye: false,
            status: 'scheduled',
          ),
        ],
      ),
    );

    await controller.loadDetail();

    expect(controller.fixtures.length, 1);
    expect(controller.fixturesGenerated, isTrue);
  });

  test('generateFixtures returns null and refreshes fixtures on success', () async {
    getOrganizationUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _detail()),
    );
    await controller.loadDetail();

    generateFixturesUseCase.response = Either.result(
      const CricketResponse(message: 'ok', data: null),
    );
    getFixturesUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: [
          FixtureRes(
            id: 'fixture-1',
            round: 1,
            order: 0,
            teamA: FixtureTeamRef(id: 'team-1', name: 'Harbor CC'),
            teamB: FixtureTeamRef(id: 'team-2', name: 'Lakeside XI'),
            isBye: false,
            status: 'scheduled',
          ),
        ],
      ),
    );

    final errorMessage = await controller.generateFixtures();

    expect(errorMessage, isNull);
    expect(controller.fixtures.length, 1);
  });

  test('generateFixtures returns the backend message on failure', () async {
    generateFixturesUseCase.response = Either.fallback(
      CricketBadRequestFailure(
        statusCode: 400,
        message: 'Not enough teams enrolled for this tournament\'s format',
      ),
    );

    final errorMessage = await controller.generateFixtures();

    expect(errorMessage, 'Not enough teams enrolled for this tournament\'s format');
    expect(controller.fixtures, isEmpty);
  });

  test('startFixtureMatch returns a success outcome with the created match', () async {
    startFixtureMatchUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: CreateMatchRes(
          matchId: 'match-1',
          joinCode: 'ABC123',
          teamA: TeamRef(id: 'team-1', name: 'Harbor CC'),
          teamB: TeamRef(id: 'team-2', name: 'Lakeside XI'),
          totalOvers: 20,
          status: 'upcoming',
          syncStatus: 'local',
          createdAt: '2026-09-06T10:00:00.000Z',
        ),
      ),
    );
    getFixturesUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: const <FixtureRes>[]),
    );

    final outcome = await controller.startFixtureMatch(
      'fixture-1',
      totalOvers: 20,
    );

    expect(outcome.errorMessage, isNull);
    expect(outcome.match?.matchId, 'match-1');
  });

  test('startFixtureMatch returns a failure outcome with the backend message', () async {
    startFixtureMatchUseCase.response = Either.fallback(
      CricketConflictFailure(statusCode: 409, message: 'This fixture already has a match'),
    );

    final outcome = await controller.startFixtureMatch(
      'fixture-1',
      totalOvers: 20,
    );

    expect(outcome.match, isNull);
    expect(outcome.errorMessage, 'This fixture already has a match');
  });

  test('resolveFixture returns null and refreshes fixtures on success', () async {
    resolveFixtureUseCase.response = Either.result(
      const CricketResponse(message: 'ok', data: null),
    );
    getFixturesUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: const <FixtureRes>[]),
    );

    final errorMessage = await controller.resolveFixture('fixture-1', 'team-1');

    expect(errorMessage, isNull);
  });
```

- [ ] **Step 4: Run the tests**

Run: `flutter test test/features/tournament/presentation/controllers/tournament_detail_controller_test.dart`
Expected: PASS, all tests (existing + 6 new)

- [ ] **Step 5: Run the wider test suite to confirm nothing else broke**

Run: `flutter analyze`
Run: `flutter test`
Expected: 0 analyzer issues; every test passes (the `OrganizationDetailController`/`OrganizationsListController`/`OrganizationDetailRes` tests from the earlier Tournament UI phase are untouched by this task and should be unaffected)

- [ ] **Step 6: Commit**

```bash
git add lib/features/tournament/presentation/controllers/tournament_detail_controller.dart lib/features/tournament/presentation/bindings/tournament_detail_binding.dart test/features/tournament/presentation/controllers/tournament_detail_controller_test.dart test/features/tournament/presentation/widget/edit_tournament_sheet_test.dart test/features/tournament/presentation/widget/enroll_team_sheet_test.dart
git commit -m "feat: add fixtures state and actions to TournamentDetailController"
```

---

### Task 6: Fixtures section on TournamentDetailScreen

**Files:**
- Modify: `lib/features/tournament/presentation/pages/tournament_detail_screen.dart`

**Interfaces:**
- Consumes: `TournamentDetailController.fixtures`/`latestRoundFixtures`/`canGenerateNextRound`/`fixturesGenerated`/`generateFixtures()` (Task 5), `fixtureStatusLabel`/`fixtureStatusColor` (Task 4). Calls `showStartFixtureMatchSheet`/`showResolveFixtureSheet` — written in Task 7/8, so this task's fixture-row action callbacks reference functions that don't exist until then; write this task's code exactly as shown (it will not compile standalone) and treat Tasks 6-8 as one compile-and-test unit, running `flutter analyze`/`flutter test` only after Task 8's Step is done, not after this task alone. Note this explicitly in the commit for this task's step (skip the "verify it compiles" step here and do it once at the end of Task 8 instead).

- [ ] **Step 1: Add the Fixtures section and supporting row/widgets**

Modify `lib/features/tournament/presentation/pages/tournament_detail_screen.dart` — this is a full replacement of the file:

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
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/enroll_team_sheet.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/edit_tournament_sheet.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/format_status_chips.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/fixture_status_chip.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/resolve_fixture_sheet.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/start_fixture_match_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A tournament's detail plus its enrolled-team roster and fixture
/// schedule — reached by tapping a tournament row on
/// `OrganizationDetailScreen`. Shares that screen's and `TeamProfileScreen`'s
/// section/row vocabulary.
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

  Future<void> _generateFixtures() async {
    final errorMessage = await controller.generateFixtures();
    if (errorMessage == null) {
      CricketSnackbar.showSuccessMessage(TranslationKeys.fixturesGenerated.tr);
    } else {
      CricketSnackbar.showErrorMessage(errorMessage);
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A tournament isn't a person or a team, so it gets no
                    // monogram — unlike OrganizationDetailScreen's and
                    // TeamProfileScreen's initials avatars, this circle
                    // carries a representative icon instead. Same size and
                    // background token as those avatars, so the header still
                    // reads as the same family of screen.
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: context.colors.chipBackground,
                      child: Icon(
                        Icons.emoji_events_outlined,
                        color: context.colorScheme.primary,
                        size: 26,
                      ),
                    ),
                    16.w,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CricketText(
                            text: data.name,
                            style: context.textTheme.headlineSmall?.copyWith(
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                          4.h,
                          CricketText(
                            text: data.organization.name,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                12.h,
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
                24.h,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CricketText(
                      text: TranslationKeys.teams.tr,
                      style: context.textTheme.titleSmall,
                    ),
                    if (controller.isOwner && !controller.fixturesGenerated)
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
                      canRemove: controller.isOwner && !controller.fixturesGenerated,
                      onRemove: () => _confirmRemoveTeam(team),
                    ),
                    4.h,
                  ],
                24.h,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CricketText(
                      text: TranslationKeys.fixtures.tr,
                      style: context.textTheme.titleSmall,
                    ),
                    if (controller.isOwner &&
                        (!controller.fixturesGenerated || controller.canGenerateNextRound))
                      TextButton(
                        onPressed: _generateFixtures,
                        child: CricketText(
                          text: controller.fixturesGenerated
                              ? TranslationKeys.generateNextRound.tr
                              : TranslationKeys.generateFixtures.tr,
                        ),
                      ),
                  ],
                ),
                8.h,
                if (controller.fixtures.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CricketText(
                      text: TranslationKeys.noFixturesYet.tr,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (final round in _roundsInOrder(controller.fixtures)) ...[
                    CricketText(
                      text: '${TranslationKeys.round.tr} $round',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    8.h,
                    for (final fixture in controller.fixtures.where((f) => f.round == round)) ...[
                      _FixtureRow(
                        fixture: fixture,
                        isOwner: controller.isOwner,
                        onStart: () => showStartFixtureMatchSheet(
                          controller: controller,
                          fixture: fixture,
                        ),
                        onResolve: () => showResolveFixtureSheet(
                          controller: controller,
                          fixture: fixture,
                        ),
                      ),
                      4.h,
                    ],
                    12.h,
                  ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Every round number present in [fixtures], ascending, de-duplicated —
/// drives the round-header grouping in the Fixtures section above.
List<int> _roundsInOrder(List<FixtureRes> fixtures) {
  final rounds = fixtures.map((f) => f.round).toSet().toList();
  rounds.sort();
  return rounds;
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

/// One fixture: the matchup (or "TeamA — Bye"), a status pill, and — when
/// applicable — a trailing action. `scheduled` gets "Start match" (any
/// member); `unresolved` gets owner-only "Declare winner"; `bye`/`completed`
/// get no action, just the pill.
class _FixtureRow extends StatelessWidget {
  const _FixtureRow({
    required this.fixture,
    required this.isOwner,
    required this.onStart,
    required this.onResolve,
  });

  final FixtureRes fixture;
  final bool isOwner;
  final VoidCallback onStart;
  final VoidCallback onResolve;

  @override
  Widget build(BuildContext context) {
    final matchupText = fixture.isBye
        ? '${fixture.teamA.name} — ${TranslationKeys.byeLabel.tr}'
        : '${fixture.teamA.name} ${TranslationKeys.vsLabel.tr} ${fixture.teamB?.name ?? ''}';

    Widget? action;
    if (fixture.status == 'scheduled') {
      action = TextButton(
        onPressed: onStart,
        child: CricketText(text: TranslationKeys.startMatch.tr),
      );
    } else if (fixture.status == 'unresolved' && isOwner) {
      action = TextButton(
        onPressed: onResolve,
        child: CricketText(text: TranslationKeys.declareWinner.tr),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: CricketText(
              text: matchupText,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.secondary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: fixtureStatusColor(context, fixture.status).withValues(alpha: 0.12),
              borderRadius: 8.radius,
            ),
            child: CricketText(
              text: fixtureStatusLabel(fixture.status),
              style: context.textTheme.labelSmall?.copyWith(
                color: fixtureStatusColor(context, fixture.status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (action != null) ...[8.w, action],
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit (after Task 8 completes and the whole slice compiles)**

Do not run `flutter analyze`/`flutter test` or commit yet — `showStartFixtureMatchSheet`/`showResolveFixtureSheet` don't exist until Tasks 7-8. Move on to Task 7.

---

### Task 7: Start-match sheet

**Files:**
- Create: `lib/features/tournament/presentation/widget/start_fixture_match_sheet.dart`
- Test: `test/features/tournament/presentation/widget/start_fixture_match_sheet_test.dart`

**Interfaces:**
- Consumes: `TournamentDetailController.startFixtureMatch` (Task 5), `CoinFlip` (`lib/features/scoring/presentation/widget/coin_flip.dart`, already exists), `AppRoutes.scoreBall` (already exists).
- Produces: `showStartFixtureMatchSheet({required controller, required fixture})` — Task 6 calls this.

- [ ] **Step 1: Write the sheet**

Create `lib/features/tournament/presentation/widget/start_fixture_match_sheet.dart`:

```dart
import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/coin_flip.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Starting a scheduled fixture into a real match. Both teams are already
/// fixed by the fixture, so unlike `CreateMatchScreen` this only ever asks
/// for overs and an optional toss — reusing the exact same `CoinFlip`
/// widget and toss-decision chips `CreateMatchScreen` already has. On
/// success, navigates straight into the existing live-scoring screen the
/// same way `CreateMatchController` does today
/// (`Get.toNamed(AppRoutes.scoreBall, arguments: ...)`), so this sheet adds
/// no new scoring UI of its own.
Future<void> showStartFixtureMatchSheet({
  required TournamentDetailController controller,
  required FixtureRes fixture,
}) async {
  final oversController = TextEditingController();
  String? tossWinner;
  String? tossDecision;

  await CustomBottomSheet.wrapBottomSheet<void>(
    headlineText: TranslationKeys.startMatch.tr,
    child: StatefulBuilder(
      builder: (context, setSheetState) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CricketTextField(
              controller: oversController,
              hintText: TranslationKeys.enterOvers.tr,
              labelText: TranslationKeys.overs.tr,
              prefixIcon: const Icon(Icons.timer_outlined),
              keyboardType: TextInputType.number,
              isRequired: true,
            ),
            16.h,
            CricketText(
              text: TranslationKeys.tossOptional.tr,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            8.h,
            CricketText(
              text: TranslationKeys.tossWinner.tr,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            8.h,
            CoinFlip(
              onResult: (winner) => setSheetState(() => tossWinner = winner),
            ),
            16.h,
            if (tossWinner != null) ...[
              CricketText(
                text: TranslationKeys.tossDecision.tr,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              8.h,
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  FilterChip(
                    label: CricketText(text: TranslationKeys.bat.tr),
                    selected: tossDecision == 'bat',
                    onSelected: (_) => setSheetState(() => tossDecision = 'bat'),
                  ),
                  FilterChip(
                    label: CricketText(text: TranslationKeys.bowl.tr),
                    selected: tossDecision == 'bowl',
                    onSelected: (_) => setSheetState(() => tossDecision = 'bowl'),
                  ),
                ],
              ),
              16.h,
            ],
            CricketButton(
              buttonText: TranslationKeys.startMatch.tr,
              onPressed: () async {
                final overs = int.tryParse(oversController.text.trim());
                if (overs == null || overs < 1 || overs > 50) {
                  CricketSnackbar.showAlertMessage(TranslationKeys.enterOvers.tr);
                  return;
                }
                if ((tossWinner == null) != (tossDecision == null)) {
                  CricketSnackbar.showAlertMessage(TranslationKeys.tossIncomplete.tr);
                  return;
                }

                final outcome = await controller.startFixtureMatch(
                  fixture.id,
                  totalOvers: overs,
                  tossWinner: tossWinner,
                  tossDecision: tossDecision,
                );

                if (outcome.match != null) {
                  Get.back<void>();
                  unawaited(
                    Get.toNamed<dynamic>(
                      AppRoutes.scoreBall,
                      arguments: outcome.match,
                    ),
                  );
                } else {
                  CricketSnackbar.showAlertMessage(
                    outcome.errorMessage ?? TranslationKeys.somethingWentWrong.tr,
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  );

  oversController.dispose();
}
```

Add the missing `dart:async` import for `unawaited` at the top of the file:

```dart
import 'dart:async';
```

(Place it as the first import, above `package:cricket_scorer/...`, matching Dart's own import-ordering convention already used in `create_match_controller.dart`.)

- [ ] **Step 2: Write a widget test**

Create `test/features/tournament/presentation/widget/start_fixture_match_sheet_test.dart`, following `edit_tournament_sheet_test.dart`'s exact fake-controller shape (a thin subclass overriding only the one method this sheet calls, `_Unused*UseCase` no-op fakes for the other ten constructor args) plus `create_match_controller_test.dart`'s pattern for asserting navigation via a real registered `GetPage`:

```dart
import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/generate_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resolve_fixture.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_fixture_match.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/update_tournament.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/start_fixture_match_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

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
        getFixturesUseCase: _UnusedGetFixturesUseCase(),
        generateFixturesUseCase: _UnusedGenerateFixturesUseCase(),
        startFixtureMatchUseCase: _UnusedStartFixtureMatchUseCase(),
        resolveFixtureUseCase: _UnusedResolveFixtureUseCase(),
      );

  String? lastFixtureId;
  int? lastTotalOvers;
  StartFixtureMatchOutcome outcome = const StartFixtureMatchOutcome.failure(
    'not configured',
  );

  @override
  Future<StartFixtureMatchOutcome> startFixtureMatch(
    String fixtureId, {
    required int totalOvers,
    String? tossWinner,
    String? tossDecision,
  }) async {
    lastFixtureId = fixtureId;
    lastTotalOvers = totalOvers;
    return outcome;
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

class _UnusedGetFixturesUseCase implements GetFixturesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedGenerateFixturesUseCase implements GenerateFixturesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedStartFixtureMatchUseCase implements StartFixtureMatchUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedResolveFixtureUseCase implements ResolveFixtureUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _FakeTournamentDetailController controller;

  final fixture = FixtureRes(
    id: 'fixture-1',
    round: 1,
    order: 0,
    teamA: FixtureTeamRef(id: 'team-1', name: 'Harbor CC'),
    teamB: FixtureTeamRef(id: 'team-2', name: 'Lakeside XI'),
    isBye: false,
    status: 'scheduled',
  );

  Future<void> pumpOpenButton(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showStartFixtureMatchSheet(
                controller: controller,
                fixture: fixture,
              ),
              child: const Text('open'),
            ),
          ),
        ),
        // startFixtureMatch navigates to AppRoutes.scoreBall on success —
        // give it somewhere real to land, same as
        // create_match_controller_test.dart.
        getPages: [
          GetPage(
            name: AppRoutes.scoreBall,
            page: () => const Scaffold(body: Text('score ball')),
          ),
        ],
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  // Same GetX-snackbar-timing reasoning as edit_tournament_sheet_test.dart:
  // pump frame-by-frame, never pumpAndSettle(), across a tap that can
  // trigger a snackbar and/or a route change.
  Future<void> tapAndSettleFrames(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  setUp(() {
    Get.testMode = true;
    controller = _FakeTournamentDetailController();
  });

  tearDown(Get.reset);

  testWidgets('shows the overs field and the toss section', (tester) async {
    await pumpOpenButton(tester);

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('toss_optional'), findsOneWidget);
  });

  testWidgets(
    'submitting a valid overs value with no toss starts the match and navigates to scoring',
    (tester) async {
      controller.outcome = StartFixtureMatchOutcome.success(
        CreateMatchRes(
          matchId: 'match-1',
          joinCode: 'ABC123',
          teamA: TeamRef(id: 'team-1', name: 'Harbor CC'),
          teamB: TeamRef(id: 'team-2', name: 'Lakeside XI'),
          totalOvers: 20,
          status: 'upcoming',
          syncStatus: 'local',
          createdAt: '2026-09-06T10:00:00.000Z',
        ),
      );
      await pumpOpenButton(tester);

      await tester.enterText(find.byType(TextField), '20');
      await tapAndSettleFrames(tester, find.text('start_match').last);

      expect(controller.lastFixtureId, 'fixture-1');
      expect(controller.lastTotalOvers, 20);
      expect(find.text('score ball'), findsOneWidget);
    },
  );

  testWidgets('shows an alert message and stays open on failure', (tester) async {
    controller.outcome = const StartFixtureMatchOutcome.failure(
      'This fixture already has a match',
    );
    await pumpOpenButton(tester);

    await tester.enterText(find.byType(TextField), '20');
    await tapAndSettleFrames(tester, find.text('start_match').last);

    expect(find.text('This fixture already has a match'), findsOneWidget);
  });
}
```

`find.text('start_match').last` disambiguates the sheet's headline (`TranslationKeys.startMatch.tr`, also `'start_match'` untranslated in tests) from its submit button, which share the same key — both render the literal string `'start_match'` in a test with no translation table loaded, so `.last` picks the button rather than the headline. If this app's test setup does load real translations, adjust the finder to whatever distinguishes the button (e.g. `find.widgetWithText(CricketButton, TranslationKeys.startMatch.tr)`), but check `edit_tournament_sheet_test.dart`'s own precedent first — it finds `'save'` directly with no disambiguation because that string appears only once there, so this file may need the same `.last` treatment `edit_tournament_sheet_test.dart` didn't need to reach for.

- [ ] **Step 3: Commit**

```bash
git add lib/features/tournament/presentation/widget/start_fixture_match_sheet.dart test/features/tournament/presentation/widget/start_fixture_match_sheet_test.dart
git commit -m "feat: add start-fixture-match sheet"
```

---

### Task 8: Resolve-fixture sheet

**Files:**
- Create: `lib/features/tournament/presentation/widget/resolve_fixture_sheet.dart`
- Test: `test/features/tournament/presentation/widget/resolve_fixture_sheet_test.dart`

**Interfaces:**
- Consumes: `TournamentDetailController.resolveFixture` (Task 5).
- Produces: `showResolveFixtureSheet({required controller, required fixture})` — Task 6 calls this. This is the last piece Task 6 needed; run the full compile/test verification at the end of this task, covering Tasks 6-8 together.

- [ ] **Step 1: Write the sheet**

Create `lib/features/tournament/presentation/widget/resolve_fixture_sheet.dart`:

```dart
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Manually resolving an `unresolved` fixture (tie/no-result/abandoned) —
/// exactly two candidates, so this mirrors `showEnrollTeamSheet`'s
/// tap-a-name shape rather than needing a full picker.
Future<void> showResolveFixtureSheet({
  required TournamentDetailController controller,
  required FixtureRes fixture,
}) async {
  final teamB = fixture.teamB;
  if (teamB == null) return; // A bye fixture is never 'unresolved'.

  final resolved = await CustomBottomSheet.wrapBottomSheet<bool>(
    headlineText: TranslationKeys.declareWinner.tr,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CandidateRow(
            name: fixture.teamA.name,
            onTap: () async {
              final errorMessage = await controller.resolveFixture(
                fixture.id,
                fixture.teamA.id,
              );
              if (errorMessage == null) {
                Get.back<bool>(result: true);
              } else {
                CricketSnackbar.showErrorMessage(errorMessage);
              }
            },
          ),
          _CandidateRow(
            name: teamB.name,
            onTap: () async {
              final errorMessage = await controller.resolveFixture(
                fixture.id,
                teamB.id,
              );
              if (errorMessage == null) {
                Get.back<bool>(result: true);
              } else {
                CricketSnackbar.showErrorMessage(errorMessage);
              }
            },
          ),
        ],
      ),
    ),
  );

  if (resolved == true) {
    CricketSnackbar.showSuccessMessage(TranslationKeys.fixtureResolved.tr);
  }
}

class _CandidateRow extends StatelessWidget {
  const _CandidateRow({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: 8.radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 20,
                color: context.colorScheme.onSurfaceVariant,
              ),
              12.w,
              Expanded(
                child: CricketText(
                  text: name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.secondary,
                  ),
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

- [ ] **Step 2: Write a widget test**

Create `test/features/tournament/presentation/widget/resolve_fixture_sheet_test.dart`, following the exact same `_FakeTournamentDetailController` shape used in Task 7's test (a thin subclass overriding just `resolveFixture`, with the same ten `_Unused*UseCase` no-op fakes):

```dart
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/generate_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resolve_fixture.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_fixture_match.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/update_tournament.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/resolve_fixture_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

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
        getFixturesUseCase: _UnusedGetFixturesUseCase(),
        generateFixturesUseCase: _UnusedGenerateFixturesUseCase(),
        startFixtureMatchUseCase: _UnusedStartFixtureMatchUseCase(),
        resolveFixtureUseCase: _UnusedResolveFixtureUseCase(),
      );

  String? lastFixtureId;
  String? lastWinnerTeamId;
  String? errorMessage;

  @override
  Future<String?> resolveFixture(String fixtureId, String winnerTeamId) async {
    lastFixtureId = fixtureId;
    lastWinnerTeamId = winnerTeamId;
    return errorMessage;
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

class _UnusedGetFixturesUseCase implements GetFixturesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedGenerateFixturesUseCase implements GenerateFixturesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedStartFixtureMatchUseCase implements StartFixtureMatchUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedResolveFixtureUseCase implements ResolveFixtureUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _FakeTournamentDetailController controller;

  final fixture = FixtureRes(
    id: 'fixture-1',
    round: 2,
    order: 0,
    teamA: FixtureTeamRef(id: 'team-1', name: 'Harbor CC'),
    teamB: FixtureTeamRef(id: 'team-2', name: 'Lakeside XI'),
    isBye: false,
    status: 'unresolved',
  );

  Future<void> pumpOpenButton(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showResolveFixtureSheet(
                controller: controller,
                fixture: fixture,
              ),
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

  setUp(() {
    Get.testMode = true;
    controller = _FakeTournamentDetailController();
  });

  tearDown(Get.reset);

  testWidgets('shows both fixture teams as tappable rows', (tester) async {
    await pumpOpenButton(tester);

    expect(find.text('Harbor CC'), findsOneWidget);
    expect(find.text('Lakeside XI'), findsOneWidget);
  });

  testWidgets(
    "tapping a team resolves the fixture with that team's id and shows a success snackbar",
    (tester) async {
      await pumpOpenButton(tester);

      await tapAndAwaitSnackbar(tester, find.text('Lakeside XI'));

      expect(controller.lastFixtureId, 'fixture-1');
      expect(controller.lastWinnerTeamId, 'team-2');
      expect(find.text('fixture_resolved'), findsOneWidget);
      await drainSnackbar(tester);
    },
  );

  testWidgets('shows an error snackbar on failure', (tester) async {
    controller.errorMessage = "This fixture isn't awaiting manual resolution";
    await pumpOpenButton(tester);

    await tapAndAwaitSnackbar(tester, find.text('Harbor CC'));

    expect(find.text("This fixture isn't awaiting manual resolution"), findsOneWidget);
    await drainSnackbar(tester);
  });
}
```

- [ ] **Step 3: Commit the sheet and its test**

```bash
git add lib/features/tournament/presentation/widget/resolve_fixture_sheet.dart test/features/tournament/presentation/widget/resolve_fixture_sheet_test.dart
git commit -m "feat: add resolve-fixture sheet"
```

- [ ] **Step 4: Now verify Tasks 6-8 together compile and pass**

Run: `dart run build_runner build --delete-conflicting-outputs` (in case any lingering generated-file drift exists)
Run: `flutter analyze`
Expected: 0 issues — this is the first point `tournament_detail_screen.dart` (Task 6), `start_fixture_match_sheet.dart` (Task 7), and `resolve_fixture_sheet.dart` (Task 8) all exist together and can resolve each other's imports

Run: `flutter test`
Expected: every test passes, including Task 6's screen having no dedicated test of its own (it's exercised via the controller test and on-device verification in Task 10) and Tasks 1/5/7/8's new tests

- [ ] **Step 5: Commit Task 6's screen changes**

```bash
git add lib/features/tournament/presentation/pages/tournament_detail_screen.dart
git commit -m "feat: add Fixtures section to TournamentDetailScreen"
```

---

### Task 9: Frontend design pass

Invoke the `frontend-design` skill on the four new/changed surfaces together: the Fixtures section + round headers + `_FixtureRow` on `TournamentDetailScreen`, `start_fixture_match_sheet.dart`, `resolve_fixture_sheet.dart`, and `fixture_status_chip.dart`. Ground it in this app's existing visual vocabulary exactly the way the earlier Tournament UI design pass did:

- `_FixtureRow`'s status pill must match the flat, alpha-tinted, borderless shape every other status/format pill in this app already uses (`tournamentStatusColor`/`fixtureStatusColor` withValues(alpha: 0.12) treatment) — check it doesn't accidentally read as a generic Material chip.
- The round header (`'${TranslationKeys.round.tr} $round'`) is plain text in this plan's draft — decide deliberately whether that's sufficient or whether it wants the same treatment as a section header elsewhere in this screen (e.g. a subtle divider, different weight/size) rather than leaving it as an afterthought default.
- `_CandidateRow` in the resolve sheet currently uses a trophy icon for both candidates identically — consider whether that reads as "you're picking one of these to be the champion" clearly enough, or whether it needs a different affordance (e.g. no icon at all, relying purely on the sheet's own headline "Declare winner" for context) — decide deliberately, don't leave an icon that doesn't earn its place.
- Confirm `start_fixture_match_sheet.dart`'s reuse of `CreateMatchScreen`'s exact toss/overs layout reads correctly inside a bottom sheet's tighter vertical space (a full screen's `SingleChildScrollView` padding may not be right for a sheet) — adjust spacing if needed, following `edit_tournament_sheet.dart`'s own sheet-specific spacing rather than the full-screen `create_match_screen.dart`'s.
- Verify the bye-fixture row's "TeamName — Bye" text reads clearly as "this team automatically advanced," not as an error or missing-data state.

After the design pass, re-run `flutter analyze` and `flutter test` and confirm both stay clean — this pass changes only presentation, not controller/widget behavior the existing tests assert on. Commit the design-pass changes separately from the mechanical-implementation commits above, with a commit message that's clear this is a design/polish pass (matching the earlier Tournament UI phase's own convention).

---

### Task 10: On-device verification

Per the user's original Phase 3 instructions ("Build it, then verify on device before calling it done"), verify the golden path and at least one edge case live, the same way the earlier Tournament UI phase did (iOS Simulator, physical device, or a running emulator — never boot one yourself if none is already running; ask first if unsure per this session's own established device-priority rule).

Golden path to verify, for at least one `round_robin` (or `league`) tournament and one `knockout` tournament with 3+ teams:
1. Generate fixtures from `TournamentDetailScreen` as the owner — confirm the round-grouped list renders, byes (knockout only) show correctly attributed to the earliest-enrolled teams, and the "Enroll team"/remove-team controls disappear once fixtures exist.
2. Start a scheduled fixture — confirm the sheet takes overs (+ optional toss via the real `CoinFlip` widget) and navigates into the existing live-scoring screen with the right two teams.
3. Play the match to completion through the existing scoring flow, return to `TournamentDetailScreen` (pull-to-refresh or re-navigate), and confirm the fixture now shows `completed` with the correct winner.
4. For knockout: once the current round is fully resolved, confirm "Generate next round" appears (owner-only) and produces the next round correctly, down to the final auto-completing the tournament.
5. Negative case: abandon a live match started from a fixture, return to `TournamentDetailScreen`, confirm that fixture shows `unresolved`, and (as the owner) use "Declare winner" to resolve it manually.

Report exactly what was verified and any bugs found/fixed, the same way the earlier Tournament UI phase's on-device pass surfaced and fixed a real parent-screen-refresh bug — this step is not "assume it works because the code compiles," per `superpowers:verification-before-completion`.

---

### Task 11: Final verification and code review

- [ ] **Step 1: Invoke `superpowers:verification-before-completion`**

Re-run `flutter analyze` and `flutter test` fresh (not relying on earlier-in-session runs) and confirm both are clean before making any completion claim.

- [ ] **Step 2: Invoke `superpowers:requesting-code-review`**

Dispatch a code-reviewer subagent per that skill's template, covering the whole `feat-tournament-fixtures-ui` branch against this plan and `docs/api.md`'s Fixture section (the contract this UI consumes). Fix any Critical/Important findings before proceeding; note Minor findings.

- [ ] **Step 3: Report**

This is also the point to report on the *whole* cross-repo feature (backend + frontend), per the user's original top-level instructions ("run superpowers:verification-before-completion and superpowers:requesting-code-review, and report what each surfaced" — stated once, covering the whole feature, not per-phase). Summarize: test counts pass/fail for both repos, the on-device verification findings from Task 10, and the code review's findings (fixed vs. noted) for this branch.
