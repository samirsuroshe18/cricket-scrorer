import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/onboarding_controller.dart';
import 'package:cricket_scorer/features/auth/presentation/widget/onboarding_hero_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:get/get.dart';

/// Onboarding pages max out at this width on tablets/desktop so the hero
/// card and copy don't stretch edge-to-edge on a wide window.
const _kMaxContentWidth = 480.0;

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
            child: Padding(
              padding: 24.p,
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: (index) {
                        HapticFeedback.selectionClick();
                        controller.onPageChanged(index);
                      },
                      itemCount: controller.onboardingPages.length,
                      itemBuilder: (_, index) {
                        final item = controller.onboardingPages[index];

                        return Semantics(
                          label:
                              '${TranslationKeys.onboardingPageSemanticLabel.trParams({
                                'current': '${index + 1}',
                                'total': '${controller.onboardingPages.length}',
                              })}. ${item.title}. ${item.description}',
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ExcludeSemantics(
                                        child: Obx(() {
                                          final isActive =
                                              controller.currentPage.value ==
                                              index;
                                          final motionDuration =
                                              MediaQuery.of(
                                                context,
                                              ).disableAnimations
                                              ? Duration.zero
                                              : Durations.medium2;

                                          return AnimatedOpacity(
                                            opacity: isActive ? 1 : 0,
                                            duration: motionDuration,
                                            curve: Easing.standard,
                                            child: AnimatedScale(
                                              scale: isActive ? 1 : 0.92,
                                              duration: motionDuration,
                                              curve:
                                                  Easing.emphasizedDecelerate,
                                              child: OnboardingHeroCard(
                                                pageIndex: index,
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                      48.h,
                                      ExcludeSemantics(
                                        child: CricketText(
                                          text: item.title,
                                          style:
                                              context.textTheme.headlineLarge,
                                        ),
                                      ),
                                      16.h,
                                      ExcludeSemantics(
                                        child: CricketText(
                                          text: item.description,
                                          textAlign: TextAlign.center,
                                          style: context.textTheme.bodyLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // Indicator — also doubles as tap-to-jump, so it's a real
                  // control now rather than purely decorative.
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.onboardingPages.length,
                        (index) {
                          final isCurrent =
                              controller.currentPage.value == index;
                          final dotMotionDuration =
                              MediaQuery.of(context).disableAnimations
                              ? Duration.zero
                              : Durations.medium2;

                          return Semantics(
                            button: true,
                            selected: isCurrent,
                            label: TranslationKeys.onboardingPageSemanticLabel
                                .trParams({
                                  'current': '${index + 1}',
                                  'total':
                                      '${controller.onboardingPages.length}',
                                }),
                            // 48x48 tap target around the small visual dot —
                            // the dot itself stays compact for the indicator
                            // to read lightly, but the hit area still meets
                            // the minimum touch-target size.
                            child: SizedBox.square(
                              dimension: 48,
                              child: Material(
                                type: MaterialType.transparency,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () =>
                                      controller.pageController.animateToPage(
                                        index,
                                        duration: dotMotionDuration,
                                        curve: Easing.standard,
                                      ),
                                  child: Center(
                                    child: ExcludeSemantics(
                                      child: AnimatedContainer(
                                        duration: dotMotionDuration,
                                        curve: Easing.standard,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        width: isCurrent ? 24 : 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          borderRadius: 10.radius,
                                          color: isCurrent
                                              ? context.colorScheme.primary
                                              : context
                                                    .colorScheme
                                                    .outlineVariant,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  20.h,

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: controller.skip,
                        child: CricketText(
                          text: TranslationKeys.skip.tr,
                          style: context.textTheme.bodyLarge,
                        ),
                      ),

                      Obx(
                        () => CricketButton(
                          width: 140,
                          isAutoSize: true,
                          onPressed: controller.nextPage,
                          buttonText: controller.currentPage.value == 2
                              ? TranslationKeys.getStarted.tr
                              : TranslationKeys.next.tr,
                        ),
                      ),
                    ],
                  ),
                  24.h,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Preview-only below. `OnboardingScreen` itself needs `OnboardingController`
// (GetX) plus registered translations, which the isolated Widget Previewer
// can't satisfy — the hero cards have no such dependency, so they're
// previewed directly.

@_MultiPreviewBrightness(name: 'Live scoring hero')
Widget liveScoringHeroPreview() => const ColoredBox(
  color: Colors.black12,
  child: Center(child: OnboardingHeroCard(pageIndex: 0)),
);

@_MultiPreviewBrightness(name: 'Deep match stats hero')
Widget matchStatsHeroPreview() => const ColoredBox(
  color: Colors.black12,
  child: Center(child: OnboardingHeroCard(pageIndex: 1)),
);

@_MultiPreviewBrightness(name: 'Share the victory hero')
Widget shareVictoryHeroPreview() => const ColoredBox(
  color: Colors.black12,
  child: Center(child: OnboardingHeroCard(pageIndex: 2)),
);

final class _MultiPreviewBrightness extends MultiPreview {
  const _MultiPreviewBrightness({required this.name});

  final String name;

  @override
  List<Preview> get previews => const [
    Preview(brightness: Brightness.light),
    Preview(brightness: Brightness.dark),
  ];

  @override
  List<Preview> transform() {
    return super.transform().map((preview) {
      final builder = preview.toBuilder()
        ..group = 'Onboarding screen'
        ..name = '$name — ${preview.brightness!.name}'
        ..theme = () => PreviewThemeData(
          materialLight: AppTheme.lightTheme,
          materialDark: AppTheme.darkTheme,
        );
      return builder.build();
    }).toList();
  }
}
