import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/search/data/models/response/search_res.dart';
import 'package:cricket_scorer/features/search/domain/usecases/search.dart';
import 'package:cricket_scorer/features/search/presentation/controllers/search_controller.dart';
import 'package:cricket_scorer/features/search/presentation/pages/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _FakeSearchUseCase implements SearchUseCase {
  Either<CricketResponse<SearchRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<SearchRes>, CricketFailure>> call({
    SearchParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _FakeSearchUseCase useCase;

  setUp(() {
    Get.testMode = true;
    useCase = _FakeSearchUseCase();
    Get.put<CricketSearchController>(CricketSearchController(searchUseCase: useCase));
  });

  tearDown(Get.reset);

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.search,
        getPages: [
          GetPage(name: AppRoutes.search, page: () => const SearchScreen()),
          GetPage(
            name: AppRoutes.organizationDetail,
            page: () => const Scaffold(body: Text('org detail screen')),
          ),
          GetPage(
            name: AppRoutes.tournamentDetail,
            page: () => const Scaffold(body: Text('tournament detail screen')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> typeAndDebounce(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextFormField), text);
    await tester.pump(const Duration(milliseconds: 450));
  }

  testWidgets('shows an idle prompt before anything is typed', (tester) async {
    await pumpScreen(tester);

    expect(find.text('search_hint'), findsOneWidget);
  });

  testWidgets('shows organizations and tournaments sections after a successful search', (tester) async {
    useCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: SearchRes(
          organizations: [
            SearchOrganizationRes(id: 'org-1', name: 'Riverside CC', memberCount: 4),
          ],
          tournaments: [
            SearchTournamentRes(
              id: 'tournament-1', name: 'Summer Cup', organizationName: 'Harbor CC',
              format: 'round_robin', status: 'upcoming',
            ),
          ],
        ),
      ),
    );

    await pumpScreen(tester);
    await typeAndDebounce(tester, 'Cup');

    expect(find.text('organizations'), findsOneWidget);
    expect(find.text('Riverside CC'), findsOneWidget);
    expect(find.text('tournaments'), findsOneWidget);
    expect(find.text('Summer Cup'), findsOneWidget);
    expect(find.text('Harbor CC'), findsOneWidget);
  });

  testWidgets('shows the no-results state when a search finds nothing', (tester) async {
    useCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: SearchRes(organizations: const [], tournaments: const []),
      ),
    );

    await pumpScreen(tester);
    await typeAndDebounce(tester, 'zzz');

    expect(find.text('no_search_results_found'), findsOneWidget);
  });

  testWidgets('shows the backend error and a retry button on failure', (tester) async {
    useCase.response = Either.fallback(
      CricketServerErrorFailure(statusCode: 500, message: 'Something went wrong'),
    );

    await pumpScreen(tester);
    await typeAndDebounce(tester, 'cup');

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('retry'), findsOneWidget);
  });

  testWidgets('tapping an organization result navigates to its detail screen', (tester) async {
    useCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: SearchRes(
          organizations: [
            SearchOrganizationRes(id: 'org-1', name: 'Riverside CC', memberCount: 4),
          ],
          tournaments: const [],
        ),
      ),
    );

    await pumpScreen(tester);
    await typeAndDebounce(tester, 'river');

    await tester.tap(find.text('Riverside CC'));
    await tester.pumpAndSettle();

    expect(find.text('org detail screen'), findsOneWidget);
  });

  testWidgets('tapping a tournament result navigates to its detail screen', (tester) async {
    useCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: SearchRes(
          organizations: const [],
          tournaments: [
            SearchTournamentRes(
              id: 'tournament-1', name: 'Summer Cup', organizationName: 'Harbor CC',
              format: 'round_robin', status: 'upcoming',
            ),
          ],
        ),
      ),
    );

    await pumpScreen(tester);
    await typeAndDebounce(tester, 'summer');

    await tester.tap(find.text('Summer Cup'));
    await tester.pumpAndSettle();

    expect(find.text('tournament detail screen'), findsOneWidget);
  });
}
