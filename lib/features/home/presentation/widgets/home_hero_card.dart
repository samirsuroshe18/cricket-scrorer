import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/utils/home_match_view.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/recent_ball_dots.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The one filled-red control on Home. Which of the three faces shows is the
/// dashboard's call: a match the user is scoring, a prompt to start the next
/// one, or the first-run walkthrough.
class _HeroShell extends StatelessWidget {
  const _HeroShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: context.homeCardDecoration(radius: 18, alwaysBordered: true),
      child: child,
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: CricketText(
          text: label,
          style: context.homeText(
            15,
            weight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: context.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: 12.radius),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

/// A match the signed-in user is scoring: score, overs, recent balls and a
/// single full-width way back into the console.
class ResumeScoringHero extends StatelessWidget {
  const ResumeScoringHero({
    required this.item,
    required this.onResume,
    super.key,
  });

  final MatchHistoryItem item;
  final VoidCallback onResume;

  String _tag() => switch (item.status) {
    'innings_break' => TranslationKeys.homeHeroBreak.tr,
    'upcoming' => TranslationKeys.homeHeroReady.tr,
    _ => TranslationKeys.homeHeroLive.tr,
  }.toUpperCase();

  @override
  Widget build(BuildContext context) {
    final innings = item.currentInnings;
    final isUpcoming = item.status == 'upcoming';

    return _HeroShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUpcoming
                      ? context.colors.statusWarning
                      : context.colorScheme.primary,
                ),
              ),
              6.w,
              Expanded(
                child: CricketText(
                  text: _tag(),
                  maxLines: 1,
                  textOverflow: TextOverflow.ellipsis,
                  style: context.homeText(
                    11,
                    weight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: isUpcoming
                        ? context.colors.statusWarning
                        : context.homeLiveText,
                  ),
                ),
              ),
            ],
          ),
          10.h,
          if (innings == null)
            _NotStarted(item: item)
          else
            _Score(item: item, innings: innings),
          if (innings != null && innings.recentBalls.isNotEmpty) ...[
            12.h,
            RecentBallDots(balls: innings.recentBalls),
            12.h,
          ] else
            14.h,
          _HeroButton(
            icon: isUpcoming ? Icons.sports_cricket : Icons.play_arrow_rounded,
            label: isUpcoming
                ? TranslationKeys.homeStartScoring.tr
                : TranslationKeys.homeResumeScoring.tr,
            onPressed: onResume,
          ),
        ],
      ),
    );
  }
}

class _NotStarted extends StatelessWidget {
  const _NotStarted({required this.item});

  final MatchHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CricketText(
          text: '${item.teamA.name} vs ${item.teamB.name}',
          maxLines: 2,
          textOverflow: TextOverflow.ellipsis,
          style: context.homeText(18, weight: FontWeight.w600),
        ),
        4.h,
        CricketText(
          text: TranslationKeys.homeOverMatch.trParams({
            'n': '${item.totalOvers}',
          }),
          style: context.homeText(12, color: context.homeMuted),
        ),
      ],
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({required this.item, required this.innings});

  final MatchHistoryItem item;
  final CurrentInningsSummary innings;

  @override
  Widget build(BuildContext context) {
    final batting = battingTeamName(item);
    final bowling = bowlingTeamName(item);
    final chase = chaseNeeded(item);
    final muted = context.homeMuted;

    final rightSub = chase != null
        ? TranslationKeys.homeNeedOff.trParams({
            'runs': '${chase.runsNeeded}',
            'balls': '${chase.ballsLeft}',
          })
        : (innings.inningsNumber == 1
              ? TranslationKeys.homeInningsFirst.tr
              : TranslationKeys.homeInningsSecond.tr);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (batting != null)
                CricketText(
                  text: batting,
                  maxLines: 1,
                  textOverflow: TextOverflow.ellipsis,
                  style: context.homeText(13, color: muted),
                ),
              Text.rich(
                TextSpan(
                  text: '${innings.totalRuns}',
                  children: [
                    TextSpan(
                      text: '/${innings.wickets}',
                      style: TextStyle(color: muted),
                    ),
                  ],
                ),
                style: context.homeText(
                  30,
                  weight: FontWeight.w600,
                  height: 1.1,
                  tabular: true,
                ),
              ),
              CricketText(
                text:
                    '${innings.overs} ${TranslationKeys.homeOvShort.tr} · '
                    '${TranslationKeys.homeOverMatch.trParams({'n': '${item.totalOvers}'})}',
                style: context.homeText(12, color: muted),
              ),
            ],
          ),
        ),
        8.w,
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (bowling != null)
                CricketText(
                  text: TranslationKeys.homeVsTeam.trParams({'name': bowling}),
                  maxLines: 1,
                  textOverflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: context.homeText(13, color: muted),
                ),
              4.h,
              CricketText(
                text: rightSub,
                textAlign: TextAlign.end,
                style: context.homeText(12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// No match in play: a prompt to start the next one.
class StartMatchHero extends StatelessWidget {
  const StartMatchHero({required this.onStart, super.key});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return _HeroShell(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CricketText(
              text: TranslationKeys.homeStartHeroTitle.tr,
              style: context.homeText(18, weight: FontWeight.w600),
            ),
            4.h,
            CricketText(
              text: TranslationKeys.homeStartHeroBody.tr,
              style: context.homeText(13, color: context.homeMuted),
            ),
            14.h,
            _HeroButton(
              icon: Icons.add,
              label: TranslationKeys.homeStartMatchCta.tr,
              onPressed: onStart,
            ),
          ],
        ),
      ),
    );
  }
}

/// First run: what scoring a match involves, before asking for the first one.
class FirstMatchHero extends StatelessWidget {
  const FirstMatchHero({required this.onStart, super.key});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return _HeroShell(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CricketText(
              text: TranslationKeys.homeFirstHeroTitle.tr,
              style: context.homeText(18, weight: FontWeight.w600),
            ),
            4.h,
            CricketText(
              text: TranslationKeys.homeFirstHeroBody.tr,
              style: context.homeText(13, color: context.homeMuted),
            ),
            14.h,
            _Step(
              number: 1,
              title: TranslationKeys.homeStep1Title.tr,
              body: TranslationKeys.homeStep1Body.tr,
            ),
            _Step(
              number: 2,
              title: TranslationKeys.homeStep2Title.tr,
              body: TranslationKeys.homeStep2Body.tr,
            ),
            _Step(
              number: 3,
              title: TranslationKeys.homeStep3Title.tr,
              body: TranslationKeys.homeStep3Body.tr,
            ),
            4.h,
            _HeroButton(
              icon: Icons.add,
              label: TranslationKeys.homeStartFirstCta.tr,
              onPressed: onStart,
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.title, required this.body});

  final int number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colorScheme.outline,
              ),
              child: CricketText(
                text: '$number',
                style: context.homeText(12, weight: FontWeight.w600),
              ),
            ),
          ),
          10.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CricketText(text: title, style: context.homeText(14)),
                CricketText(
                  text: body,
                  style: context.homeText(12, color: context.homeMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
