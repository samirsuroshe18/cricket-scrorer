import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_grouped_card.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image_source.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/current_user.dart';
import 'package:cricket_scorer/features/auth/data/models/user.dart';
import 'package:cricket_scorer/features/auth/data/profile_constants.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Display label/icon per wire value — kept beside this screen rather than on
/// [BattingStyle]/[BowlingStyle]/[PlayingRole], which hold wire values only,
/// same split `update_profile_screen.dart` uses for its own copy of these
/// maps (see that file's comment for why they aren't shared).
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

const Map<String, String> _playingRoleLabels = <String, String>{
  PlayingRole.batsman: TranslationKeys.roleBatsman,
  PlayingRole.bowler: TranslationKeys.roleBowler,
  PlayingRole.allrounder: TranslationKeys.roleAllrounder,
  PlayingRole.wicketkeeper: TranslationKeys.roleWicketkeeper,
};

const Map<String, IconData> _battingStyleIcons = <String, IconData>{
  BattingStyle.rightHanded: Icons.back_hand_outlined,
  BattingStyle.leftHanded: Icons.back_hand_outlined,
};

const Map<String, IconData> _bowlingStyleIcons = <String, IconData>{
  BowlingStyle.rightArmPace: Icons.bolt_outlined,
  BowlingStyle.leftArmPace: Icons.bolt_outlined,
  BowlingStyle.rightArmSpin: Icons.rotate_right,
  BowlingStyle.leftArmSpin: Icons.rotate_left,
};

const Map<String, IconData> _playingRoleIcons = <String, IconData>{
  PlayingRole.batsman: Icons.sports_cricket,
  PlayingRole.bowler: Icons.adjust,
  PlayingRole.allrounder: Icons.swap_horiz,
  PlayingRole.wicketkeeper: Icons.pan_tool_outlined,
};

/// Profile tab: the avatar-tap-to-edit-form shortcut Home used to be is
/// replaced by an actual identity destination — a view first, with edit and
/// "my stats" as explicit actions off it, plus the entry point into the new
/// Settings screen (which is where logout now lives; see
/// `SettingsScreen`'s doc comment for why it moved off Home's app bar).
///
/// The identity card mirrors `update_profile_screen.dart`'s
/// `_ProfilePreviewCard` — role/batting/bowling tags and the jersey-number
/// corner badge — so what a player sets on the edit screen is what they see
/// here, instead of that data going in and never coming back out. Edit lives
/// in the app bar rather than inline in the header row: it's a screen-level
/// action on the identity shown below it, not part of the identity itself.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      appBar: CustomAppBar(
        title: TranslationKeys.navProfile.tr,
        actions: [
          IconButton(
            tooltip: TranslationKeys.editProfile.tr,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Get.toNamed<dynamic>(
              AppRoutes.updateProfile,
              arguments: {'isEditing': true},
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 44),
          children: [
            Obx(() => _IdentityCard(user: controller.currentUserProfile.value)),
            24.h,
            CricketGroupedCard(
              children: [
                _ProfileMenuRow(
                  icon: Icons.bar_chart_outlined,
                  label: TranslationKeys.viewMyStats.tr,
                  onTap: () => Get.toNamed<dynamic>(
                    AppRoutes.playerStatsPath(currentUserId()),
                  ),
                ),
                _ProfileMenuRow(
                  icon: Icons.settings_outlined,
                  label: TranslationKeys.settings.tr,
                  onTap: () => Get.toNamed<dynamic>(AppRoutes.settings),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.user});

  final User? user;

  /// `userName` first (what every other identity surface in the app —
  /// `HomeHeader`, the update-profile preview — shows), then `fullName`,
  /// then a placeholder. The previous version of this card skipped the
  /// `fullName` fallback `HomeHeader` already has, so a user who'd filled in
  /// their name but not a username saw the bare placeholder here while Home
  /// showed their name.
  String _displayName() {
    final userName = user?.userName;
    if (userName != null && userName.isNotEmpty) return userName;
    final fullName = user?.fullName;
    if (fullName != null && fullName.isNotEmpty) return fullName;
    return TranslationKeys.username.tr;
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoUrl;
    final bio = user?.bio;
    final jerseyNumber = user?.jerseyNumber;
    final scheme = context.colorScheme;

    // Guarded with `containsKey` rather than a bare lookup: the backend's
    // unset-default for playingRole is the wire value "unknown" (see
    // `PlayingRole`'s doc comment), which deliberately has no label — a
    // player who hasn't set a role should see no tag, not a crash.
    final tags = <Widget>[
      if (user?.playingRole case final role?
          when _playingRoleLabels.containsKey(role))
        _IdentityTag(
          icon: _playingRoleIcons[role],
          text: _playingRoleLabels[role]!.tr,
        ),
      if (user?.battingStyle case final style?
          when _battingStyleLabels.containsKey(style))
        _IdentityTag(
          icon: _battingStyleIcons[style],
          text: _battingStyleLabels[style]!.tr,
        ),
      if (user?.bowlingStyle case final style?
          when _bowlingStyleLabels.containsKey(style))
        _IdentityTag(
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (photoUrl == null || photoUrl.isEmpty)
                  ? CircleAvatar(
                      radius: 30,
                      backgroundColor: context.colors.chipBackground,
                      child: Icon(
                        Icons.person_outline,
                        size: 30,
                        color: scheme.onSurfaceVariant,
                      ),
                    )
                  : CricketImage(
                      source: CricketImageSource.network(photoUrl),
                      height: 60,
                      width: 60,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(60),
                      ),
                    ),
              16.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CricketText(
                      text: _displayName(),
                      style: context.textTheme.titleLarge,
                    ),
                    if (bio != null && bio.isNotEmpty) ...[
                      4.h,
                      CricketText(
                        text: bio,
                        maxLines: 2,
                        textOverflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (tags.isNotEmpty) ...[
                      12.h,
                      Wrap(spacing: 8, runSpacing: 8, children: tags),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        // Kept off to the side of the tag row rather than folded in as one
        // more pill — same reasoning as the edit screen's preview card: it
        // reads as a real jersey patch pinned to the card, not a metadata
        // chip.
        if (jerseyNumber != null)
          Positioned(
            top: -12,
            right: 14,
            child: _JerseyBadge(number: '$jerseyNumber'),
          ),
      ],
    );
  }
}

/// Icon + label pill — the exact visual `update_profile_screen.dart`'s
/// private `_PreviewTag` already uses for this same data, redeclared here
/// per this file's own per-screen-maps convention above. `onSurfaceVariant`
/// on `surface` rather than the `statusInfo`/`statusWarning`/`statusSuccess`
/// tint `team_profile_screen.dart`'s role badges use: that pattern measures
/// 3.96-4.42:1 for normal text against `chipBackground` (`contrast.py`),
/// under WCAG AA's 4.5:1 — not copying it into new code even though it's
/// already shipped elsewhere.
class _IdentityTag extends StatelessWidget {
  const _IdentityTag({required this.icon, required this.text});

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

/// The squad-number patch pinned to the identity card's corner — same
/// `valueIndicator` navy + white pairing as the edit screen's preview badge,
/// so the number a player sets is echoed back with the same visual weight.
class _JerseyBadge extends StatelessWidget {
  const _JerseyBadge({required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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

class _ProfileMenuRow extends StatelessWidget {
  const _ProfileMenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: context.colorScheme.onSurfaceVariant),
              12.w,
              Expanded(
                child: CricketText(
                  text: label,
                  style: context.textTheme.bodyLarge,
                ),
              ),
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
