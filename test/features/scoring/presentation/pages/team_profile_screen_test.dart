import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/remove_team_player.dart';
import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/add_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_players.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/invite_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/lookup_user_by_email.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/set_team_leadership.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_scorer_candidates.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/assign_scorer.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team_logo.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/delete_team.dart';
import 'package:cricket_scorer/features/scoring/presentation/bindings/team_profile_binding.dart';
import 'package:cricket_scorer/features/scoring/presentation/pages/team_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:cricket_scorer/features/scoring/presentation/widget/add_player_picker.dart';
import '../helpers/picker_fakes.dart';

/// Returns whichever profile matches the requested teamId — the real
/// regression surface for the GetX lazyPut-singleton bug: a fake keyed off
/// the CONSTRUCTOR arg would pass even if the binding/screen resolved the
/// wrong tag, since a stub controller build always sees the right params.
/// Keying off what's actually REQUESTED at call time is what a wrong-tag
/// resolution (reusing team-1's controller for team-2's route) would fail.
class _MultiTeamProfileUseCase implements GetTeamProfileUseCase {
  final Map<String, TeamProfileRes> profilesByTeamId;

  _MultiTeamProfileUseCase(this.profilesByTeamId);

  @override
  Future<Either<CricketResponse<TeamProfileRes>, CricketFailure>> call({
    GetTeamProfileParams? params,
  }) async {
    return Either.result(
      CricketResponse(
        message: 'ok',
        data: profilesByTeamId[params!.teamId],
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _RecordingMatchesUseCase implements GetTeamMatchesUseCase {
  final statuses = <String>[];

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>> call({
    GetTeamMatchesParams? params,
  }) async {
    statuses.add(params!.status);
    return Either.result(
      CricketResponse(
        message: 'ok',
        data: MatchHistoryRes(matches: const [], page: 1, limit: 20, total: 0),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _EmptyMatchesUseCase implements GetTeamMatchesUseCase {
  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>> call({
    GetTeamMatchesParams? params,
  }) async {
    return Either.result(
      CricketResponse(
        message: 'ok',
        data: MatchHistoryRes(matches: const [], page: 1, limit: 20, total: 0),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

/// This test never opens the assign-scorer sheet — TeamProfileBinding just
/// needs both use cases resolvable via Get.find() for TeamProfileController
/// to construct at all.
class _UnusedGetScorerCandidatesUseCase implements GetScorerCandidatesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedAssignScorerUseCase implements AssignScorerUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedUpdateTeamLogoUseCase implements UpdateTeamLogoUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedUpdateTeamUseCase implements UpdateTeamUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedDeleteTeamUseCase implements DeleteTeamUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

/// Always succeeds — for the regression test proving the screen pops back
/// on a successful delete rather than getting stuck behind the success
/// snackbar (a GetX snackbar is itself a route; `Get.back()` called while
/// one is still open closes the snackbar, not the screen underneath it).
class _SucceedingDeleteTeamUseCase implements DeleteTeamUseCase {
  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    DeleteTeamParams? params,
  }) async {
    return Either.result(const CricketResponse(message: 'ok', data: null));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedAddTeamPlayerUseCase implements AddTeamPlayerUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedUpdateTeamPlayerUseCase implements UpdateTeamPlayerUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedSetTeamLeadershipUseCase implements SetTeamLeadershipUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

/// The roster use cases TeamProfileBinding resolves; no test here exercises them.
class _UnusedRemoveTeamPlayerUseCase implements RemoveTeamPlayerUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _RecordingRemoveTeamPlayerUseCase implements RemoveTeamPlayerUseCase {
  _RecordingRemoveTeamPlayerUseCase({this.onRemoved});

  final void Function(String playerId)? onRemoved;
  RemoveTeamPlayerParams? lastParams;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    RemoveTeamPlayerParams? params,
  }) async {
    lastParams = params;
    onRemoved?.call(params!.playerId);
    return Either.result(
      const CricketResponse<void>(message: 'ok', data: null),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void _putUnusedRosterUseCases({RemoveTeamPlayerUseCase? removePlayer}) {
  Get.put<AddTeamPlayerUseCase>(_UnusedAddTeamPlayerUseCase());
  Get.put<UpdateTeamPlayerUseCase>(_UnusedUpdateTeamPlayerUseCase());
  Get.put<SetTeamLeadershipUseCase>(_UnusedSetTeamLeadershipUseCase());
  Get.put<GetMyPlayersUseCase>(emptyMyPlayers());
  Get.put<LookupUserByEmailUseCase>(FakeLookupUserByEmailUseCase());
  Get.put<InviteTeamPlayerUseCase>(FakeInviteTeamPlayerUseCase());
  // A single Get.put call for this type per test: GetX's Get.put only
  // replaces an existing registration while it is still "dirty" (unfetched),
  // so a second Get.put for the same type is silently ignored once anything
  // has resolved it — this is why the override lives here, not as a follow-up
  // call in pumpProfile.
  Get.put<RemoveTeamPlayerUseCase>(
    removePlayer ?? _UnusedRemoveTeamPlayerUseCase(),
  );
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  // Regression test for the GetX lazyPut-singleton bug: TeamProfileController
  // used to be registered with an untagged Get.lazyPut and read teamId from
  // ambient Get.parameters inside onInit(), so navigating from one team's
  // profile to a DIFFERENT team's profile (via a MatchHistoryCard opponent
  // link, exactly like this test does) reused the first team's
  // already-initialized controller and silently rendered its data on the
  // second team's route. This drives the real binding + real route push +
  // real Get.find(tag:) resolution end to end — not two directly-constructed
  // controller instances, which a `final` field could never make collide
  // regardless of whether the tagging fix is present.
  testWidgets(
    'navigating from one team profile to another shows the second team\'s own data, not the first\'s',
    (tester) async {
      Get.put<GetTeamProfileUseCase>(
        _MultiTeamProfileUseCase({
          'team-1': TeamProfileRes(
            teamId: 'team-1',
            name: 'Mumbai Indians',
            canManage: true,
            roster: const [],
          ),
          'team-2': TeamProfileRes(
            teamId: 'team-2',
            name: 'Chennai Super Kings',
            canManage: true,
            roster: const [],
          ),
        }),
      );
      Get.put<GetTeamMatchesUseCase>(_EmptyMatchesUseCase());
      Get.put<GetScorerCandidatesUseCase>(_UnusedGetScorerCandidatesUseCase());
      Get.put<AssignScorerUseCase>(_UnusedAssignScorerUseCase());
      Get.put<UpdateTeamLogoUseCase>(_UnusedUpdateTeamLogoUseCase());
      Get.put<UpdateTeamUseCase>(_UnusedUpdateTeamUseCase());
      Get.put<DeleteTeamUseCase>(_UnusedDeleteTeamUseCase());
      _putUnusedRosterUseCases();

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          initialRoute: AppRoutes.teamProfilePath('team-1'),
          getPages: [
            GetPage(
              name: AppRoutes.teamProfile,
              page: () => const TeamProfileScreen(),
              binding: TeamProfileBinding(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mumbai Indians'), findsOneWidget);
      expect(find.text('Chennai Super Kings'), findsNothing);

      unawaited(Get.toNamed<dynamic>(AppRoutes.teamProfilePath('team-2')));
      await tester.pumpAndSettle();

      expect(find.text('Chennai Super Kings'), findsOneWidget);
      expect(find.text('Mumbai Indians'), findsNothing);
    },
  );

  testWidgets('shows the edit/delete actions when canManage is true', (
    tester,
  ) async {
    Get.put<GetTeamProfileUseCase>(
      _MultiTeamProfileUseCase({
        'team-1': TeamProfileRes(
          teamId: 'team-1',
          name: 'Mumbai Indians',
          canManage: true,
          roster: const [],
        ),
      }),
    );
    Get.put<GetTeamMatchesUseCase>(_EmptyMatchesUseCase());
    Get.put<GetScorerCandidatesUseCase>(_UnusedGetScorerCandidatesUseCase());
    Get.put<AssignScorerUseCase>(_UnusedAssignScorerUseCase());
    Get.put<UpdateTeamLogoUseCase>(_UnusedUpdateTeamLogoUseCase());
    Get.put<UpdateTeamUseCase>(_UnusedUpdateTeamUseCase());
    Get.put<DeleteTeamUseCase>(_UnusedDeleteTeamUseCase());
    _putUnusedRosterUseCases();

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.teamProfilePath('team-1'),
        getPages: [
          GetPage(
            name: AppRoutes.teamProfile,
            page: () => const TeamProfileScreen(),
            binding: TeamProfileBinding(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('hides the edit/delete actions when canManage is false', (
    tester,
  ) async {
    Get.put<GetTeamProfileUseCase>(
      _MultiTeamProfileUseCase({
        'team-1': TeamProfileRes(
          teamId: 'team-1',
          name: 'Mumbai Indians',
          canManage: false,
          roster: const [],
        ),
      }),
    );
    Get.put<GetTeamMatchesUseCase>(_EmptyMatchesUseCase());
    Get.put<GetScorerCandidatesUseCase>(_UnusedGetScorerCandidatesUseCase());
    Get.put<AssignScorerUseCase>(_UnusedAssignScorerUseCase());
    Get.put<UpdateTeamLogoUseCase>(_UnusedUpdateTeamLogoUseCase());
    Get.put<UpdateTeamUseCase>(_UnusedUpdateTeamUseCase());
    Get.put<DeleteTeamUseCase>(_UnusedDeleteTeamUseCase());
    _putUnusedRosterUseCases();

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.teamProfilePath('team-1'),
        getPages: [
          GetPage(
            name: AppRoutes.teamProfile,
            page: () => const TeamProfileScreen(),
            binding: TeamProfileBinding(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets(
    'deleting the team pops back to the previous screen, not just the snackbar',
    (tester) async {
      Get.put<GetTeamProfileUseCase>(
        _MultiTeamProfileUseCase({
          'team-1': TeamProfileRes(
            teamId: 'team-1',
            name: 'Mumbai Indians',
            canManage: true,
            roster: const [],
          ),
        }),
      );
      Get.put<GetTeamMatchesUseCase>(_EmptyMatchesUseCase());
      Get.put<GetScorerCandidatesUseCase>(_UnusedGetScorerCandidatesUseCase());
      Get.put<AssignScorerUseCase>(_UnusedAssignScorerUseCase());
      Get.put<UpdateTeamLogoUseCase>(_UnusedUpdateTeamLogoUseCase());
      Get.put<UpdateTeamUseCase>(_UnusedUpdateTeamUseCase());
      Get.put<DeleteTeamUseCase>(_SucceedingDeleteTeamUseCase());
      _putUnusedRosterUseCases();

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          initialRoute: '/home',
          getPages: [
            GetPage(
              name: '/home',
              page: () => const Scaffold(body: Text('home stub')),
            ),
            GetPage(
              name: AppRoutes.teamProfile,
              page: () => const TeamProfileScreen(),
              binding: TeamProfileBinding(),
            ),
          ],
        ),
      );
      unawaited(Get.toNamed<dynamic>(AppRoutes.teamProfilePath('team-1')));
      await tester.pumpAndSettle();
      expect(find.text('Mumbai Indians'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('delete_team').last);
      await tester.pumpAndSettle();

      expect(find.text('home stub'), findsOneWidget);
      expect(find.text('Mumbai Indians'), findsNothing);

      // Drain the success snackbar's timer before the tree is torn down.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    },
  );

  Future<void> pumpProfile(
    WidgetTester tester,
    TeamProfileRes profile, {
    GetTeamMatchesUseCase? matches,
    RemoveTeamPlayerUseCase? removePlayer,
  }) async {
    Get.put<GetTeamProfileUseCase>(
      _MultiTeamProfileUseCase({'team-1': profile}),
    );
    Get.put<GetTeamMatchesUseCase>(matches ?? _EmptyMatchesUseCase());
    Get.put<GetScorerCandidatesUseCase>(_UnusedGetScorerCandidatesUseCase());
    Get.put<AssignScorerUseCase>(_UnusedAssignScorerUseCase());
    Get.put<UpdateTeamLogoUseCase>(_UnusedUpdateTeamLogoUseCase());
    Get.put<UpdateTeamUseCase>(_UnusedUpdateTeamUseCase());
    Get.put<DeleteTeamUseCase>(_UnusedDeleteTeamUseCase());
    _putUnusedRosterUseCases(removePlayer: removePlayer);

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.teamProfilePath('team-1'),
        getPages: [
          GetPage(
            name: AppRoutes.teamProfile,
            page: () => const TeamProfileScreen(),
            binding: TeamProfileBinding(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  TeamProfileRes profileWith({
    bool canManage = true,
    TeamStatsRes? stats,
    List<TeamRosterPlayer> roster = const [],
    String? captainId,
    String? viceCaptainId,
  }) => TeamProfileRes(
    teamId: 'team-1',
    name: 'Mumbai Indians',
    canManage: canManage,
    roster: roster,
    stats: stats,
    captainId: captainId,
    viceCaptainId: viceCaptainId,
  );

  testWidgets('labels the match list Matches, not Past results', (
    tester,
  ) async {
    await pumpProfile(tester, profileWith());

    expect(find.text(TranslationKeys.teamMatchesSection), findsOneWidget);
    expect(find.text(TranslationKeys.pastResults), findsNothing);
  });

  testWidgets('shows the four filter chips and loads All first', (
    tester,
  ) async {
    final matches = _RecordingMatchesUseCase();
    await pumpProfile(tester, profileWith(), matches: matches);

    expect(find.text(TranslationKeys.filterAll), findsOneWidget);
    expect(find.text(TranslationKeys.statusLive), findsOneWidget);
    expect(find.text(TranslationKeys.statusUpcoming), findsOneWidget);
    expect(find.text(TranslationKeys.statusCompleted), findsOneWidget);
    expect(matches.statuses, ['all']);
  });

  testWidgets('tapping a filter chip requests that status', (tester) async {
    final matches = _RecordingMatchesUseCase();
    await pumpProfile(tester, profileWith(), matches: matches);

    await tester.tap(find.text(TranslationKeys.statusLive));
    await tester.pumpAndSettle();
    await tester.tap(find.text(TranslationKeys.statusCompleted));
    await tester.pumpAndSettle();

    expect(matches.statuses, ['all', 'live', 'completed']);
  });

  testWidgets('shows the stats strip when the team has played', (tester) async {
    await pumpProfile(
      tester,
      profileWith(
        stats: TeamStatsRes(
          played: 12,
          won: 7,
          lost: 4,
          tied: 1,
          noResult: 0,
          winPercentage: 58.3,
          form: const ['W', 'L'],
        ),
      ),
    );

    expect(find.text('58.3%'), findsOneWidget);
  });

  testWidgets('shows no stats strip for a legacy payload without stats', (
    tester,
  ) async {
    await pumpProfile(tester, profileWith());

    expect(find.text(TranslationKeys.recentForm), findsNothing);
    expect(find.text(TranslationKeys.winPercentage), findsNothing);
  });

  testWidgets('roster shows C and VC badges for the team leaders', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      profileWith(
        captainId: 'p1',
        viceCaptainId: 'p2',
        roster: [
          TeamRosterPlayer(
            playerId: 'p1',
            playerName: 'Rohit',
            role: 'batsman',
            isCaptain: true,
          ),
          TeamRosterPlayer(
            playerId: 'p2',
            playerName: 'Hardik',
            role: 'allrounder',
            isViceCaptain: true,
          ),
          TeamRosterPlayer(
            playerId: 'p3',
            playerName: 'Bumrah',
            role: 'bowler',
          ),
        ],
      ),
    );

    expect(find.text(TranslationKeys.captainShort), findsOneWidget);
    expect(find.text(TranslationKeys.viceCaptainShort), findsOneWidget);
  });

  testWidgets('roster shows the Invited chip only for a pending invite', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      profileWith(
        roster: [
          TeamRosterPlayer(
            playerId: 'p1',
            playerName: 'Rahul',
            role: 'batsman',
            inviteStatus: 'pending',
          ),
          TeamRosterPlayer(
            playerId: 'p2',
            playerName: 'Rohit',
            role: 'batsman',
          ),
        ],
      ),
    );

    expect(find.text(TranslationKeys.invited), findsOneWidget);
  });

  testWidgets('a manager sees add player and a menu on each roster row', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      profileWith(
        roster: [
          TeamRosterPlayer(
            playerId: 'p1',
            playerName: 'Rohit',
            role: 'batsman',
          ),
        ],
      ),
    );

    expect(find.text(TranslationKeys.addPlayer), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });

  testWidgets(
    'add player and the row menu are hidden when canManage is false',
    (
      tester,
    ) async {
      await pumpProfile(
        tester,
        profileWith(
          canManage: false,
          roster: [
            TeamRosterPlayer(
              playerId: 'p1',
              playerName: 'Rohit',
              role: 'batsman',
            ),
          ],
        ),
      );

      expect(find.text(TranslationKeys.addPlayer), findsNothing);
      expect(find.byIcon(Icons.more_vert), findsNothing);
    },
  );

  testWidgets(
    'the row menu opens Edit and Remove from team, and Edit opens the edit sheet',
    (tester) async {
      await pumpProfile(
        tester,
        profileWith(
          roster: [
            TeamRosterPlayer(
              playerId: 'p1',
              playerName: 'Rohit',
              role: 'batsman',
            ),
          ],
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text(TranslationKeys.editPlayer), findsOneWidget);
      expect(find.text(TranslationKeys.removeFromTeam), findsOneWidget);

      await tester.tap(find.text(TranslationKeys.editPlayer));
      await tester.pumpAndSettle();

      expect(find.text(TranslationKeys.editPlayer), findsWidgets);
      expect(find.byType(CricketTextField), findsWidgets);
    },
  );

  testWidgets(
    'Remove from team asks for confirmation and does nothing on Cancel',
    (tester) async {
      await pumpProfile(
        tester,
        profileWith(
          roster: [
            TeamRosterPlayer(
              playerId: 'p1',
              playerName: 'Rohit',
              role: 'batsman',
            ),
          ],
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text(TranslationKeys.removeFromTeam));
      await tester.pumpAndSettle();

      expect(
        find.text(TranslationKeys.removeFromTeamConfirmTitle),
        findsOneWidget,
      );

      await tester.tap(find.text(TranslationKeys.cancel));
      await tester.pumpAndSettle();

      expect(find.text('Rohit'), findsOneWidget);
    },
  );

  testWidgets(
    'confirming Remove from team calls the use case and the player is gone',
    (tester) async {
      // A mutable backing map: the profile use case reads whatever is
      // current in it, and the remove use case fake writes the
      // player-removed profile into it on success — the same shape a real
      // reload-after-write sees.
      final profiles = {
        'team-1': profileWith(
          roster: [
            TeamRosterPlayer(
              playerId: 'p1',
              playerName: 'Rohit',
              role: 'batsman',
            ),
          ],
        ),
      };
      final removeUseCase = _RecordingRemoveTeamPlayerUseCase(
        onRemoved: (playerId) =>
            profiles['team-1'] = profileWith(roster: const []),
      );
      Get.put<GetTeamProfileUseCase>(_MultiTeamProfileUseCase(profiles));
      Get.put<GetTeamMatchesUseCase>(_EmptyMatchesUseCase());
      Get.put<GetScorerCandidatesUseCase>(_UnusedGetScorerCandidatesUseCase());
      Get.put<AssignScorerUseCase>(_UnusedAssignScorerUseCase());
      Get.put<UpdateTeamLogoUseCase>(_UnusedUpdateTeamLogoUseCase());
      Get.put<UpdateTeamUseCase>(_UnusedUpdateTeamUseCase());
      Get.put<DeleteTeamUseCase>(_UnusedDeleteTeamUseCase());
      _putUnusedRosterUseCases(removePlayer: removeUseCase);

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          initialRoute: AppRoutes.teamProfilePath('team-1'),
          getPages: [
            GetPage(
              name: AppRoutes.teamProfile,
              page: () => const TeamProfileScreen(),
              binding: TeamProfileBinding(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text(TranslationKeys.removeFromTeam));
      await tester.pumpAndSettle();
      await tester.tap(find.text(TranslationKeys.removeFromTeam).last);
      await tester.pumpAndSettle();

      expect(removeUseCase.lastParams?.playerId, 'p1');
      expect(find.text('Rohit'), findsNothing);

      // Drain the success snackbar's timer before the tree is torn down.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('tapping add player opens the add player sheet', (tester) async {
    await pumpProfile(tester, profileWith());

    await tester.tap(find.text(TranslationKeys.addPlayer));
    await tester.pumpAndSettle();

    expect(find.byType(AddPlayerPicker), findsOneWidget);
    expect(find.text(TranslationKeys.createNewPlayer), findsOneWidget);
  });
}
