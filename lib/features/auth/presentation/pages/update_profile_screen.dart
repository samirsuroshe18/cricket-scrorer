import 'dart:math' as math;

import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image_source.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/auth/data/profile_constants.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/update_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Display label per wire value. Kept beside the screen rather than on
/// [BattingStyle]/[BowlingStyle]/[PlayingRole], which hold wire values only
/// and must not carry UI strings — same split as `wicket_bottom_sheet.dart`'s
/// `_wicketLabels`.
const Map<String, String> _battingStyleLabels = <String, String>{
  BattingStyle.rightHanded: TranslationKeys.rightHanded,
  BattingStyle.leftHanded: TranslationKeys.leftHanded,
};

const Map<String, String> _bowlingStyleLabels = <String, String>{
  BowlingStyle.rightArmPace: TranslationKeys.rightArmPace,
  BowlingStyle.leftArmPace: TranslationKeys.leftArmPace,
  BowlingStyle.rightArmSpin: TranslationKeys.rightArmSpin,
  BowlingStyle.leftArmSpin: TranslationKeys.leftArmSpin,
};

// Reuses the exact labels `edit_player_profile_sheet.dart` already defined
// for this same `PLAYER_ROLES` enum, rather than a second, parallel set of
// keys for the same four words.
const Map<String, String> _playingRoleLabels = <String, String>{
  PlayingRole.batsman: TranslationKeys.roleBatsman,
  PlayingRole.bowler: TranslationKeys.roleBowler,
  PlayingRole.allrounder: TranslationKeys.roleAllrounder,
  PlayingRole.wicketkeeper: TranslationKeys.roleWicketkeeper,
};

// Icons are decorative shorthand for a spatial concept (which hand, which
// arm), not a claim of cricket-specific iconography Material doesn't ship —
// paired with a text label on every chip, never standing in for one.
const Map<String, IconData> _battingStyleIcons = <String, IconData>{
  BattingStyle.rightHanded: Icons.back_hand_outlined,
  BattingStyle.leftHanded: Icons.back_hand_outlined,
};
const Set<String> _mirroredBattingStyles = <String>{BattingStyle.leftHanded};

const Map<String, IconData> _bowlingStyleIcons = <String, IconData>{
  BowlingStyle.rightArmPace: Icons.bolt_outlined,
  BowlingStyle.leftArmPace: Icons.bolt_outlined,
  BowlingStyle.rightArmSpin: Icons.rotate_right,
  BowlingStyle.leftArmSpin: Icons.rotate_left,
};
const Set<String> _mirroredBowlingStyles = <String>{BowlingStyle.leftArmPace};

const Map<String, IconData> _playingRoleIcons = <String, IconData>{
  PlayingRole.batsman: Icons.sports_cricket,
  PlayingRole.bowler: Icons.adjust,
  PlayingRole.allrounder: Icons.swap_horiz,
  PlayingRole.wicketkeeper: Icons.pan_tool_outlined,
};

class UpdateProfileScreen extends GetView<UpdateProfileController> {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title:
            (controller.isEditing
                    ? TranslationKeys.myProfile
                    : TranslationKeys.completeProfile)
                .tr,
        centerTitle: true,
        // The first-time flow lands here via Get.offAllNamed with no back
        // stack — a step indicator says how close to done the user is on a
        // screen they can't otherwise back out of. Edit mode is a normal
        // pushed route the user already understands, so it's skipped there.
        bottom: controller.isEditing ? null : const _StepProgress(),
      ),
      body: Obx(() {
        if (controller.isLoadingProfile.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return _UpdateProfileForm(controller: controller);
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isLoadingProfile.value) {
          return const SizedBox.shrink();
        }
        return _BottomActionBar(controller: controller);
      }),
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: 4.radius,
              child: LinearProgressIndicator(
                value: 1,
                minHeight: 4,
                backgroundColor: scheme.surfaceContainerHighest,
                color: scheme.primary,
              ),
            ),
          ),
          10.w,
          CricketText(
            text: TranslationKeys.stepIndicatorLabel.tr,
            style: context.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateProfileForm extends StatelessWidget {
  const _UpdateProfileForm({required this.controller});

  final UpdateProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: SingleChildScrollView(
        padding: 20.p,
        child: Column(
          children: [
            if (!controller.isEditing) ...[
              CricketText(
                text: TranslationKeys.completeProfileSubtitle.tr,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              16.h,
            ],

            _AvatarPicker(controller: controller),

            24.h,

            _ProfilePreviewCard(controller: controller),

            24.h,

            /// Username
            CricketTextField(
              controller: controller.usernameController,
              hintText: TranslationKeys.enterUsername.tr,
              labelText: TranslationKeys.username.tr,
              prefixIcon: const Icon(Icons.person_outline),
              validator: controller.validateUsername,
              keyboardType: TextInputType.name,
              isRequired: true,
            ),

            20.h,

            /// Bio
            CricketTextField(
              controller: controller.bioController,
              hintText: TranslationKeys.tellUsAboutYourself.tr,
              labelText:
                  '${TranslationKeys.bio.tr} (${TranslationKeys.optionalLabel.tr})',
              prefixIcon: const Icon(Icons.person_outline),
              maxLines: 4,
              maxLength: 150,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.sentences,
            ),

            20.h,

            /// Playing role
            _SectionLabel(
              text: TranslationKeys.playingRole.tr,
              optional: true,
            ),
            8.h,
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PlayingRole.all.map((String role) {
                  return ChoiceChip(
                    avatar: Icon(_playingRoleIcons[role], size: 18),
                    label: CricketText(text: _playingRoleLabels[role]!.tr),
                    selected: controller.playingRole.value == role,
                    onSelected: (_) => controller.togglePlayingRole(role),
                  );
                }).toList(),
              ),
            ),

            20.h,

            /// Batting style
            _SectionLabel(
              text: TranslationKeys.battingStyle.tr,
              optional: true,
            ),
            8.h,
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: BattingStyle.all.map((String style) {
                  return ChoiceChip(
                    avatar: _StyleIcon(
                      icon: _battingStyleIcons[style]!,
                      mirrored: _mirroredBattingStyles.contains(style),
                    ),
                    label: CricketText(text: _battingStyleLabels[style]!.tr),
                    selected: controller.battingStyle.value == style,
                    onSelected: (_) => controller.toggleBattingStyle(style),
                  );
                }).toList(),
              ),
            ),

            20.h,

            /// Bowling style
            _SectionLabel(
              text: TranslationKeys.bowlingStyle.tr,
              optional: true,
            ),
            8.h,
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: BowlingStyle.all.map((String style) {
                  return ChoiceChip(
                    avatar: _StyleIcon(
                      icon: _bowlingStyleIcons[style]!,
                      mirrored: _mirroredBowlingStyles.contains(style),
                    ),
                    label: CricketText(text: _bowlingStyleLabels[style]!.tr),
                    selected: controller.bowlingStyle.value == style,
                    onSelected: (_) => controller.toggleBowlingStyle(style),
                  );
                }).toList(),
              ),
            ),

            20.h,

            /// Jersey number
            CricketTextField(
              controller: controller.jerseyNumberController,
              hintText: TranslationKeys.enterJerseyNumber.tr,
              labelText:
                  '${TranslationKeys.jerseyNumber.tr} (${TranslationKeys.optionalLabel.tr})',
              prefixIcon: const Icon(Icons.numbers),
              keyboardType: TextInputType.number,
              validator: controller.validateJerseyNumber,
            ),
          ],
        ),
      ),
    );
  }
}

/// A right/left-hand or right/left-arm glyph is the same [icon] mirrored —
/// cheaper and more consistent than sourcing a second icon per direction.
class _StyleIcon extends StatelessWidget {
  const _StyleIcon({required this.icon, required this.mirrored});

  final IconData icon;
  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    final child = Icon(icon, size: 18);
    if (!mirrored) return child;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(math.pi),
      child: child,
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.controller});

  final UpdateProfileController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Center(
      child: Semantics(
        button: true,
        label: TranslationKeys.addProfilePhoto.tr,
        child: GestureDetector(
          onTap: controller.pickImageBottomSheet,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Obx(() {
                final localFile = controller.selectedImage.value;
                final networkUrl = controller.existingPhotoUrl.value;
                final source = localFile != null
                    ? CricketImageSource.file(localFile.path)
                    : (networkUrl != null && networkUrl.isNotEmpty)
                    ? CricketImageSource.network(networkUrl)
                    : const CricketImageSource.file('');
                return CricketImage(
                  source: source,
                  height: 120,
                  width: 120,
                  borderRadius: const BorderRadius.all(Radius.circular(180)),
                );
              }),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.surface, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A live summary of the fields above, updating as they're filled in —
/// addresses the fact that, before this redesign, nothing filled in here was
/// ever shown back to the person filling it in (see the Home app bar avatar,
/// which now reads the same profile once it's saved).
class _ProfilePreviewCard extends StatelessWidget {
  const _ProfilePreviewCard({required this.controller});

  final UpdateProfileController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AnimatedBuilder(
      animation: Listenable.merge([
        controller.usernameController,
        controller.bioController,
        controller.jerseyNumberController,
      ]),
      builder: (context, _) {
        final username = controller.usernameController.text.trim();
        final bio = controller.bioController.text.trim();
        final jerseyNumber = controller.jerseyNumberController.text.trim();

        return Obx(() {
          final localFile = controller.selectedImage.value;
          final networkUrl = controller.existingPhotoUrl.value;
          final avatarSource = localFile != null
              ? CricketImageSource.file(localFile.path)
              : (networkUrl != null && networkUrl.isNotEmpty)
              ? CricketImageSource.network(networkUrl)
              : const CricketImageSource.file('');

          final tags = <Widget>[
            if (controller.playingRole.value case final role?)
              _PreviewTag(
                icon: _playingRoleIcons[role],
                text: _playingRoleLabels[role]!.tr,
              ),
            if (controller.battingStyle.value case final style?)
              _PreviewTag(
                icon: _battingStyleIcons[style],
                text: _battingStyleLabels[style]!.tr,
              ),
            if (controller.bowlingStyle.value case final style?)
              _PreviewTag(
                icon: _bowlingStyleIcons[style],
                text: _bowlingStyleLabels[style]!.tr,
              ),
            if (jerseyNumber.isNotEmpty)
              _PreviewTag(icon: Icons.numbers, text: '#$jerseyNumber'),
          ];

          return Container(
            padding: 16.p,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: 16.radius,
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                    6.w,
                    CricketText(
                      text: TranslationKeys.profilePreview.tr,
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                4.h,
                CricketText(
                  text: TranslationKeys.profilePreviewHint.tr,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                12.h,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CricketImage(
                      source: avatarSource,
                      height: 44,
                      width: 44,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(44),
                      ),
                    ),
                    12.w,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CricketText(
                            text: username.isEmpty
                                ? TranslationKeys.username.tr
                                : username,
                            maxLines: 1,
                            textOverflow: TextOverflow.ellipsis,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (bio.isNotEmpty) ...[
                            2.h,
                            CricketText(
                              text: bio,
                              maxLines: 2,
                              textOverflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (tags.isNotEmpty) ...[
                  10.h,
                  Wrap(spacing: 8, runSpacing: 8, children: tags),
                ],
              ],
            ),
          );
        });
      },
    );
  }
}

class _PreviewTag extends StatelessWidget {
  const _PreviewTag({required this.icon, required this.text});

  final IconData? icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: 20.radius,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: scheme.onSurfaceVariant),
            4.w,
          ],
          CricketText(
            text: text,
            style: context.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.controller});

  final UpdateProfileController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: context.colorScheme.surface),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!controller.isEditing) ...[
                CricketText(
                  text: TranslationKeys.optionalDetailsHint.tr,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                12.h,
              ],
              CricketButton(
                onPressed: controller.updateProfile,
                buttonText:
                    (controller.isEditing
                            ? TranslationKeys.saveChanges
                            : TranslationKeys.completeProfile)
                        .tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, this.optional = false});

  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CricketText(text: text, style: context.textTheme.titleSmall),
        if (optional) ...[
          6.w,
          CricketText(
            text: '(${TranslationKeys.optionalLabel.tr})',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
