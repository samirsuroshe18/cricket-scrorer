import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/career_stats_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/player_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_career_stats.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_player.dart';
import 'package:cricket_scorer/features/scoring/presentation/bindings/player_stats_binding.dart';
import 'package:cricket_scorer/features/scoring/presentation/pages/player_stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _FakeGetCareerStatsUseCase implements GetCareerStatsUseCase {
  Either<CricketResponse<CareerStatsRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<CareerStatsRes>, CricketFailure>> call({
    GetCareerStatsParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeUpdatePlayerUseCase implements UpdatePlayerUseCase {
  Either<CricketResponse<PlayerProfileRes>, CricketFailure>? response;
  UpdatePlayerParams? lastParams;

  @override
  Future<Either<CricketResponse<PlayerProfileRes>, CricketFailure>> call({
    UpdatePlayerParams? params,
  }) async {
    lastParams = params;
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

CareerStatsRes _stats({
  String role = 'unknown',
  int? jerseyNumber,
  String? bio,
  String? battingStyle,
  String? bowlingStyle,
}) => CareerStatsRes(
  playerId: 'player-1',
  playerName: 'Rahul',
  role: role,
  jerseyNumber: jerseyNumber,
  bio: bio,
  battingStyle: battingStyle,
  bowlingStyle: bowlingStyle,
  matchesPlayed: 0,
  batting: BattingCareerStats(
    inningsBatted: 0, runs: 0, ballsFaced: 0, timesOut: 0, notOuts: 0,
    average: null, strikeRate: 0, fours: 0, sixes: 0, fifties: 0, hundreds: 0,
    highScore: null,
  ),
  bowling: BowlingCareerStats(
    inningsBowled: 0, legalDeliveries: 0, runsConceded: 0, wickets: 0,
    maidens: 0, economy: 0, bestBowling: null,
  ),
);

void main() {
  late _FakeGetCareerStatsUseCase getCareerStatsUseCase;
  late _FakeUpdatePlayerUseCase updatePlayerUseCase;

  setUp(() {
    Get.testMode = true;
    getCareerStatsUseCase = _FakeGetCareerStatsUseCase()
      ..response = Either.result(CricketResponse(message: 'ok', data: _stats()));
    updatePlayerUseCase = _FakeUpdatePlayerUseCase();
    Get.put<GetCareerStatsUseCase>(getCareerStatsUseCase);
    Get.put<UpdatePlayerUseCase>(updatePlayerUseCase);
  });

  tearDown(Get.reset);

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.playerStatsPath('player-1'),
        getPages: [
          GetPage(
            name: AppRoutes.playerStats,
            page: () => const PlayerStatsScreen(),
            binding: PlayerStatsBinding(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the player\'s profile fields alongside their stats', (tester) async {
    getCareerStatsUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: _stats(
          role: 'allrounder', jerseyNumber: 7, bio: 'Opens the batting.',
          battingStyle: 'right_handed', bowlingStyle: 'right_arm_spin',
        ),
      ),
    );

    await pumpScreen(tester);

    expect(find.text('role_allrounder'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('Opens the batting.'), findsOneWidget);
    expect(find.text('right_handed'), findsOneWidget);
    expect(find.text('right_arm_spin'), findsOneWidget);
  });

  testWidgets('editing the profile calls updatePlayer and refreshes the screen', (tester) async {
    // The edit sheet's content (role chips, jersey field, bio field,
    // batting/bowling style chips, save button) is taller than the test
    // harness's default 800x600 surface — grow it so the save button
    // actually lands within the hit-testable viewport, same as a real
    // device's taller screen would.
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '9');

    updatePlayerUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: PlayerProfileRes(
          playerId: 'player-1', playerName: 'Rahul',
          role: 'unknown', jerseyNumber: 9, bio: null,
          battingStyle: null, bowlingStyle: null,
        ),
      ),
    );
    getCareerStatsUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: _stats(jerseyNumber: 9),
      ),
    );

    await tester.ensureVisible(find.text('save_changes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('save_changes'));
    await tester.pumpAndSettle();

    expect(updatePlayerUseCase.lastParams?.playerId, 'player-1');
    expect(updatePlayerUseCase.lastParams?.req.jerseyNumber, 9);
    expect(find.text('9'), findsOneWidget);
  });
}
