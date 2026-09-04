# Team Profile Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a team profile screen (roster + paginated past results) reachable by tapping a team's name from match history, plus an "reuse an existing team" picker on match creation — using three already-shipped backend endpoints (`GET /v1/team`, `GET /v1/team/:teamId`, `GET /v1/team/:teamId/matches`) and the extended `POST /v1/match/create` (`teamAId`/`teamBId`).

**Architecture:** Follows this app's existing GetX + clean-architecture layering exactly: `MatchEndpoint` (paths) → `MatchApiService` (Dio calls) → `MatchRepositoryImpl`/`MatchRepository` (DTO mapping, `Either<CricketResponse<T>, CricketFailure>`) → `UseCase` classes → `GetxController` → `GetView` screen, wired through `Bindings` and `GetPage` routes. Team reads are added to the existing scoring vertical slice (`MatchEndpoint`/`MatchApiService`/`MatchRepository`) rather than a new "team" slice, mirroring how `careerStats` (player-scoped, not match-scoped) already shares this same chain. The one genuine, byte-for-byte duplication — the match-history card — is extracted into a shared widget; the hand-rolled pagination/scroll-listener pattern is deliberately duplicated, not extracted, to avoid touching `HomeController`'s already-shipped behavior.

**Tech Stack:** Flutter, GetX (state/navigation/DI), Dio, `json_annotation`/`json_serializable`/`build_runner` for DTOs, `flutter_test` for controller/DTO/widget tests.

**Spec:** `/Users/samirsuroshe/Projects/Cricket-Scorer-Project/cricket-scorer-workspace/docs/api.md`, sections "## Team profile" and "## POST /v1/match/create".

## Global Constraints

- Every new endpoint path constant starts at `/v1/...`, never `/api/v1/...` — `FlavorConfig.baseUrl` already ends in `/api` and Dio concatenates, it does not resolve.
- Do not modify any backend code — the three team endpoints and the extended `POST /v1/match/create` are already shipped.
- `Authorization: Bearer <accessToken>` is attached automatically by the existing `AuthInterceptor`/`ApiClient` for every authenticated call — no per-request auth code is needed in any new method.
- Team-level aggregate stats (wins/losses/win%) are explicitly out of scope. Do not add fields, DTOs, or UI hooks for them, including "for later" placeholders.
- Do not add tap handlers to the live-scoring console (`score_ball_screen.dart`) or spectator screen (`spectator_screen.dart`) — out of scope.
- Do not change `HomeController`'s or `home_page.dart`'s pagination/scroll-listener logic — only the match-history card gets extracted out of `home_page.dart`.
- Reuse `MatchHistoryItem`/`MatchHistoryRes` (from `lib/features/scoring/data/models/response/match_history_res.dart`) directly for `GET /v1/team/:teamId/matches` — do not create a `TeamMatchesRes` class, the JSON shape is identical.
- This repo has a real Flutter test convention (`test/` mirrors `lib/`, fake `MatchRepository`/`UseCase` implementations, `flutter_test`/`testWidgets`) for **controllers, DTOs, endpoints, and some widgets** — but **no test coverage exists today for full pages** (`home_page.dart`, `player_stats_screen.dart`, `create_match_screen.dart` have no page-level test beyond one form-only widget test). Follow the existing convention where it exists (controllers, DTOs, endpoint builders, the extracted card widget); for the two new/changed full screens (`TeamProfileScreen`, the chip picker on `CreateMatchScreen`), state explicitly that verification is manual (Task 10) rather than inventing a testing pattern this codebase doesn't have.
- A visual/aesthetic design pass (per the `frontend-design` skill) is applied when implementing Tasks 8–9's screen UI — the widget code in those tasks is a functionally-correct baseline, not the final visual treatment. Don't skip that pass just because this plan's code compiles and works.
- **Known repo state**: at the time this plan was written, `cricket-scrorer`'s `development` branch already has *uncommitted, unrelated, in-progress* changes sitting in some of the same files this plan touches (`lib/config/routes/app_pages.dart`, `lib/config/routes/app_routes.dart`, `lib/core/di/injection/scoring_injection.dart` — apparently a career-stats/player-profile feature from an earlier session). Do not discard, stash-and-drop, or silently fold that work into this plan's commits. Confirm with the user how to handle it (separate branch, commit alongside with a clear message, etc.) before running Task 1's first commit.

---

### Task 1: Team response DTOs

**Files:**
- Create: `lib/features/scoring/data/models/response/team_profile_res.dart`
- Create: `lib/features/scoring/data/models/response/team_profile_res.g.dart` (generated)
- Create: `lib/features/scoring/data/models/response/my_teams_res.dart`
- Create: `lib/features/scoring/data/models/response/my_teams_res.g.dart` (generated)
- Test: `test/features/scoring/data/models/response/team_profile_res_test.dart`
- Test: `test/features/scoring/data/models/response/my_teams_res_test.dart`

**Interfaces:**
- Consumes: nothing (leaf DTOs), `json_annotation`'s `@JsonSerializable()`/`@JsonSerializable(explicitToJson: true)` exactly as used in `lib/features/scoring/data/models/response/career_stats_res.dart`.
- Produces: `TeamRosterPlayer(playerId, playerName, jerseyNumber, role)`, `TeamProfileRes(teamId, name, shortName, roster)`, `TeamSummary(id, name, shortName)`, `MyTeamsRes(teams)` — all with `fromJson`/`toJson`, consumed by Task 4's repository and Task 8/9's controllers.

- [ ] **Step 1: Write `team_profile_res.dart`**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'team_profile_res.g.dart';

/// One row of `GET /v1/team/:teamId`'s `roster` — the same lightweight
/// identity fields already embedded in `Scorecard.battingScores`/
/// `bowlingScores`; there is no separate, heavier "player-summary" object to
/// reuse for a roster row. See docs/api.md's "Team profile" section.
@JsonSerializable()
class TeamRosterPlayer {
  final String playerId;
  final String playerName;

  /// Null when the player has never been assigned one.
  final int? jerseyNumber;

  /// `batsman` / `bowler` / `allrounder` / `wicketkeeper` / `unknown`.
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
/// accumulated onto its roster across every match it has been attached to
/// (directly, or via `teamAId`/`teamBId` reuse on match creation).
/// `roster` is `[]`, not an error, for a team no one has been rostered onto
/// yet. Deliberately carries no aggregate stats (wins/losses/win%) — v1 is
/// roster + past results only, see docs/api.md.
@JsonSerializable(explicitToJson: true)
class TeamProfileRes {
  final String teamId;
  final String name;
  final String? shortName;
  final List<TeamRosterPlayer> roster;

  TeamProfileRes({
    required this.teamId,
    required this.name,
    this.shortName,
    required this.roster,
  });

  factory TeamProfileRes.fromJson(Map<String, dynamic> json) =>
      _$TeamProfileResFromJson(json);

  Map<String, dynamic> toJson() => _$TeamProfileResToJson(this);
}
```

- [ ] **Step 2: Write `my_teams_res.dart`**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'my_teams_res.g.dart';

/// One row of `GET /v1/team` — the source list for the "reuse this team"
/// picker on `CreateMatchScreen`. A team appears once regardless of how many
/// matches reference it.
@JsonSerializable()
class TeamSummary {
  final String id;
  final String name;
  final String? shortName;

  TeamSummary({required this.id, required this.name, this.shortName});

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

- [ ] **Step 3: Generate the `.g.dart` files**

Run: `cd cricket-scrorer && dart run build_runner build --delete-conflicting-outputs`
Expected: `team_profile_res.g.dart` and `my_teams_res.g.dart` are created next to the source files, each with `_$...FromJson`/`_$...ToJson` top-level functions matching the fields above.

- [ ] **Step 4: Write the DTO pin tests**

```dart
// test/features/scoring/data/models/response/team_profile_res_test.dart
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson parses a team profile with a populated roster', () {
    final res = TeamProfileRes.fromJson({
      'teamId': '665f1a2b3c4d5e6f7a8b9c01',
      'name': 'Mumbai Indians',
      'shortName': 'MI',
      'roster': [
        {
          'playerId': '665f3b1c2d3e4f5a6b7c8d90',
          'playerName': 'Rahul',
          'jerseyNumber': 7,
          'role': 'batsman',
        },
      ],
    });

    expect(res.teamId, '665f1a2b3c4d5e6f7a8b9c01');
    expect(res.shortName, 'MI');
    expect(res.roster.single.playerName, 'Rahul');
    expect(res.roster.single.jerseyNumber, 7);
    expect(res.roster.single.role, 'batsman');
  });

  test('fromJson accepts a null shortName and an empty roster', () {
    final res = TeamProfileRes.fromJson({
      'teamId': '665f1a2b3c4d5e6f7a8b9c01',
      'name': 'Mumbai Indians',
      'shortName': null,
      'roster': <dynamic>[],
    });

    expect(res.shortName, isNull);
    expect(res.roster, isEmpty);
  });
}
```

```dart
// test/features/scoring/data/models/response/my_teams_res_test.dart
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson parses the caller\'s own teams', () {
    final res = MyTeamsRes.fromJson({
      'teams': [
        {
          'id': '665f1a2b3c4d5e6f7a8b9c01',
          'name': 'Mumbai Indians',
          'shortName': 'MI',
        },
      ],
    });

    expect(res.teams.single.id, '665f1a2b3c4d5e6f7a8b9c01');
    expect(res.teams.single.shortName, 'MI');
  });

  test('fromJson accepts a null shortName', () {
    final res = MyTeamsRes.fromJson({
      'teams': [
        {'id': 'team-1', 'name': 'Chennai Super Kings', 'shortName': null},
      ],
    });

    expect(res.teams.single.shortName, isNull);
  });
}
```

- [ ] **Step 5: Run the tests**

Run: `flutter test test/features/scoring/data/models/response/team_profile_res_test.dart test/features/scoring/data/models/response/my_teams_res_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/features/scoring/data/models/response/team_profile_res.dart lib/features/scoring/data/models/response/team_profile_res.g.dart lib/features/scoring/data/models/response/my_teams_res.dart lib/features/scoring/data/models/response/my_teams_res.g.dart test/features/scoring/data/models/response/team_profile_res_test.dart test/features/scoring/data/models/response/my_teams_res_test.dart
git commit -m "feat: add team profile and my-teams response DTOs"
```

---

### Task 2: `MatchEndpoint` path builders

**Files:**
- Modify: `lib/features/scoring/data/match_endpoint.dart`
- Test: `test/features/scoring/data/match_endpoint_test.dart`

**Interfaces:**
- Consumes: nothing new.
- Produces: `MatchEndpoint.myTeams` (`String` field), `MatchEndpoint.teamProfile(String teamId)`, `MatchEndpoint.teamMatches(String teamId)` — consumed by Task 3's `MatchApiService`.

- [ ] **Step 1: Add the three path builders**

Insert after line 6 (`final String history = '/v1/match/history';`) in `lib/features/scoring/data/match_endpoint.dart`:

```dart
  /// `GET /v1/team` — the caller's own teams, source for the "reuse this
  /// team" picker on `CreateMatchScreen`.
  final String myTeams = '/v1/team';

  /// `GET /v1/team/:teamId` — always a server-generated ObjectId hex string,
  /// same as `startInnings`/`scoreBall`/etc.'s `matchId` above; no encoding
  /// needed, unlike `publicMatch`'s user-suppliable `code`.
  String teamProfile(String teamId) => '/v1/team/$teamId';

  /// `GET /v1/team/:teamId/matches` — byte-for-byte the same response shape
  /// as [history], scoped to one team.
  String teamMatches(String teamId) => '/v1/team/$teamId/matches';

```

- [ ] **Step 2: Write the failing test**

Append to `test/features/scoring/data/match_endpoint_test.dart`:

```dart
  test('myTeams is a fixed path', () {
    expect(endpoint.myTeams, '/v1/team');
  });

  test('teamProfile interpolates the team id with no encoding', () {
    expect(
      endpoint.teamProfile('665f1a2b3c4d5e6f7a8b9c01'),
      '/v1/team/665f1a2b3c4d5e6f7a8b9c01',
    );
  });

  test('teamMatches interpolates the team id with no encoding', () {
    expect(
      endpoint.teamMatches('665f1a2b3c4d5e6f7a8b9c01'),
      '/v1/team/665f1a2b3c4d5e6f7a8b9c01/matches',
    );
  });
```

- [ ] **Step 3: Run the tests**

Run: `flutter test test/features/scoring/data/match_endpoint_test.dart`
Expected: PASS (5 tests total — 2 existing `publicMatch` tests plus the 3 new ones).

- [ ] **Step 4: Commit**

```bash
git add lib/features/scoring/data/match_endpoint.dart test/features/scoring/data/match_endpoint_test.dart
git commit -m "feat: add team-profile endpoint paths"
```

---

### Task 3: `MatchApiService` team methods

**Files:**
- Modify: `lib/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart`

**Interfaces:**
- Consumes: `MatchEndpoint.myTeams`/`teamProfile`/`teamMatches` (Task 2), `ApiClient.get({required String endpoint, Map<String, dynamic>? queryParameters})` (existing, `lib/core/network/api_client_service.dart:66`).
- Produces: `MatchApiService.getMyTeams()`, `MatchApiService.getTeamProfile({required String teamId})`, `MatchApiService.getTeamMatches({required String teamId, required int page, required int limit})`, all returning `Future<Either<ApiResponseModel, CricketFailure>>` — consumed by Task 4's `MatchRepositoryImpl`.

**No test convention exists for this layer** — there is no `match_api_service_test.dart` in this repo (confirmed: `find test -iname "*api_service*"` returns nothing) and every other method on this class is untested directly, exercised only indirectly through the repository/controller layer. This task is verified by Task 4's repository tests and by Task 10's manual pass.

- [ ] **Step 1: Add the three methods**

Insert after `getMatchHistory` (after the closing `}` of that method) in `lib/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart`:

```dart
  /// `GET /v1/team` — the caller's own teams.
  Future<Either<ApiResponseModel, CricketFailure>> getMyTeams() async {
    return await apiClient.get(endpoint: matchEndpoint.myTeams);
  }

  /// `GET /v1/team/:teamId` — display name plus roster. `verifyJwt` plus a
  /// `createdBy` ownership check server-side, same shape as [getScorecard].
  Future<Either<ApiResponseModel, CricketFailure>> getTeamProfile({
    required String teamId,
  }) async {
    return await apiClient.get(endpoint: matchEndpoint.teamProfile(teamId));
  }

  /// `GET /v1/team/:teamId/matches` — byte-for-byte the same shape as
  /// [getMatchHistory], scoped to one team instead of the caller.
  Future<Either<ApiResponseModel, CricketFailure>> getTeamMatches({
    required String teamId,
    required int page,
    required int limit,
  }) async {
    return await apiClient.get(
      endpoint: matchEndpoint.teamMatches(teamId),
      queryParameters: {'page': page, 'limit': limit},
    );
  }
```

- [ ] **Step 2: Verify the file still analyzes cleanly**

Run: `flutter analyze lib/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart
git commit -m "feat: add team-profile calls to MatchApiService"
```

---

### Task 4: `MatchRepository`/`MatchRepositoryImpl` team methods + update existing fakes

**Files:**
- Modify: `lib/features/scoring/domain/repositories/match_repository.dart`
- Modify: `lib/features/scoring/data/repositories/match_repository_impl.dart`
- Modify: `test/features/home/presentation/controllers/home_controller_test.dart`
- Modify: `test/features/scoring/presentation/controllers/spectator_controller_test.dart`
- Modify: `test/features/scoring/presentation/controllers/score_ball_controller_test.dart`

**Interfaces:**
- Consumes: `MatchApiService.getMyTeams`/`getTeamProfile`/`getTeamMatches` (Task 3), `MyTeamsRes`/`TeamProfileRes` (Task 1), existing `CricketResponse<T>`/`Either`/`ApiResponseModel` patterns.
- Produces: `MatchRepository.getMyTeams()`, `MatchRepository.getTeamProfile({required String teamId})`, `MatchRepository.getTeamMatches({required String teamId, required int page, required int limit})` — consumed by Task 5's use cases.

`MatchRepository` is an abstract class implemented directly (not via `noSuchMethod`) by fakes in three test files (`home_controller_test.dart`, `spectator_controller_test.dart`, and **six** separate fake classes inside `score_ball_controller_test.dart`) — adding abstract methods breaks all of them at compile time unless each gets a stub override. Verified directly against the repo: `_OfflineMatchRepository`, `_MixedMatchRepository`, `_RecordingMatchRepository`, `_ServerSimulatingMatchRepository`, `_RuleBlockingMatchRepository`, `_LockTransitionMatchRepository` all `implements MatchRepository` and each has its own `getMatchHistory` override — insert the new stubs directly after each class's own `getMatchHistory` override, located by searching for that method's closing brace in each class, not by a fixed line number (line numbers drift). (`offline_sync_service_test.dart` and `result_controller_test.dart` use a `noSuchMethod`-based fake and need no change.)

- [ ] **Step 1: Add the three abstract methods to `MatchRepository`**

Add this import near the top of `lib/features/scoring/domain/repositories/match_repository.dart` (alongside the other response imports):

```dart
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
```

Insert immediately before the class's final closing `}` (right after the `deleteMatch` declaration, currently the last abstract method):

```dart

  /// `GET /v1/team` — the caller's own teams, source for the "reuse this
  /// team" picker on match creation.
  Future<Either<CricketResponse<MyTeamsRes>, CricketFailure>> getMyTeams();

  /// `GET /v1/team/:teamId` — display name plus the roster accumulated
  /// across every match this team has been attached to.
  Future<Either<CricketResponse<TeamProfileRes>, CricketFailure>>
  getTeamProfile({required String teamId});

  /// `GET /v1/team/:teamId/matches` — byte-for-byte the same response shape
  /// as [getMatchHistory], scoped to one team instead of the caller.
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>
  getTeamMatches({required String teamId, required int page, required int limit});
```

- [ ] **Step 2: Implement the three methods in `MatchRepositoryImpl`**

Add this import near the top of `lib/features/scoring/data/repositories/match_repository_impl.dart`:

```dart
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
```

Insert immediately before the class's final closing `}` (right after the `getMatchHistory` implementation):

```dart

  @override
  Future<Either<CricketResponse<MyTeamsRes>, CricketFailure>>
  getMyTeams() async {
    Either<ApiResponseModel, CricketFailure> response = await matchApiService
        .getMyTeams();
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: MyTeamsRes.fromJson(
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
  Future<Either<CricketResponse<TeamProfileRes>, CricketFailure>>
  getTeamProfile({required String teamId}) async {
    Either<ApiResponseModel, CricketFailure> response = await matchApiService
        .getTeamProfile(teamId: teamId);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: TeamProfileRes.fromJson(
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
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>
  getTeamMatches({
    required String teamId,
    required int page,
    required int limit,
  }) async {
    Either<ApiResponseModel, CricketFailure> response = await matchApiService
        .getTeamMatches(teamId: teamId, page: page, limit: limit);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: MatchHistoryRes.fromJson(
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

- [ ] **Step 3: Confirm the break — run the full suite**

Run: `flutter test`
Expected: FAIL to compile — `test/features/home/presentation/controllers/home_controller_test.dart`, `test/features/scoring/presentation/controllers/spectator_controller_test.dart`, and `test/features/scoring/presentation/controllers/score_ball_controller_test.dart` each report `Missing concrete implementation`s for `getMyTeams`, `getTeamProfile`, `getTeamMatches`.

- [ ] **Step 4: Patch `_FakeMatchRepository` in `home_controller_test.dart`**

Add the same two imports as Step 1 near the top of `test/features/home/presentation/controllers/home_controller_test.dart`.

Insert into `_FakeMatchRepository` right after its `getMatchHistory` override, immediately before the class's own closing brace:

```dart

  @override
  Future<Either<CricketResponse<MyTeamsRes>, CricketFailure>> getMyTeams() =>
      throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<TeamProfileRes>, CricketFailure>>
  getTeamProfile({required String teamId}) =>
      throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>
  getTeamMatches({
    required String teamId,
    required int page,
    required int limit,
  }) => throw UnimplementedError('Not exercised in this test.');
```

- [ ] **Step 5: Patch `_FakeMatchRepository` in `spectator_controller_test.dart`**

Add the same two imports near the top of `test/features/scoring/presentation/controllers/spectator_controller_test.dart`.

Insert right after its `getMatchHistory` override, right before the class's closing `}`, the same three-method stub block as Step 4.

- [ ] **Step 6: Patch all six fake classes in `score_ball_controller_test.dart`**

Add the same two imports near the top of `test/features/scoring/presentation/controllers/score_ball_controller_test.dart`.

This file has six classes implementing `MatchRepository` directly: `_OfflineMatchRepository`, `_MixedMatchRepository`, `_RecordingMatchRepository`, `_ServerSimulatingMatchRepository`, `_RuleBlockingMatchRepository`, `_LockTransitionMatchRepository`. Insert the same three-method stub block (as Step 4) immediately after each class's own `getMatchHistory` override — locate each by searching for `getMatchHistory({required int page, required int limit})` inside that class's body, not by line number.

- [ ] **Step 7: Run the full suite**

Run: `flutter test`
Expected: PASS — same pass count as before Task 4 started (no behavior changed, only new unreachable stubs added).

- [ ] **Step 8: Commit**

```bash
git add lib/features/scoring/domain/repositories/match_repository.dart lib/features/scoring/data/repositories/match_repository_impl.dart test/features/home/presentation/controllers/home_controller_test.dart test/features/scoring/presentation/controllers/spectator_controller_test.dart test/features/scoring/presentation/controllers/score_ball_controller_test.dart
git commit -m "feat: add team-profile reads to MatchRepository"
```

---

### Task 5: Team use cases + DI registration

**Files:**
- Create: `lib/features/scoring/domain/usecases/get_my_teams.dart`
- Create: `lib/features/scoring/domain/usecases/get_team_profile.dart`
- Create: `lib/features/scoring/domain/usecases/get_team_matches.dart`
- Modify: `lib/core/di/injection/scoring_injection.dart`
- Test: `test/features/scoring/domain/usecases/get_team_matches_test.dart`

**Interfaces:**
- Consumes: `MatchRepository.getMyTeams`/`getTeamProfile`/`getTeamMatches` (Task 4), `UseCase<T, P>` (`lib/core/usecase/usecase.dart`, `Future<T> call({P? params})`).
- Produces: `GetMyTeamsUseCase` (called as `getMyTeamsUseCase()`, no params), `GetTeamProfileUseCase`/`GetTeamProfileParams(teamId)`, `GetTeamMatchesUseCase`/`GetTeamMatchesParams(teamId, page, limit)` — consumed by Task 8's `TeamProfileController` and Task 9's `CreateMatchController`.

- [ ] **Step 1: Write `get_my_teams.dart`**

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class GetMyTeamsUseCase
    implements
        UseCase<Either<CricketResponse<MyTeamsRes>, CricketFailure>, void> {
  final MatchRepository matchRepository;

  GetMyTeamsUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<MyTeamsRes>, CricketFailure>> call({
    void params,
  }) {
    return matchRepository.getMyTeams();
  }
}
```

- [ ] **Step 2: Write `get_team_profile.dart`**

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class GetTeamProfileParams {
  final String teamId;

  GetTeamProfileParams({required this.teamId});
}

class GetTeamProfileUseCase
    implements
        UseCase<
          Either<CricketResponse<TeamProfileRes>, CricketFailure>,
          GetTeamProfileParams
        > {
  final MatchRepository matchRepository;

  GetTeamProfileUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<TeamProfileRes>, CricketFailure>> call({
    GetTeamProfileParams? params,
  }) {
    return matchRepository.getTeamProfile(teamId: params!.teamId);
  }
}
```

- [ ] **Step 3: Write `get_team_matches.dart`**

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class GetTeamMatchesParams {
  final String teamId;
  final int page;
  final int limit;

  const GetTeamMatchesParams({
    required this.teamId,
    this.page = 1,
    this.limit = 20,
  });
}

class GetTeamMatchesUseCase
    implements
        UseCase<
          Either<CricketResponse<MatchHistoryRes>, CricketFailure>,
          GetTeamMatchesParams
        > {
  final MatchRepository matchRepository;

  GetTeamMatchesUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>> call({
    GetTeamMatchesParams? params,
  }) {
    final resolved = params!;
    return matchRepository.getTeamMatches(
      teamId: resolved.teamId,
      page: resolved.page,
      limit: resolved.limit,
    );
  }
}
```

- [ ] **Step 4: Write a failing use-case test for the pagination default**

```dart
// test/features/scoring/domain/usecases/get_team_matches_test.dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingMatchRepository implements MatchRepository {
  String? lastTeamId;
  int? lastPage;
  int? lastLimit;

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>
  getTeamMatches({
    required String teamId,
    required int page,
    required int limit,
  }) async {
    lastTeamId = teamId;
    lastPage = page;
    lastLimit = limit;
    return Either.result(
      CricketResponse(
        message: 'ok',
        data: MatchHistoryRes(matches: const [], page: page, limit: limit, total: 0),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  test('forwards teamId/page/limit unchanged to the repository', () async {
    final repo = _RecordingMatchRepository();
    final useCase = GetTeamMatchesUseCase(matchRepository: repo);

    await useCase(
      params: GetTeamMatchesParams(teamId: 'team-1', page: 2, limit: 10),
    );

    expect(repo.lastTeamId, 'team-1');
    expect(repo.lastPage, 2);
    expect(repo.lastLimit, 10);
  });

  test('defaults to page 1, limit 20 when not specified', () async {
    final repo = _RecordingMatchRepository();
    final useCase = GetTeamMatchesUseCase(matchRepository: repo);

    await useCase(params: GetTeamMatchesParams(teamId: 'team-1'));

    expect(repo.lastPage, 1);
    expect(repo.lastLimit, 20);
  });
}
```

- [ ] **Step 5: Run the test**

Run: `flutter test test/features/scoring/domain/usecases/get_team_matches_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 6: Register the three use cases in `scoring_injection.dart`**

Add imports near the top of `lib/core/di/injection/scoring_injection.dart`:

```dart
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
```

Insert after the `GetMatchHistoryUseCase` registration block (locate by content — the `Get.lazyPut<GetMatchHistoryUseCase>(...)` call — not by a fixed line number, since this file already has other uncommitted edits in the working tree):

```dart

    Get.lazyPut<GetMyTeamsUseCase>(
      () => GetMyTeamsUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetTeamProfileUseCase>(
      () => GetTeamProfileUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetTeamMatchesUseCase>(
      () => GetTeamMatchesUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );
```

- [ ] **Step 7: Run the full suite**

Run: `flutter test`
Expected: PASS, no new failures.

- [ ] **Step 8: Commit**

```bash
git add lib/features/scoring/domain/usecases/get_my_teams.dart lib/features/scoring/domain/usecases/get_team_profile.dart lib/features/scoring/domain/usecases/get_team_matches.dart lib/core/di/injection/scoring_injection.dart test/features/scoring/domain/usecases/get_team_matches_test.dart
git commit -m "feat: add team-profile use cases and DI registration"
```

---

### Task 6: `CreateMatchReq` — `teamAId`/`teamBId`

**Files:**
- Modify: `lib/features/scoring/data/models/request/create_match_req.dart`
- Modify: `lib/features/scoring/data/models/request/create_match_req.g.dart` (regenerated)
- Test: `test/features/scoring/data/models/request/create_match_req_test.dart`

**Interfaces:**
- Consumes: nothing new.
- Produces: `CreateMatchReq(teamAName, teamBName, totalOvers, tossWinner, tossDecision, teamAId, teamBId)` — consumed by Task 9's `CreateMatchController`.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/scoring/data/models/request/create_match_req_test.dart
import 'package:cricket_scorer/features/scoring/data/models/request/create_match_req.dart';
import 'package:flutter_test/flutter_test.dart';

// teamAId/teamBId let a scorer reuse an existing Team instead of creating a
// new one for that side — see docs/api.md's updated "POST /v1/match/create".
void main() {
  test('toJson carries teamAId/teamBId as null when no team is reused', () {
    final req = CreateMatchReq(
      teamAName: 'Mumbai Indians',
      teamBName: 'Chennai Super Kings',
      totalOvers: 20,
    );

    final json = req.toJson();
    expect(json['teamAId'], isNull);
    expect(json['teamBId'], isNull);
  });

  test('toJson carries teamAId/teamBId when a team is reused', () {
    final req = CreateMatchReq(
      teamAName: 'Mumbai Indians',
      teamBName: 'Chennai Super Kings',
      totalOvers: 20,
      teamAId: '665f1a2b3c4d5e6f7a8b9c01',
    );

    expect(req.toJson()['teamAId'], '665f1a2b3c4d5e6f7a8b9c01');
    expect(req.toJson()['teamBId'], isNull);
  });
}
```

- [ ] **Step 2: Run it to verify it fails**

Run: `flutter test test/features/scoring/data/models/request/create_match_req_test.dart`
Expected: FAIL — `The named parameter 'teamAId' isn't defined`.

- [ ] **Step 3: Add the two optional fields**

Replace `lib/features/scoring/data/models/request/create_match_req.dart` with:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'create_match_req.g.dart';

@JsonSerializable()
class CreateMatchReq {
  final String teamAName;
  final String teamBName;
  final int totalOvers;

  /// Both null (toss skipped) or both non-null — the server rejects one
  /// without the other. `teamA` / `teamB`.
  final String? tossWinner;

  /// `bat` / `bowl`.
  final String? tossDecision;

  /// An existing, caller-owned Team id to reuse for side A instead of
  /// creating one from [teamAName] — see `GET /v1/team` for the picker
  /// source. Passing this makes [teamAName] irrelevant server-side; it is
  /// still sent because the form always has a name in the field (either
  /// typed, or auto-filled from the selected team).
  final String? teamAId;

  /// Same as [teamAId], for side B.
  final String? teamBId;

  CreateMatchReq({
    required this.teamAName,
    required this.teamBName,
    required this.totalOvers,
    this.tossWinner,
    this.tossDecision,
    this.teamAId,
    this.teamBId,
  });

  factory CreateMatchReq.fromJson(Map<String, dynamic> json) =>
      _$CreateMatchReqFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMatchReqToJson(this);
}
```

- [ ] **Step 4: Regenerate**

Run: `cd cricket-scrorer && dart run build_runner build --delete-conflicting-outputs`
Expected: `create_match_req.g.dart` now includes `teamAId`/`teamBId` in both `_$CreateMatchReqFromJson` and `_$CreateMatchReqToJson`.

- [ ] **Step 5: Run the test to verify it passes**

Run: `flutter test test/features/scoring/data/models/request/create_match_req_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/features/scoring/data/models/request/create_match_req.dart lib/features/scoring/data/models/request/create_match_req.g.dart test/features/scoring/data/models/request/create_match_req_test.dart
git commit -m "feat: add teamAId/teamBId to CreateMatchReq"
```

---

### Task 7: Extract `MatchHistoryCard` shared widget

**Files:**
- Create: `lib/features/scoring/presentation/widget/match_history_card.dart`
- Create: `test/features/scoring/presentation/widget/match_history_card_test.dart`
- Modify: `lib/features/home/presentation/pages/home_page.dart`
- Modify: `lib/config/routes/app_routes.dart`

**Interfaces:**
- Consumes: `MatchHistoryItem`/`TeamRef` (existing, `match_history_res.dart`/`create_match_res.dart`), `AppRoutes.teamProfilePath` (defined in this task's Step 0).
- Produces: `MatchHistoryCard({required MatchHistoryItem item, required VoidCallback onTap, VoidCallback? onDelete, bool Function()? isDeleting, String? highlightTeamId})` — consumed by `home_page.dart` (this task) and Task 8's `TeamProfileScreen`.

- [ ] **Step 0: Add the route constant this widget needs**

In `lib/config/routes/app_routes.dart`, insert after the `playerStatsPath` method (currently the last two lines of the class):

```dart

  /// Registered with a GetX path parameter, same shape as [playerStats].
  /// Never navigate with this constant directly — use [teamProfilePath].
  static const String teamProfile = '/team/:teamId/profile';

  static String teamProfilePath(String teamId) => '/team/$teamId/profile';
```

- [ ] **Step 1: Write `match_history_card.dart`**

```dart
import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// One row of a match-history-shaped list — used by `HomePage` (the
/// scorer's own match history, [highlightTeamId] null) and
/// `TeamProfileScreen` (past results for one team, [highlightTeamId] set to
/// that team's id) since `GET /v1/team/:teamId/matches` returns the exact
/// same [MatchHistoryItem] shape as `GET /v1/match/history`.
class MatchHistoryCard extends StatelessWidget {
  const MatchHistoryCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onDelete,
    this.isDeleting,
    this.highlightTeamId,
  });

  final MatchHistoryItem item;
  final VoidCallback onTap;

  /// Null on `TeamProfileScreen`'s list — that screen offers no delete
  /// affordance, only `HomePage`'s own history does.
  final VoidCallback? onDelete;

  /// A callback rather than a plain `bool`, same reason as before: the
  /// caller's `deletingMatchIds` is reactive and this card needs to read it
  /// live without the surrounding list rebuilding on every delete. Null
  /// whenever [onDelete] is null.
  final bool Function()? isDeleting;

  /// When set to [item.teamA]'s or [item.teamB]'s id — the team whose
  /// profile is already on screen — the title shows just the opponent
  /// ("vs Chennai Super Kings") instead of "Team A vs Team B", so
  /// `TeamProfileScreen`'s own match list doesn't repeat the name already in
  /// its header. `HomePage` passes null and always gets the full title.
  final String? highlightTeamId;

  void _openTeamProfile(String teamId) {
    Get.toNamed<dynamic>(AppRoutes.teamProfilePath(teamId));
  }

  Widget _buildTitle(BuildContext context) {
    final highlight = highlightTeamId;
    final style = context.textTheme.titleSmall;

    if (highlight == item.teamA.id || highlight == item.teamB.id) {
      final opponent = highlight == item.teamA.id ? item.teamB : item.teamA;
      return GestureDetector(
        onTap: () => _openTeamProfile(opponent.id),
        child: CricketText(
          text: 'vs ${opponent.name}',
          style: style,
          maxLines: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: GestureDetector(
            onTap: () => _openTeamProfile(item.teamA.id),
            child: CricketText(
              text: item.teamA.name,
              style: style,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        CricketText(text: ' vs ', style: style),
        Flexible(
          child: GestureDetector(
            onTap: () => _openTeamProfile(item.teamB.id),
            child: CricketText(
              text: item.teamB.name,
              style: style,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final delete = onDelete;
    final deleting = isDeleting;

    return Material(
      color: context.colorScheme.surfaceContainerHighest,
      borderRadius: 12.radius,
      child: InkWell(
        borderRadius: 12.radius,
        onTap: onTap,
        child: Padding(
          padding: 16.p,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildTitle(context)),
                  8.w,
                  _StatusBadge(status: item.status),
                  if (delete != null)
                    Obx(
                      () => (deleting?.call() ?? false)
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : IconButton(
                              tooltip: TranslationKeys.deleteMatch.tr,
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                              onPressed: delete,
                            ),
                    ),
                ],
              ),
              6.h,
              CricketText(
                text:
                    '${item.totalOvers} ${TranslationKeys.overs.tr} · '
                    '${_formatDate(item.createdAt)}',
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

  /// No `intl` dependency in this project (see pubspec.yaml) — a plain
  /// "20 Aug 2026" built from the ISO string's own fields, deliberately not
  /// locale-aware, matches every other date shown in this codebase today.
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return iso;
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'live' => (TranslationKeys.statusLive.tr, context.colors.statusInfo),
      'innings_break' => (
        TranslationKeys.statusInningsBreak.tr,
        context.colors.statusInfo,
      ),
      'completed' => (
        TranslationKeys.statusCompleted.tr,
        context.colors.statusSuccess,
      ),
      'abandoned' => (
        TranslationKeys.statusAbandoned.tr,
        context.colors.statusDanger,
      ),
      _ => (TranslationKeys.statusUpcoming.tr, context.colors.statusWarning),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: 8.radius,
      ),
      child: CricketText(
        text: label,
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Write a widget test for the tap-to-navigate behavior**

```dart
// test/features/scoring/presentation/widget/match_history_card_test.dart
import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/match_history_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

MatchHistoryItem _item() => MatchHistoryItem(
  matchId: 'match-1',
  teamA: TeamRef(id: 'team-a', name: 'Mumbai Indians'),
  teamB: TeamRef(id: 'team-b', name: 'Chennai Super Kings'),
  totalOvers: 20,
  status: 'completed',
  createdAt: '2026-08-20T10:15:00.000Z',
);

void main() {
  testWidgets('tapping teamA\'s name opens that team\'s profile, not the card\'s own onTap', (
    tester,
  ) async {
    var cardTapped = false;

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: '/home',
        getPages: [
          GetPage(
            name: '/home',
            page: () => MatchHistoryCard(
              item: _item(),
              onTap: () => cardTapped = true,
            ),
          ),
          GetPage(
            name: AppRoutes.teamProfile,
            page: () => const Scaffold(body: Text('team profile')),
          ),
        ],
      ),
    );

    await tester.tap(find.text('Mumbai Indians'));
    await tester.pumpAndSettle();

    expect(find.text('team profile'), findsOneWidget);
    expect(cardTapped, isFalse);
  });

  testWidgets('with highlightTeamId set to teamA, the title shows only the opponent', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: MatchHistoryCard(
          item: _item(),
          onTap: () {},
          highlightTeamId: 'team-a',
        ),
      ),
    );

    expect(find.text('vs Chennai Super Kings'), findsOneWidget);
    expect(find.text('Mumbai Indians'), findsNothing);
  });
}
```

- [ ] **Step 3: Run the tests**

Run: `flutter test test/features/scoring/presentation/widget/match_history_card_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 4: Update `home_page.dart` to use the shared widget**

In `lib/features/home/presentation/pages/home_page.dart`:
- Add import: `import 'package:cricket_scorer/features/scoring/presentation/widget/match_history_card.dart';`
- Delete the private `_MatchHistoryCard` class and the private `_StatusBadge` class — both now live in `match_history_card.dart`.
- Replace the `itemBuilder`'s card construction:

```dart
                  final item = controller.matches[index];
                  return _MatchHistoryCard(
                    item: item,
                    onTap: () => controller.openMatch(item),
                    onDelete: () => unawaited(_confirmDelete(controller, item)),
                    isDeleting: () =>
                        controller.deletingMatchIds.contains(item.matchId),
                  );
```
with:
```dart
                  final item = controller.matches[index];
                  return MatchHistoryCard(
                    item: item,
                    onTap: () => controller.openMatch(item),
                    onDelete: () => unawaited(_confirmDelete(controller, item)),
                    isDeleting: () =>
                        controller.deletingMatchIds.contains(item.matchId),
                  );
```

- [ ] **Step 5: Run the full suite**

Run: `flutter test`
Expected: PASS, no new failures.

- [ ] **Step 6: Verify analyze is clean**

Run: `flutter analyze lib/features/home/presentation/pages/home_page.dart lib/features/scoring/presentation/widget/match_history_card.dart`
Expected: `No issues found!` — confirms no now-unused imports were left in `home_page.dart` (it still needs `MatchHistoryItem` for `_confirmDelete`'s parameter type, so that import stays).

- [ ] **Step 7: Commit**

```bash
git add lib/config/routes/app_routes.dart lib/features/scoring/presentation/widget/match_history_card.dart test/features/scoring/presentation/widget/match_history_card_test.dart lib/features/home/presentation/pages/home_page.dart
git commit -m "refactor: extract MatchHistoryCard into a shared widget"
```

---

### Task 8: `TeamProfileScreen` — controller, binding, screen, route

**Files:**
- Create: `lib/features/scoring/presentation/controllers/team_profile_controller.dart`
- Create: `lib/features/scoring/presentation/bindings/team_profile_binding.dart`
- Create: `lib/features/scoring/presentation/pages/team_profile_screen.dart`
- Modify: `lib/config/routes/app_pages.dart`
- Modify: `lib/core/translations/translation_keys.dart`
- Modify: `lib/core/translations/en.dart`
- Modify: `lib/core/translations/hi.dart`
- Modify: `lib/core/translations/mr.dart`
- Test: `test/features/scoring/presentation/controllers/team_profile_controller_test.dart`

(`AppRoutes.teamProfile`/`teamProfilePath` were already added in Task 7, Step 0.)

**Interfaces:**
- Consumes: `GetTeamProfileUseCase`/`GetTeamProfileParams` and `GetTeamMatchesUseCase`/`GetTeamMatchesParams` (Task 5), `TeamProfileRes`/`TeamRosterPlayer` (Task 1), `MatchHistoryCard` (Task 7), `AppRoutes.playerStatsPath` (existing).
- Produces: `TeamProfileController` with `teamId` (getter), `isLoadingProfile`/`profileError`/`profile` (Rx), `matches`/`isLoadingMatches`/`isLoadingMore`/`hasMore`/`matchesError` (Rx), `loadProfile()`, `loadMatches()`, `loadMoreMatches()`, `openMatch(MatchHistoryItem)` — a self-contained screen, nothing downstream depends on it.

- [ ] **Step 1: Add the new translation keys**

In `lib/core/translations/translation_keys.dart`, insert before the class's closing `}`:

```dart

  // Team profile
  static const String teamProfile = 'team_profile';
  static const String pastResults = 'past_results';
  static const String roster = 'roster';
  static const String noRosterYet = 'no_roster_yet';
  static const String roleBatsman = 'role_batsman';
  static const String roleBowler = 'role_bowler';
  static const String roleAllrounder = 'role_allrounder';
  static const String roleWicketkeeper = 'role_wicketkeeper';
  static const String roleUnknown = 'role_unknown';
```

In `lib/core/translations/en.dart`, insert before the map's closing `};`:

```dart
  TranslationKeys.teamProfile: 'Team profile',
  TranslationKeys.pastResults: 'Past results',
  TranslationKeys.roster: 'Roster',
  TranslationKeys.noRosterYet: 'No players on this roster yet.',
  TranslationKeys.roleBatsman: 'Batsman',
  TranslationKeys.roleBowler: 'Bowler',
  TranslationKeys.roleAllrounder: 'All-rounder',
  TranslationKeys.roleWicketkeeper: 'Wicketkeeper',
  TranslationKeys.roleUnknown: 'Role unknown',
```

In `lib/core/translations/hi.dart`, insert before the map's closing `};`:

```dart
  TranslationKeys.teamProfile: 'टीम प्रोफ़ाइल',
  TranslationKeys.pastResults: 'पिछले नतीजे',
  TranslationKeys.roster: 'रोस्टर',
  TranslationKeys.noRosterYet: 'अभी इस रोस्टर में कोई खिलाड़ी नहीं है।',
  TranslationKeys.roleBatsman: 'बल्लेबाज',
  TranslationKeys.roleBowler: 'गेंदबाज',
  TranslationKeys.roleAllrounder: 'ऑलराउंडर',
  TranslationKeys.roleWicketkeeper: 'विकेटकीपर',
  TranslationKeys.roleUnknown: 'भूमिका अज्ञात',
```

In `lib/core/translations/mr.dart`, insert before the map's closing `};`:

```dart
  TranslationKeys.teamProfile: 'संघ प्रोफाइल',
  TranslationKeys.pastResults: 'मागील निकाल',
  TranslationKeys.roster: 'रोस्टर',
  TranslationKeys.noRosterYet: 'अजून या रोस्टरमध्ये कोणताही खेळाडू नाही.',
  TranslationKeys.roleBatsman: 'फलंदाज',
  TranslationKeys.roleBowler: 'गोलंदाज',
  TranslationKeys.roleAllrounder: 'अष्टपैलू',
  TranslationKeys.roleWicketkeeper: 'यष्टिरक्षक',
  TranslationKeys.roleUnknown: 'भूमिका अज्ञात',
```

- [ ] **Step 2: Write `team_profile_controller.dart`**

```dart
import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:get/get.dart';

/// The same still-live/terminal split `HomeController.openMatch` routes on —
/// duplicated here rather than shared, matching this file's own pagination
/// duplication (see class doc below).
const _liveStatuses = {'upcoming', 'live', 'innings_break'};

/// One team's profile: its identity/roster (a one-shot fetch) plus its
/// past results (a paginated list). The paginated half deliberately
/// duplicates `HomeController`'s own page/hasMore/isLoadingMore
/// hand-rolled-scroll-listener shape field-for-field, rather than sharing a
/// mixin — see the plan's design notes: extracting that logic risks
/// regressing `HomeController`'s already-shipped behavior for a shape this
/// is the only second user of.
class TeamProfileController extends GetxController {
  final GetTeamProfileUseCase getTeamProfileUseCase;
  final GetTeamMatchesUseCase getTeamMatchesUseCase;

  TeamProfileController({
    required this.getTeamProfileUseCase,
    required this.getTeamMatchesUseCase,
  });

  static const int _pageSize = 20;

  String _teamId = '';

  /// The id this screen is showing — exposed so `MatchHistoryCard` can be
  /// told which side to omit from its title (`highlightTeamId`).
  String get teamId => _teamId;

  final isLoadingProfile = true.obs;
  final profileError = Rxn<String>();
  final profile = Rxn<TeamProfileRes>();
  bool _isLoadingProfile = false;

  final matches = <MatchHistoryItem>[].obs;
  final isLoadingMatches = true.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final matchesError = Rxn<String>();
  int _page = 1;
  bool _isLoadingMatches = false;

  @override
  void onInit() {
    super.onInit();

    final teamId = Get.parameters['teamId']?.trim();
    if (teamId == null || teamId.isEmpty) {
      profileError.value = TranslationKeys.somethingWentWrong.tr;
      matchesError.value = TranslationKeys.somethingWentWrong.tr;
      isLoadingProfile.value = false;
      isLoadingMatches.value = false;
      return;
    }

    _teamId = teamId;
    unawaited(loadProfile());
    unawaited(loadMatches());
  }

  Future<void> loadProfile() async {
    if (_isLoadingProfile) return;
    _isLoadingProfile = true;
    isLoadingProfile.value = true;
    profileError.value = null;

    final response = await getTeamProfileUseCase(
      params: GetTeamProfileParams(teamId: _teamId),
    );

    isLoadingProfile.value = false;
    _isLoadingProfile = false;

    if (response.isResult) {
      profile.value = response.result.data;
    } else {
      profileError.value = response.fallback.message;
    }
  }

  /// First page, replacing whatever list is already showing — same shape as
  /// `HomeController.loadHistory`.
  Future<void> loadMatches() async {
    if (_isLoadingMatches) return;
    _isLoadingMatches = true;
    isLoadingMatches.value = true;
    matchesError.value = null;
    _page = 1;

    final response = await getTeamMatchesUseCase(
      params: GetTeamMatchesParams(teamId: _teamId, page: 1, limit: _pageSize),
    );

    isLoadingMatches.value = false;
    _isLoadingMatches = false;

    if (response.isResult) {
      final data = response.result.data;
      matches.assignAll(data?.matches ?? []);
      hasMore.value = data?.hasMore ?? false;
    } else {
      matchesError.value = response.fallback.message;
    }
  }

  /// Appends the next page — same shape as `HomeController.loadMore`.
  Future<void> loadMoreMatches() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;

    final response = await getTeamMatchesUseCase(
      params: GetTeamMatchesParams(
        teamId: _teamId,
        page: _page + 1,
        limit: _pageSize,
      ),
    );

    isLoadingMore.value = false;

    if (response.isResult) {
      final data = response.result.data;
      if (data != null) {
        matches.addAll(data.matches);
        hasMore.value = data.hasMore;
        _page += 1;
      }
    } else {
      CricketSnackbar.showErrorMessage(response.fallback.message);
    }
  }

  /// Same routing rule as `HomeController.openMatch`: still-live states
  /// reopen the scoring console, terminal ones open the result screen.
  void openMatch(MatchHistoryItem item) {
    if (_liveStatuses.contains(item.status)) {
      unawaited(
        Get.toNamed<dynamic>(
          AppRoutes.scoreBall,
          arguments: CreateMatchRes(
            matchId: item.matchId,
            joinCode: item.joinCode,
            teamA: item.teamA,
            teamB: item.teamB,
            totalOvers: item.totalOvers,
            tossWinner: item.tossWinner,
            tossDecision: item.tossDecision,
            status: item.status,
            syncStatus: 'synced',
            createdAt: item.createdAt,
          ),
        ),
      );
    } else {
      unawaited(Get.toNamed<dynamic>(AppRoutes.matchResultPath(item.matchId)));
    }
  }
}
```

- [ ] **Step 3: Write `team_profile_binding.dart`**

```dart
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_profile_controller.dart';
import 'package:get/get.dart';

class TeamProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeamProfileController>(
      () => TeamProfileController(
        getTeamProfileUseCase: Get.find<GetTeamProfileUseCase>(),
        getTeamMatchesUseCase: Get.find<GetTeamMatchesUseCase>(),
      ),
    );
  }
}
```

- [ ] **Step 4: Write `team_profile_screen.dart`**

```dart
import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_profile_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/match_history_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A team's roster plus its past results — reached by tapping a team's name
/// on a `MatchHistoryCard` (home's match history, or another team's own
/// past-results list). Not a stats page: v1 is deliberately roster + past
/// results only, no aggregate wins/losses/win% — see docs/api.md.
class TeamProfileScreen extends GetView<TeamProfileController> {
  const TeamProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.teamProfile.tr),
      body: SafeArea(
        child: Obx(() {
          final loading = controller.isLoadingProfile.value;
          final error = controller.profileError.value;
          final data = controller.profile.value;

          if (loading && data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null && data == null) {
            return _ErrorState(message: error, onRetry: controller.loadProfile);
          }
          if (data == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: () =>
                Future.wait([controller.loadProfile(), controller.loadMatches()]),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200) {
                  controller.loadMoreMatches();
                }
                return false;
              },
              child: ListView(
                padding: 16.p,
                children: [
                  _TeamHeader(profile: data),
                  24.h,
                  CricketText(
                    text: TranslationKeys.pastResults.tr,
                    style: context.textTheme.titleSmall,
                  ),
                  12.h,
                  Obx(() {
                    if (controller.isLoadingMatches.value &&
                        controller.matches.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final matchesError = controller.matchesError.value;
                    if (matchesError != null && controller.matches.isEmpty) {
                      return _ErrorState(
                        message: matchesError,
                        onRetry: controller.loadMatches,
                      );
                    }

                    if (controller.matches.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: CricketText(
                          text: TranslationKeys.noMatchesYet.tr,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return Column(
                      children: [
                        for (final item in controller.matches) ...[
                          MatchHistoryCard(
                            item: item,
                            onTap: () => controller.openMatch(item),
                            highlightTeamId: controller.teamId,
                          ),
                          12.h,
                        ],
                        if (controller.isLoadingMore.value)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
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
            CricketText(
              text: message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            24.h,
            CricketButton(
              buttonText: TranslationKeys.retry.tr,
              onPressed: () => onRetry(),
              width: 160,
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamHeader extends StatelessWidget {
  const _TeamHeader({required this.profile});

  final TeamProfileRes profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CricketText(
          text: profile.shortName == null
              ? profile.name
              : '${profile.name} (${profile.shortName})',
          style: context.textTheme.headlineSmall,
        ),
        16.h,
        CricketText(
          text: TranslationKeys.roster.tr,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        8.h,
        if (profile.roster.isEmpty)
          CricketText(text: TranslationKeys.noRosterYet.tr)
        else
          for (final player in profile.roster) ...[
            _RosterRow(player: player),
            8.h,
          ],
      ],
    );
  }
}

class _RosterRow extends StatelessWidget {
  const _RosterRow({required this.player});

  final TeamRosterPlayer player;

  String _roleLabel(String role) => switch (role) {
    'batsman' => TranslationKeys.roleBatsman.tr,
    'bowler' => TranslationKeys.roleBowler.tr,
    'allrounder' => TranslationKeys.roleAllrounder.tr,
    'wicketkeeper' => TranslationKeys.roleWicketkeeper.tr,
    _ => TranslationKeys.roleUnknown.tr,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed<dynamic>(AppRoutes.playerStatsPath(player.playerId)),
      child: Row(
        children: [
          Expanded(
            child: CricketText(
              text: player.playerName,
              style: context.textTheme.bodyMedium,
            ),
          ),
          if (player.jerseyNumber != null) ...[
            CricketText(
              text: '#${player.jerseyNumber}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            8.w,
          ],
          CricketText(
            text: _roleLabel(player.role),
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Register the route in `app_pages.dart`**

Add imports near the top of `lib/config/routes/app_pages.dart` (alongside the other scoring bindings/pages):

```dart
import 'package:cricket_scorer/features/scoring/presentation/bindings/team_profile_binding.dart';
import 'package:cricket_scorer/features/scoring/presentation/pages/team_profile_screen.dart';
```

Add a `GetPage` after the `playerStats` entry, right before the closing `];`:

```dart
    GetPage(
      name: AppRoutes.teamProfile,
      page: () => const TeamProfileScreen(),
      binding: TeamProfileBinding(),
    ),
```

- [ ] **Step 6: Write the controller unit tests**

```dart
// test/features/scoring/presentation/controllers/team_profile_controller_test.dart
import 'dart:async';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_profile_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _FakeGetTeamProfileUseCase implements GetTeamProfileUseCase {
  Either<CricketResponse<TeamProfileRes>, CricketFailure>? response;
  String? lastTeamId;

  @override
  Future<Either<CricketResponse<TeamProfileRes>, CricketFailure>> call({
    GetTeamProfileParams? params,
  }) async {
    lastTeamId = params!.teamId;
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeGetTeamMatchesUseCase implements GetTeamMatchesUseCase {
  Either<CricketResponse<MatchHistoryRes>, CricketFailure>? response;
  int callCount = 0;
  int? lastPage;

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>> call({
    GetTeamMatchesParams? params,
  }) async {
    callCount += 1;
    lastPage = params!.page;
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

MatchHistoryItem _item(String matchId) => MatchHistoryItem(
  matchId: matchId,
  teamA: TeamRef(id: 'team-1', name: 'Mumbai Indians'),
  teamB: TeamRef(id: 'team-2', name: 'Chennai Super Kings'),
  totalOvers: 20,
  status: 'completed',
  createdAt: '2026-08-20T10:15:00.000Z',
);

void main() {
  late _FakeGetTeamProfileUseCase profileUseCase;
  late _FakeGetTeamMatchesUseCase matchesUseCase;
  late TeamProfileController controller;

  setUp(() {
    Get.testMode = true;
    profileUseCase = _FakeGetTeamProfileUseCase();
    matchesUseCase = _FakeGetTeamMatchesUseCase();
    controller = TeamProfileController(
      getTeamProfileUseCase: profileUseCase,
      getTeamMatchesUseCase: matchesUseCase,
    );
  });

  tearDown(Get.reset);

  test('loadProfile populates profile on success', () async {
    profileUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: TeamProfileRes(teamId: 'team-1', name: 'Mumbai Indians', roster: const []),
      ),
    );

    await controller.loadProfile();

    expect(controller.profile.value?.name, 'Mumbai Indians');
    expect(controller.isLoadingProfile.value, isFalse);
    expect(controller.profileError.value, isNull);
  });

  test('loadProfile sets profileError on failure', () async {
    profileUseCase.response = Either.fallback(
      CricketServerErrorFailure(statusCode: 500, message: 'Server error'),
    );

    await controller.loadProfile();

    expect(controller.profile.value, isNull);
    expect(controller.profileError.value, 'Server error');
  });

  test('loadMatches populates the first page', () async {
    matchesUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: MatchHistoryRes(
          matches: [_item('match-1')],
          page: 1,
          limit: 20,
          total: 1,
        ),
      ),
    );

    await controller.loadMatches();

    expect(controller.matches.length, 1);
    expect(controller.hasMore.value, isFalse);
    expect(matchesUseCase.lastPage, 1);
  });

  test('loadMoreMatches appends the next page and advances the cursor', () async {
    matchesUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: MatchHistoryRes(
          matches: [_item('match-1')],
          page: 1,
          limit: 1,
          total: 2,
        ),
      ),
    );
    await controller.loadMatches();
    expect(controller.hasMore.value, isTrue);

    matchesUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: MatchHistoryRes(
          matches: [_item('match-2')],
          page: 2,
          limit: 1,
          total: 2,
        ),
      ),
    );
    await controller.loadMoreMatches();

    expect(controller.matches.length, 2);
    expect(controller.hasMore.value, isFalse);
    expect(matchesUseCase.lastPage, 2);
  });
}
```

- [ ] **Step 7: Run the tests**

Run: `flutter test test/features/scoring/presentation/controllers/team_profile_controller_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 8: Run the full suite**

Run: `flutter test`
Expected: PASS, no new failures.

- [ ] **Step 9: Commit**

```bash
git add lib/features/scoring/presentation/controllers/team_profile_controller.dart lib/features/scoring/presentation/bindings/team_profile_binding.dart lib/features/scoring/presentation/pages/team_profile_screen.dart lib/config/routes/app_pages.dart lib/core/translations/translation_keys.dart lib/core/translations/en.dart lib/core/translations/hi.dart lib/core/translations/mr.dart test/features/scoring/presentation/controllers/team_profile_controller_test.dart
git commit -m "feat: add team profile screen"
```

---

### Task 9: "Reuse an existing team" picker on `CreateMatchScreen`

**Files:**
- Modify: `lib/features/scoring/presentation/controllers/create_match_controller.dart`
- Modify: `lib/features/scoring/presentation/pages/create_match_screen.dart`
- Modify: `lib/features/scoring/presentation/bindings/create_match_binding.dart`
- Modify: `test/features/scoring/presentation/pages/create_match_screen_test.dart`
- Modify: `lib/core/translations/translation_keys.dart`
- Modify: `lib/core/translations/en.dart`
- Modify: `lib/core/translations/hi.dart`
- Modify: `lib/core/translations/mr.dart`
- Test: `test/features/scoring/presentation/controllers/create_match_controller_test.dart`

**Interfaces:**
- Consumes: `GetMyTeamsUseCase` (Task 5), `TeamSummary`/`MyTeamsRes` (Task 1), `CreateMatchReq.teamAId`/`teamBId` (Task 6).
- Produces: `CreateMatchController.myTeams`/`isLoadingTeams`/`selectedTeamAId`/`selectedTeamBId` (Rx), `selectTeamA(TeamSummary)`/`clearTeamASelection()`/`selectTeamB(TeamSummary)`/`clearTeamBSelection()`.

**State machine (id-selected vs free-text), unambiguous by construction:**
- Selecting a chip for team A sets `selectedTeamAId.value = team.id` and writes `team.name` into `teamAController.text`.
- A `TextEditingController` listener on `teamAController` clears `selectedTeamAId` the moment the field's text no longer equals the selected team's name — covering both manual retyping and an explicit clear.
- Tapping the already-selected chip again clears the selection and empties the field (the explicit "clear selection" action).
- `createMatch()` sends `teamAId`/`teamBId` when set (alongside `teamAName`/`teamBName`, which the server ignores for a side with an id — see docs/api.md), otherwise only the name fields, matching today's behavior exactly.

- [ ] **Step 1: Add the translation key**

In `lib/core/translations/translation_keys.dart`, insert after `teamNamesMustDiffer`:

```dart
  static const String reuseExistingTeam = 'reuse_existing_team';
```

In `lib/core/translations/en.dart`, add near the other scoring-feature strings (any position in the map is fine; append before the closing `};`):

```dart
  TranslationKeys.reuseExistingTeam: 'Use an existing team',
```

In `lib/core/translations/hi.dart`:

```dart
  TranslationKeys.reuseExistingTeam: 'मौजूदा टीम इस्तेमाल करें',
```

In `lib/core/translations/mr.dart`:

```dart
  TranslationKeys.reuseExistingTeam: 'विद्यमान संघ वापरा',
```

- [ ] **Step 2: Write the failing controller test for the id-selection state machine**

```dart
// test/features/scoring/presentation/controllers/create_match_controller_test.dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/create_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/create_match_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _UnusedCreateMatchUseCase implements CreateMatchUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeGetMyTeamsUseCase implements GetMyTeamsUseCase {
  List<TeamSummary> teams = const [];

  @override
  Future<Either<CricketResponse<MyTeamsRes>, CricketFailure>> call({
    void params,
  }) async => Either.result(
    CricketResponse(message: 'ok', data: MyTeamsRes(teams: teams)),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  late _FakeGetMyTeamsUseCase getMyTeamsUseCase;
  late CreateMatchController controller;

  setUp(() {
    Get.testMode = true;
    getMyTeamsUseCase = _FakeGetMyTeamsUseCase()
      ..teams = [
        TeamSummary(id: 'team-1', name: 'Mumbai Indians'),
        TeamSummary(id: 'team-2', name: 'Chennai Super Kings'),
      ];
    controller = CreateMatchController(
      createMatchUseCase: _UnusedCreateMatchUseCase(),
      getMyTeamsUseCase: getMyTeamsUseCase,
    );
    controller.onInit();
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  test('onInit loads the caller\'s own teams', () async {
    await Future<void>.delayed(Duration.zero);
    expect(controller.myTeams.map((t) => t.id), ['team-1', 'team-2']);
  });

  test('selecting a team sets its id and fills the name field', () async {
    await Future<void>.delayed(Duration.zero);

    controller.selectTeamA(controller.myTeams.first);

    expect(controller.selectedTeamAId.value, 'team-1');
    expect(controller.teamAController.text, 'Mumbai Indians');
  });

  test('retyping the field after a selection clears the selected id', () async {
    await Future<void>.delayed(Duration.zero);

    controller.selectTeamA(controller.myTeams.first);
    controller.teamAController.text = 'Something else';

    expect(controller.selectedTeamAId.value, isNull);
  });

  test('tapping the same chip again clears the selection and the field', () async {
    await Future<void>.delayed(Duration.zero);

    final team = controller.myTeams.first;
    controller.selectTeamA(team);
    controller.selectTeamA(team);

    expect(controller.selectedTeamAId.value, isNull);
    expect(controller.teamAController.text, isEmpty);
  });
}
```

- [ ] **Step 3: Run it to verify it fails**

Run: `flutter test test/features/scoring/presentation/controllers/create_match_controller_test.dart`
Expected: FAIL — `The named parameter 'getMyTeamsUseCase' isn't defined`.

- [ ] **Step 4: Update `CreateMatchController`**

Replace `lib/features/scoring/presentation/controllers/create_match_controller.dart` with:

```dart
import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/dialogue/custom_dialog.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_match_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/create_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateMatchController extends GetxController {
  final CreateMatchUseCase createMatchUseCase;
  final GetMyTeamsUseCase getMyTeamsUseCase;

  CreateMatchController({
    required this.createMatchUseCase,
    required this.getMyTeamsUseCase,
  });

  final teamAController = TextEditingController();
  final teamBController = TextEditingController();
  final oversController = TextEditingController();

  /// The caller's own teams, for the "reuse an existing team" chip picker.
  /// A failure loading these just leaves the picker empty — free-text team
  /// creation still works either way, so it is not surfaced as an error.
  final myTeams = <TeamSummary>[].obs;
  final isLoadingTeams = true.obs;

  /// Non-null exactly while side A's field holds a selected, existing
  /// team's own name untouched — see [_handleTeamATextChanged]. Null means
  /// free-text mode: submitting creates a brand-new team from whatever name
  /// is typed, today's original behavior.
  final selectedTeamAId = Rxn<String>();
  final selectedTeamBId = Rxn<String>();

  /// `teamA` / `teamB` / null (toss skipped — [CoinFlip] never tapped).
  /// Set only from [CoinFlip.onResult]; never tapped directly, unlike
  /// [tossDecision].
  final tossWinner = Rxn<String>();

  /// `bat` / `bowl` / null.
  final tossDecision = Rxn<String>();

  /// Called back from [CoinFlip] once a flip lands. A re-flip clears
  /// [tossDecision] too — a decision picked for the previous winner has
  /// nothing to do with whoever the coin names this time.
  void recordTossWinner(String value) {
    tossWinner.value = value;
    tossDecision.value = null;
  }

  void toggleTossDecision(String value) {
    tossDecision.value = tossDecision.value == value ? null : value;
  }

  final formKey = GlobalKey<FormState>();

  String? validateTeamName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.teamNameRequired.tr;
    }
    return null;
  }

  String? validateOvers(String? value) {
    final overs = int.tryParse(value?.trim() ?? '');
    if (overs == null || overs < 1 || overs > 50) {
      return TranslationKeys.invalidOvers.tr;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    teamAController.addListener(_handleTeamATextChanged);
    teamBController.addListener(_handleTeamBTextChanged);
    unawaited(_loadMyTeams());
  }

  Future<void> _loadMyTeams() async {
    isLoadingTeams.value = true;
    final response = await getMyTeamsUseCase();
    isLoadingTeams.value = false;
    if (response.isResult) {
      myTeams.assignAll(response.result.data?.teams ?? const []);
    }
  }

  String? _nameOf(String? teamId) {
    if (teamId == null) return null;
    for (final team in myTeams) {
      if (team.id == teamId) return team.name;
    }
    return null;
  }

  /// Clears [selectedTeamAId] the moment the field's text stops matching the
  /// selected team's own name — whether that's the scorer manually retyping
  /// over it, or [clearTeamASelection]'s own `.clear()` call. A
  /// programmatic `.text = team.name` assignment from [selectTeamA] always
  /// matches, so it never triggers this.
  void _handleTeamATextChanged() {
    final selectedId = selectedTeamAId.value;
    if (selectedId == null) return;
    if (teamAController.text != _nameOf(selectedId)) {
      selectedTeamAId.value = null;
    }
  }

  void _handleTeamBTextChanged() {
    final selectedId = selectedTeamBId.value;
    if (selectedId == null) return;
    if (teamBController.text != _nameOf(selectedId)) {
      selectedTeamBId.value = null;
    }
  }

  /// Tapping the already-selected chip again is the explicit "clear
  /// selection" action; tapping a different chip replaces the selection.
  void selectTeamA(TeamSummary team) {
    if (selectedTeamAId.value == team.id) {
      clearTeamASelection();
      return;
    }
    selectedTeamAId.value = team.id;
    teamAController.text = team.name;
  }

  void clearTeamASelection() {
    selectedTeamAId.value = null;
    teamAController.clear();
  }

  void selectTeamB(TeamSummary team) {
    if (selectedTeamBId.value == team.id) {
      clearTeamBSelection();
      return;
    }
    selectedTeamBId.value = team.id;
    teamBController.text = team.name;
  }

  void clearTeamBSelection() {
    selectedTeamBId.value = null;
    teamBController.clear();
  }

  Future<void> createMatch() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final teamAName = teamAController.text.trim();
    final teamBName = teamBController.text.trim();
    final teamAId = selectedTeamAId.value;
    final teamBId = selectedTeamBId.value;

    // Mirrors the server's own TEAM_NAMES_MUST_DIFFER rule, which also
    // fires when both sides resolve to the same team id — checked
    // explicitly here rather than relying only on the name-equality check
    // below, since that check is on the *displayed* text, not the id.
    final sameTeamSelected = teamAId != null && teamAId == teamBId;
    if (sameTeamSelected || teamAName.toLowerCase() == teamBName.toLowerCase()) {
      CricketSnackbar.showAlertMessage(TranslationKeys.teamNamesMustDiffer.tr);
      return;
    }

    // Both or neither, mirroring the server's own rule — caught here so a
    // half-filled toss never reaches the request only to bounce off
    // INVALID_TOSS_RESULT.
    if ((tossWinner.value == null) != (tossDecision.value == null)) {
      CricketSnackbar.showAlertMessage(TranslationKeys.tossIncomplete.tr);
      return;
    }

    CricketLoaderDialog.show();

    Either<CricketResponse<CreateMatchRes>, CricketFailure> response =
        await createMatchUseCase(
          params: CreateMatchReq(
            teamAName: teamAName,
            teamBName: teamBName,
            totalOvers: int.parse(oversController.text.trim()),
            tossWinner: tossWinner.value,
            tossDecision: tossDecision.value,
            teamAId: teamAId,
            teamBId: teamBId,
          ),
        );

    CricketLoaderDialog.hide();

    if (response.isResult) {
      CricketSnackbar.showSuccessMessage(response.result.message);
      unawaited(
        Get.toNamed<dynamic>(
          AppRoutes.scoreBall,
          arguments: response.result.data,
        ),
      );
    } else {
      CricketSnackbar.showAlertMessage(response.fallback.message);
    }
  }

  @override
  void onClose() {
    teamAController.dispose();
    teamBController.dispose();
    oversController.dispose();
    super.onClose();
  }
}
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `flutter test test/features/scoring/presentation/controllers/create_match_controller_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 6: Update `CreateMatchBinding`**

Replace `lib/features/scoring/presentation/bindings/create_match_binding.dart` with:

```dart
import 'package:cricket_scorer/features/scoring/domain/usecases/create_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/create_match_controller.dart';
import 'package:get/get.dart';

class CreateMatchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateMatchController>(
      () => CreateMatchController(
        createMatchUseCase: Get.find<CreateMatchUseCase>(),
        getMyTeamsUseCase: Get.find<GetMyTeamsUseCase>(),
      ),
    );
  }
}
```

- [ ] **Step 7: Update the existing `create_match_screen_test.dart` fake**

In `test/features/scoring/presentation/pages/create_match_screen_test.dart`, add imports and a fake, then supply it to the controller:

```dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
```

Add this class alongside `_UnusedCreateMatchUseCase`:

```dart
/// Returns an empty team list — this test only exercises the form's text
/// fields, never the chip picker.
class _EmptyGetMyTeamsUseCase implements GetMyTeamsUseCase {
  @override
  Future<Either<CricketResponse<MyTeamsRes>, CricketFailure>> call({
    void params,
  }) async =>
      Either.result(CricketResponse(message: 'ok', data: MyTeamsRes(teams: const [])));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}
```

Update the `Get.put<CreateMatchController>(...)` call:

```dart
      Get.put<CreateMatchController>(
        CreateMatchController(
          createMatchUseCase: _UnusedCreateMatchUseCase(),
          getMyTeamsUseCase: _EmptyGetMyTeamsUseCase(),
        ),
      );
```

- [ ] **Step 8: Run that test**

Run: `flutter test test/features/scoring/presentation/pages/create_match_screen_test.dart`
Expected: PASS (1 test) — this confirms `onInit`'s now-unawaited `_loadMyTeams()` call resolves against a real (non-throwing) fake instead of leaving an uncaught async error in the test zone.

- [ ] **Step 9: Add the chip picker to `CreateMatchScreen`**

In `lib/features/scoring/presentation/pages/create_match_screen.dart`, insert before the team A `CricketTextField` a chip row, and the same before team B's:

```dart
              Obx(() {
                if (controller.isLoadingTeams.value || controller.myTeams.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CricketText(
                      text: TranslationKeys.reuseExistingTeam.tr,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    8.h,
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final team in controller.myTeams)
                          FilterChip(
                            label: CricketText(text: team.name),
                            selected: controller.selectedTeamAId.value == team.id,
                            onSelected: (_) => controller.selectTeamA(team),
                          ),
                      ],
                    ),
                    8.h,
                  ],
                );
              }),
              CricketTextField(
                controller: controller.teamAController,
                hintText: TranslationKeys.enterTeamAName.tr,
                labelText: TranslationKeys.teamAName.tr,
                prefixIcon: const Icon(Icons.sports_cricket),
                validator: controller.validateTeamName,
                textCapitalization: TextCapitalization.words,
                // Matches Team.name's backend maxlength: 50 — without this,
                // a name over the limit passes this form cleanly and only
                // fails on the backend's own validation.
                maxLength: 50,
                isRequired: true,
              ),
              16.h,
              Obx(() {
                if (controller.isLoadingTeams.value || controller.myTeams.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CricketText(
                      text: TranslationKeys.reuseExistingTeam.tr,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    8.h,
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final team in controller.myTeams)
                          FilterChip(
                            label: CricketText(text: team.name),
                            selected: controller.selectedTeamBId.value == team.id,
                            onSelected: (_) => controller.selectTeamB(team),
                          ),
                      ],
                    ),
                    8.h,
                  ],
                );
              }),
              CricketTextField(
                controller: controller.teamBController,
                hintText: TranslationKeys.enterTeamBName.tr,
                labelText: TranslationKeys.teamBName.tr,
                prefixIcon: const Icon(Icons.sports_cricket),
                validator: controller.validateTeamName,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
                isRequired: true,
              ),
```

This replaces the previous unconditional pair of `CricketTextField`s with the same two fields, each now preceded by its own reactive chip row.

- [ ] **Step 10: Run the full suite**

Run: `flutter test`
Expected: PASS, no new failures.

- [ ] **Step 11: Verify analyze is clean**

Run: `flutter analyze lib/features/scoring/presentation/controllers/create_match_controller.dart lib/features/scoring/presentation/pages/create_match_screen.dart lib/features/scoring/presentation/bindings/create_match_binding.dart`
Expected: `No issues found!`

- [ ] **Step 12: Commit**

```bash
git add lib/features/scoring/presentation/controllers/create_match_controller.dart lib/features/scoring/presentation/pages/create_match_screen.dart lib/features/scoring/presentation/bindings/create_match_binding.dart test/features/scoring/presentation/pages/create_match_screen_test.dart test/features/scoring/presentation/controllers/create_match_controller_test.dart lib/core/translations/translation_keys.dart lib/core/translations/en.dart lib/core/translations/hi.dart lib/core/translations/mr.dart
git commit -m "feat: add existing-team picker to CreateMatchScreen"
```

---

### Task 10: Manual end-to-end verification

**Files:** none (verification only).

This app has no automated integration/E2E test harness (`test/widget_test.dart` is the stock Flutter counter smoke test, unrelated to this feature), so the final check is a manual pass on a real device or simulator, per this plan's own Global Constraints note on this repo's test conventions.

- [ ] **Step 1: Run the full test suite one more time**

Run: `flutter test`
Expected: PASS — every test from Tasks 1–9.

- [ ] **Step 2: Regenerate and analyze**

Run: `dart run build_runner build --delete-conflicting-outputs && flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Launch the app against a backend that has the three team endpoints and the extended `POST /v1/match/create` live**

Use the `run` skill or `flutter run` on a connected device/simulator with the `dev` flavor (`lib/main_dev.dart`), pointed at a backend build that already ships the "Team profile" section of `docs/api.md`.

- [ ] **Step 4: Walk match history → team profile → back**

1. Sign in and land on the home/match-history screen.
2. Confirm each card's team names are individually tappable (not the whole card).
3. Tap one team's name.
4. Confirm `TeamProfileScreen` opens, showing that team's name (and short name, if any), its roster (or the "no players" message for a team with none yet), and a paginated past-results list below.
5. Scroll the past-results list to the bottom; confirm it loads more pages when more than one page exists, and that each card shows `vs <opponent>` rather than repeating the team already at the top of the screen.
6. Tap a roster player's name; confirm it opens `PlayerStatsScreen` for that player.
7. Tap the opponent name on a past-result card; confirm it navigates to that other team's own profile.
8. Pull to refresh; confirm both the header and the results list reload.

- [ ] **Step 5: Walk match creation with an existing team**

1. Navigate to "Create match".
2. Confirm a row of chips appears above each team's name field, one chip per team already owned by the signed-in scorer (skip this check if the account has none yet — create one match first via free text, then repeat this walkthrough).
3. Tap a chip for team A; confirm the field auto-fills with that team's name and the chip shows selected.
4. Tap the same chip again; confirm the field clears and the chip deselects.
5. Re-select a chip for team A, then manually edit the text field; confirm the chip deselects (free-text mode resumed) without the text being forced back.
6. Select the same team for both A and B; confirm submitting is blocked with the "team names must differ" message.
7. Select a valid, different existing team for one or both sides and submit; confirm the match is created successfully and the created match's `teamA`/`teamB` reflect the reused team's existing id (verify via that team's own profile screen afterward — the match should now appear in its past results).

- [ ] **Step 6: Record the outcome**

If every check in Steps 4–5 passes, the feature is complete. If any step fails, file it as a follow-up rather than silently patching past this plan's task boundaries — each task above is independently reviewable and should be reopened rather than amended in place.
