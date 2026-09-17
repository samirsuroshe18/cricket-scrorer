import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/claim_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Opened only from a `cricketscorer:///claim-player/<id>?name=<name>` link
/// (see `ClaimPlayerController`'s doc comment) — never reachable from
/// in-app navigation, since nowhere in the app shows a Player's id to
/// anyone but the scorer who created it.
class ClaimPlayerScreen extends GetView<ClaimPlayerController> {
  const ClaimPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.claimPlayerTitle.tr),
      body: SafeArea(
        child: Padding(
          padding: 24.p,
          child: Center(
            child: Obx(() {
              if (controller.claimed.value) {
                return _ClaimedView(playerName: controller.playerName);
              }
              return _ConfirmView(controller: controller);
            }),
          ),
        ),
      ),
    );
  }
}

class _ConfirmView extends StatelessWidget {
  const _ConfirmView({required this.controller});

  final ClaimPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.sports_cricket_outlined,
          size: 56,
          color: context.colorScheme.primary,
        ),
        16.h,
        CricketText(
          text: TranslationKeys.claimPlayerPrompt.trParams({
            'name': controller.playerName,
          }),
          style: context.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        8.h,
        CricketText(
          text: TranslationKeys.claimPlayerHint.tr,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        24.h,
        Obx(() {
          final error = controller.errorMessage.value;
          if (error == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CricketText(
              text: error,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.statusDanger,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }),
        Obx(
          () => CricketButton(
            buttonText: TranslationKeys.claimPlayerConfirm.tr,
            onPressed: controller.isSubmitting.value
                ? null
                : controller.confirmClaim,
          ),
        ),
      ],
    );
  }
}

class _ClaimedView extends StatelessWidget {
  const _ClaimedView({required this.playerName});

  final String playerName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 56,
          color: context.colors.statusSuccess,
        ),
        16.h,
        CricketText(
          text: TranslationKeys.claimPlayerSuccess.trParams({
            'name': playerName,
          }),
          style: context.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        24.h,
        CricketButton(
          buttonText: TranslationKeys.claimPlayerGoHome.tr,
          onPressed: () => Get.offAllNamed<dynamic>(AppRoutes.home),
        ),
      ],
    );
  }
}
