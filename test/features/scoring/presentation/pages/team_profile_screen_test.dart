import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/presentation/bindings/team_profile_binding.dart';
import 'package:cricket_scorer/features/scoring/presentation/pages/team_profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

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
            roster: const [],
          ),
          'team-2': TeamProfileRes(
            teamId: 'team-2',
            name: 'Chennai Super Kings',
            roster: const [],
          ),
        }),
      );
      Get.put<GetTeamMatchesUseCase>(_EmptyMatchesUseCase());

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
}
