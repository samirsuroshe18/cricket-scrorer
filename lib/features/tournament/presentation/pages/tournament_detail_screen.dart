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
          final fixtureRounds = _roundsInOrder(controller.fixtures);

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
                  for (final round in fixtureRounds) ...[
                    // A round genuinely is a sequence — unlike an arbitrary
                    // numbered-marker default, this divider separates real
                    // matchdays, not decoration. Skipped before round 1: the
                    // 24.h gap above the "Fixtures" header already provides
                    // that separation once.
                    if (round != fixtureRounds.first) ...[
                      Divider(height: 1, thickness: 1, color: context.colors.chipBackground),
                      12.h,
                    ],
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
    // A bye fixture shows just the advancing team's name — the status pill
    // to its right already says "Bye", so repeating that here (especially
    // as a dashed "Name — Bye" label) would be both redundant and read as
    // templated chrome rather than this app's own plain vocabulary. Keyed
    // off teamB rather than isBye so a (should-never-happen) non-bye
    // fixture with no teamB yet can't render a trailing "vs ".
    final matchupText = fixture.teamB == null
        ? fixture.teamA.name
        : '${fixture.teamA.name} ${TranslationKeys.vsLabel.tr} ${fixture.teamB!.name}';

    // A completed knockout round is a bracket — which team advanced is the
    // one thing it exists to show, so a plain "Completed" pill isn't enough
    // on its own. Bye fixtures skip this: the pill already says "Bye" for
    // the same team named in matchupText above.
    final winnerText = fixture.status == 'completed' && !fixture.isBye && fixture.winner != null
        ? '${fixture.winner!.name} ${TranslationKeys.wonLabel.tr}'
        : null;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CricketText(
                  text: matchupText,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.secondary,
                  ),
                ),
                if (winnerText != null)
                  CricketText(
                    text: winnerText,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
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
