import 'dart:math' as math;

import 'package:cricket_scorer/config/theme/app_theme.dart';
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
import 'package:flutter/widget_previews.dart';
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
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 14),
      child: Row(
        children: [
          // Onboarding is exactly three screens (register, verify OTP,
          // this one) and this screen is always the last of them — two
          // done segments plus one current, never parameterized.
          const Expanded(child: _StepSegment(done: true)),
          8.w,
          const Expanded(child: _StepSegment(done: true)),
          8.w,
          const Expanded(child: _StepSegment(done: false)),
          10.w,
          CricketText(
            text: TranslationKeys.stepIndicatorLabel.tr,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// One segment of the onboarding step indicator — solid once that step is
/// behind you, a soft tint while you're on it. Replaces a single bar drawn
/// at full value under a "Step 3 of 3" caption, which read as already
/// finished rather than in progress.
class _StepSegment extends StatelessWidget {
  const _StepSegment({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: done ? primary : primary.withValues(alpha: 0.25),
        borderRadius: 4.radius,
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: 20.p,
              child: AutofillGroup(
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
                      autofillHints: const [AutofillHints.newUsername],
                      isRequired: true,
                    ),

                    20.h,

                    /// Bio
                    CricketTextField(
                      controller: controller.bioController,
                      hintText: TranslationKeys.tellUsAboutYourself.tr,
                      labelText:
                          '${TranslationKeys.bio.tr} (${TranslationKeys.optionalLabel.tr})',
                      prefixIcon: const Icon(Icons.description_outlined),
                      maxLines: 4,
                      maxLength: 150,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    24.h,

                    // Plain text/label content shrink-wraps to its own
                    // width, so it follows this Column's cross-axis
                    // alignment rather than the full-width text fields
                    // above (which fill the row regardless) — scoped to
                    // just this section rather than changed on the outer
                    // Column, which would also pull the centered avatar
                    // and subtitle over to the left.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Playing role / batting style / bowling style —
                        /// one section instead of three separately-labeled
                        /// ones, each repeating "(Optional)"; the section
                        /// subtitle says that once for all three.
                        CricketText(
                          text: TranslationKeys.aboutYourGame.tr,
                          style: context.textTheme.titleSmall,
                        ),
                        CricketText(
                          text: TranslationKeys.aboutYourGameHint.tr,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),

                        16.h,

                        /// Playing role
                        _SectionLabel(text: TranslationKeys.playingRole.tr),
                        8.h,
                        Obx(
                          () => Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: PlayingRole.all.map((String role) {
                              return ChoiceChip(
                                avatar: Icon(
                                  _playingRoleIcons[role],
                                  size: 18,
                                ),
                                label: CricketText(
                                  text: _playingRoleLabels[role]!.tr,
                                ),
                                selected: controller.playingRole.value == role,
                                onSelected: (_) =>
                                    controller.togglePlayingRole(role),
                              );
                            }).toList(),
                          ),
                        ),

                        16.h,

                        /// Batting style
                        _SectionLabel(text: TranslationKeys.battingStyle.tr),
                        8.h,
                        Obx(
                          () => Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: BattingStyle.all.map((String style) {
                              return ChoiceChip(
                                avatar: _StyleIcon(
                                  icon: _battingStyleIcons[style]!,
                                  mirrored: _mirroredBattingStyles.contains(
                                    style,
                                  ),
                                ),
                                label: CricketText(
                                  text: _battingStyleLabels[style]!.tr,
                                ),
                                selected:
                                    controller.battingStyle.value == style,
                                onSelected: (_) =>
                                    controller.toggleBattingStyle(style),
                              );
                            }).toList(),
                          ),
                        ),

                        16.h,

                        /// Bowling style
                        _SectionLabel(text: TranslationKeys.bowlingStyle.tr),
                        8.h,
                        Obx(
                          () => Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: BowlingStyle.all.map((String style) {
                              return ChoiceChip(
                                avatar: _StyleIcon(
                                  icon: _bowlingStyleIcons[style]!,
                                  mirrored: _mirroredBowlingStyles.contains(
                                    style,
                                  ),
                                ),
                                label: CricketText(
                                  text: _bowlingStyleLabels[style]!.tr,
                                ),
                                selected:
                                    controller.bowlingStyle.value == style,
                                onSelected: (_) =>
                                    controller.toggleBowlingStyle(style),
                              );
                            }).toList(),
                          ),
                        ),

                        20.h,

                        /// Jersey number — a compact stepper rather than a
                        /// full-width text field: this value reads as a
                        /// small count (0-999), not a line of text, so it
                        /// gets a control sized and shaped like one, with
                        /// direct typing still available in the middle.
                        _JerseySection(controller: controller),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                return AnimatedSwitcher(
                  duration: Durations.medium2,
                  switchInCurve: Easing.standard,
                  // CricketImageSource has no `==` override, so the key is
                  // built from its fields rather than the instance itself —
                  // keying on the instance would key by identity and
                  // cross-fade on every rebuild, not just on a real change.
                  child: CricketImage(
                    key: ValueKey('${source.type}:${source.path}'),
                    source: source,
                    height: 120,
                    width: 120,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(180),
                    ),
                  ),
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
    final motionDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : Durations.medium2;
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
          ];

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
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
                        // Purely a visual echo of the avatar already
                        // labeled and controlled above — excluded so a
                        // screen reader doesn't announce a second,
                        // unlabeled image node.
                        ExcludeSemantics(
                          child: CricketImage(
                            source: avatarSource,
                            height: 44,
                            width: 44,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(44),
                            ),
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
              ),
              // The squad number reads as a real jersey badge — pinned to
              // the card's corner like a printed patch — rather than
              // getting lost as one more pill in the tag row below it. Kept
              // in the tree (not `if`-conditional) so it can pop in/out as
              // the field is typed instead of appearing with no transition.
              // Excluded from semantics for the same reason as the avatar
              // thumbnail above: it's a decorative echo of the actual
              // jersey-number field, and a screen reader announcing a bare
              // "7" with no label would be more confusing than saying
              // nothing — the labeled value already reads fine from the
              // field itself.
              Positioned(
                top: -12,
                right: 14,
                child: ExcludeSemantics(
                  child: AnimatedScale(
                    scale: jerseyNumber.isEmpty ? 0.6 : 1,
                    duration: motionDuration,
                    curve: Easing.emphasizedDecelerate,
                    child: AnimatedOpacity(
                      opacity: jerseyNumber.isEmpty ? 0 : 1,
                      duration: motionDuration,
                      curve: Easing.standard,
                      child: _JerseyBadge(number: jerseyNumber),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }
}

/// The squad-number patch pinned to the preview card's corner — reuses the
/// existing `valueIndicator` navy token (already the slider's value-bubble
/// color) rather than introducing a new one, with the same white-on-navy
/// pairing `CustomSelectionTheme`'s `valueIndicatorTextStyle` already uses.
class _JerseyBadge extends StatelessWidget {
  const _JerseyBadge({required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      padding: 8.p,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colors.valueIndicator,
        borderRadius: 12.radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      // A minimum rather than a fixed size — a 3-digit number, or a large
      // iOS/Android text-scale setting, grows the badge instead of clipping
      // against a hard 44x44 box.
      child: CricketText(
        text: number,
        maxLines: 1,
        style: context.textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
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
        // Scaffold gives bottomNavigationBar a loose-but-finite height
        // constraint (up to its own full height), so a bare Center would
        // expand to fill that instead of shrink-wrapping this bar's actual
        // content — starving `body` of height in the process.
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: 16,
              ),
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
        ),
      ),
    );
  }
}

/// A field-group label within "About your game" — no per-label
/// "(Optional)" any more, since that section's own subtitle already says
/// all of it is optional once, rather than three times.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return CricketText(text: text, style: context.textTheme.titleSmall);
  }
}

/// Jersey number as a compact increment/decrement control rather than a
/// full-width text field — the value is a small count (0-999), not a line
/// of text, so it gets a control sized and shaped like one. The digits
/// stay directly editable in the middle for a custom number.
class _JerseySection extends StatelessWidget {
  const _JerseySection({required this.controller});

  final UpdateProfileController controller;

  void _step(int delta) {
    final current =
        int.tryParse(controller.jerseyNumberController.text.trim()) ?? 0;
    final next = (current + delta).clamp(0, 999);
    controller.jerseyNumberController.text = '$next';
  }

  @override
  Widget build(BuildContext context) {
    final label =
        '${TranslationKeys.jerseyNumber.tr} (${TranslationKeys.optionalLabel.tr})';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CricketText(text: label, style: context.textTheme.bodyMedium),
        8.h,
        // The visible label above is a plain CricketText rather than
        // InputDecoration's floating label — that label needs the field's
        // full (much wider) width to sit comfortably; this field is
        // deliberately narrow. `Semantics` restores the same accessible
        // name InputDecoration.label would otherwise have provided.
        Semantics(
          label: label,
          child: SizedBox(
            width: 190,
            child: TextFormField(
              controller: controller.jerseyNumberController,
              validator: controller.validateJerseyNumber,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium,
              decoration: InputDecoration(
                isDense: true,
                hintText: '0',
                prefixIcon: _StepperButton(
                  icon: Icons.remove,
                  tooltip: TranslationKeys.decreaseJerseyNumber.tr,
                  onPressed: () => _step(-1),
                ),
                suffixIcon: _StepperButton(
                  icon: Icons.add,
                  tooltip: TranslationKeys.increaseJerseyNumber.tr,
                  onPressed: () => _step(1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      visualDensity: VisualDensity.compact,
      color: context.colorScheme.onSurfaceVariant,
    );
  }
}

// Preview-only below. `_UpdateProfileForm`/`_AvatarPicker`/
// `_ProfilePreviewCard`/`_BottomActionBar` all read from
// `UpdateProfileController` via `Get.find()`, which needs a live GetX
// binding the isolated Widget Previewer can't satisfy — same constraint
// `login_screen.dart` documents for `AuthScoreboardHeader`. `_StepProgress`,
// `_SectionLabel`, `_StyleIcon`, `_PreviewTag` and `_JerseyBadge` take no
// controller, so those are what's previewable here.

@_MultiPreviewBrightness(name: 'Step progress')
Widget stepProgressPreview() => const _StepProgress();

@_MultiPreviewBrightness(name: 'Section label')
Widget sectionLabelPreview() => Padding(
  padding: const EdgeInsets.all(16),
  child: _SectionLabel(text: TranslationKeys.battingStyle.tr),
);

@_MultiPreviewBrightness(name: 'Style icons')
Widget styleIconsPreview() => const Padding(
  padding: EdgeInsets.all(16),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _StyleIcon(icon: Icons.back_hand_outlined, mirrored: false),
      SizedBox(width: 12),
      _StyleIcon(icon: Icons.back_hand_outlined, mirrored: true),
      SizedBox(width: 12),
      _StyleIcon(icon: Icons.rotate_right, mirrored: false),
      SizedBox(width: 12),
      _StyleIcon(icon: Icons.rotate_left, mirrored: false),
    ],
  ),
);

@_MultiPreviewBrightness(name: 'Preview tags')
Widget previewTagsPreview() => const Padding(
  padding: EdgeInsets.all(16),
  child: Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      _PreviewTag(icon: Icons.sports_cricket, text: 'Batsman'),
      _PreviewTag(icon: Icons.back_hand_outlined, text: 'Right handed'),
      _PreviewTag(icon: Icons.numbers, text: '#7'),
    ],
  ),
);

@_MultiPreviewBrightness(name: 'Jersey badge')
Widget jerseyBadgePreview() => const Padding(
  padding: EdgeInsets.all(16),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _JerseyBadge(number: '7'),
      SizedBox(width: 12),
      // A 3-digit number is the widest real value `validateJerseyNumber`
      // allows (0-999) — exercises the min-size-not-fixed-size box.
      _JerseyBadge(number: '999'),
    ],
  ),
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
        ..group = 'Complete profile screen'
        ..name = '$name — ${preview.brightness!.name}'
        ..theme = () => PreviewThemeData(
          materialLight: AppTheme.lightTheme,
          materialDark: AppTheme.darkTheme,
        );
      return builder.build();
    }).toList();
  }
}
