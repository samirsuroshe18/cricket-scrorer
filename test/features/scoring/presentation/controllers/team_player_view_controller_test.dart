import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_player_view_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/player_view_fakes.dart';

void main() {
  late FakeGetTeamPlayerView view;
  late FakeGetTeamPlayerMatches matches;
  late TeamPlayerViewController controller;

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  setUp(() {
    Get.testMode = true;
    view = FakeGetTeamPlayerView();
    matches = FakeGetTeamPlayerMatches();
    controller = TeamPlayerViewController(
      teamId: 't1',
      getTeamPlayerViewUseCase: view,
      getTeamPlayerMatchesUseCase: matches,
    );
  });

  tearDown(Get.reset);

  test('loads the profile and the first page of matches on init', () async {
    matches.byStatus['all'] = [sampleMatch('m1')];

    controller.onInit();
    await settle();

    expect(controller.profile.value?.name, 'Mumbai Indians');
    expect(controller.matches.single.matchId, 'm1');
    expect(controller.isLoadingProfile.value, isFalse);
    expect(controller.isLoadingMatches.value, isFalse);
  });

  test('a failed profile load surfaces the server message', () async {
    view.response = Either.fallback(
      CricketServerErrorFailure(message: 'not on this team'),
    );

    controller.onInit();
    await settle();

    expect(controller.profile.value, isNull);
    expect(controller.profileError.value, 'not on this team');
  });

  test('a filter chip reloads matches from page 1 with that status', () async {
    matches.byStatus['all'] = [sampleMatch('m1')];
    matches.byStatus['live'] = [sampleMatch('m2')];
    controller.onInit();
    await settle();

    await controller.setStatusFilter('live');

    expect(matches.statuses.last, 'live');
    expect(controller.statusFilter.value, 'live');
    expect(controller.matches.map((m) => m.matchId), ['m2']);
  });

  test('load more appends the next page while more remain', () async {
    matches.byStatus['all'] = [sampleMatch('m1')];
    matches.total = 25;
    controller.onInit();
    await settle();
    expect(controller.hasMore.value, isTrue);

    await controller.loadMoreMatches();

    expect(matches.pages.last, 2);
    expect(controller.matches.length, 2);
  });

  test(
    'a matches failure shows an error only when nothing is loaded',
    () async {
      matches.failure = Either.fallback(
        CricketServerErrorFailure(message: 'nope'),
      );

      controller.onInit();
      await settle();

      expect(controller.matchesError.value, 'nope');
      expect(controller.matches, isEmpty);
    },
  );

  test('an empty teamId fails fast without calling the server', () async {
    final blank = TeamPlayerViewController(
      teamId: '',
      getTeamPlayerViewUseCase: view,
      getTeamPlayerMatchesUseCase: matches,
    );

    blank.onInit();

    expect(view.calls, 0);
    expect(blank.profileError.value, isNotNull);
  });

  test('canOpen is true only for a live match with a join code', () {
    expect(controller.canOpen(sampleMatch('m', status: 'live')), isTrue);
    expect(
      controller.canOpen(sampleMatch('m', status: 'innings_break')),
      isTrue,
    );
    expect(
      controller.canOpen(sampleMatch('m', status: 'live', joinCode: null)),
      isFalse,
    );
    expect(controller.canOpen(sampleMatch('m', status: 'completed')), isFalse);
    expect(controller.canOpen(sampleMatch('m', status: 'upcoming')), isFalse);
  });
}
