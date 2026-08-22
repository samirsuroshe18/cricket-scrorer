import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image_source.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: 24.p,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.onboardingPages.length,
                itemBuilder: (_, index) {
                  final item = controller.onboardingPages[index];

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CricketImage(
                        source: CricketImageSource.asset(item.image),
                        height: 256,
                        width: 256,
                        fit: BoxFit.contain,
                        color: item.title == 'Live Scoring'
                            ? context.colorScheme.onSurfaceVariant
                            : null,
                      ),
                      48.h,
                      CricketText(
                        text: item.title,
                        style: context.textTheme.headlineLarge,
                      ),
                      16.h,
                      CricketText(
                        text: item.description,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyLarge,
                      ),
                    ],
                  );
                },
              ),
            ),

            // Indicator
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.onboardingPages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: controller.currentPage.value == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: 10.radius,
                      color: controller.currentPage.value == index
                          ? context.colorScheme.primary
                          : context.colorScheme.outlineVariant,
                    ),
                  ),
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
                    width: 80,
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
    );
  }
}
