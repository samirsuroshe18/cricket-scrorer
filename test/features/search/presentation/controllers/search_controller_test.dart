import 'dart:async';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/search/data/models/response/search_res.dart';
import 'package:cricket_scorer/features/search/domain/usecases/search.dart';
import 'package:cricket_scorer/features/search/presentation/controllers/search_controller.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _SearchResult = Either<CricketResponse<SearchRes>, CricketFailure>;

class _FakeSearchUseCase implements SearchUseCase {
  final List<String> calledWith = [];
  final Map<String, Completer<_SearchResult>> _pending = {};

  /// Used by tests that don't care about response timing — the call
  /// resolves immediately with this value.
  _SearchResult? response;

  @override
  Future<_SearchResult> call({SearchParams? params}) {
    final query = params!.query;
    calledWith.add(query);

    final pending = _pending[query];
    if (pending != null) return pending.future;

    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return Future.value(result);
  }

  /// Registers a manually-resolvable response for [query] — lets a test
  /// control exactly when a specific in-flight request completes, which is
  /// what the stale-response test needs (resolving an earlier query's
  /// request after a later one's).
  Completer<_SearchResult> pendingFor(String query) {
    final completer = Completer<_SearchResult>();
    _pending[query] = completer;
    return completer;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

SearchOrganizationRes _org(String name) =>
    SearchOrganizationRes(id: name, name: name, memberCount: 1);

_SearchResult _success({List<SearchOrganizationRes> organizations = const []}) =>
    Either.result(
      CricketResponse(
        message: 'ok',
        data: SearchRes(organizations: organizations, tournaments: const []),
      ),
    );

void main() {
  late _FakeSearchUseCase useCase;
  late CricketSearchController controller;

  setUp(() {
    useCase = _FakeSearchUseCase()..response = _success();
    controller = CricketSearchController(
      searchUseCase: useCase,
      debounceDuration: const Duration(milliseconds: 5),
    );
  });

  tearDown(() => controller.onClose());

  test('does not call search until the debounce duration elapses', () async {
    controller.onQueryChanged('cup');

    expect(useCase.calledWith, isEmpty);

    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(useCase.calledWith, ['cup']);
  });

  test('rapid successive changes before the debounce elapses trigger only one search', () async {
    controller.onQueryChanged('c');
    controller.onQueryChanged('cu');
    controller.onQueryChanged('cup');

    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(useCase.calledWith, ['cup']);
  });

  test('clearing the query to empty resets state and never calls search', () async {
    controller.onQueryChanged('   ');

    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(useCase.calledWith, isEmpty);
    expect(controller.isLoading.value, isFalse);
    expect(controller.hasSearched.value, isFalse);
    expect(controller.organizations, isEmpty);
    expect(controller.tournaments, isEmpty);
  });

  test('a successful search populates organizations and tournaments', () async {
    useCase.response = _success(organizations: [_org('Riverside CC')]);

    controller.onQueryChanged('river');
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(controller.isLoading.value, isFalse);
    expect(controller.hasSearched.value, isTrue);
    expect(controller.error.value, isNull);
    expect(controller.organizations.map((o) => o.name), ['Riverside CC']);
  });

  test('a failed search sets the backend error message', () async {
    useCase.response = Either.fallback(
      CricketBadRequestFailure(statusCode: 400, message: 'A search term is required'),
    );

    controller.onQueryChanged('x');
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(controller.isLoading.value, isFalse);
    expect(controller.hasSearched.value, isTrue);
    expect(controller.error.value, 'A search term is required');
  });

  test('a stale response does not overwrite a newer query\'s results', () async {
    final staleCompleter = useCase.pendingFor('a');
    final currentCompleter = useCase.pendingFor('ab');

    controller.onQueryChanged('a');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    controller.onQueryChanged('ab');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    // Resolve out of order: the current query's request finishes first,
    // then the stale one finishes after — the stale one must not win.
    currentCompleter.complete(_success(organizations: [_org('AB Result')]));
    await Future<void>.delayed(Duration.zero);
    staleCompleter.complete(_success(organizations: [_org('Stale A Result')]));
    await Future<void>.delayed(Duration.zero);

    expect(controller.organizations.map((o) => o.name), ['AB Result']);
  });
}
