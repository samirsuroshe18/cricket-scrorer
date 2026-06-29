import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnboardingController>(
      builder: (OnboardingController controller) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(.0),
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
                          Image.asset(
                            item.image,
                            color: item.color,
                            height: 260,
                          ),
                          48.h,
                          CricketText(
                            text: item.title,
                            style: context.textTheme.headlineMedium,
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
                          borderRadius: BorderRadius.circular(10),
                          color: controller.currentPage.value == index
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),

                // Buttons
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: controller.skip,
                        child: const Text('Skip'),
                      ),

                      const Spacer(),

                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.nextPage,
                          child: Text(
                            controller.currentPage.value == 2
                                ? 'Get Started'
                                : 'Next',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
