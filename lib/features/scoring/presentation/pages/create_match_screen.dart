import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_entity_avatar.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/create_match_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/coin_flip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateMatchScreen extends GetView<CreateMatchController> {
  const CreateMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.createMatch.tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionCard(
                title: TranslationKeys.matchSectionTeams.tr,
                trailing: _TeamsProgressDots(controller: controller),
                child: _TeamsSection(controller: controller),
              ),
              16.h,
              _SectionCard(
                title: TranslationKeys.matchSectionFormat.tr,
                child: _MatchFormatSection(controller: controller),
              ),
              16.h,
              _SectionCard(
                title: TranslationKeys.tossOptional.tr,
                child: _TossSection(controller: controller),
              ),
            ],
          ),
        ),
      ),
      // Pinned rather than the last item in the scroll view — with a couple
      // of saved teams and the toss card open, the old layout could put
      // "Create match" a full screen below the fold.
      bottomNavigationBar: _BottomActionBar(controller: controller),
    );
  }
}

/// One raised card with a section heading, matching the outline-in-light /
/// borderless-in-dark treatment `CricketGroupedCard` uses elsewhere — but for
/// a single block of mixed content rather than a list of tappable rows.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, this.trailing, required this.child});

  final String title;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: 12.radius,
        border: context.isDark
            ? null
            : Border.all(color: context.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CricketText(
                  text: title,
                  style: context.textTheme.titleSmall,
                ),
              ),
              ?trailing,
            ],
          ),
          12.h,
          child,
        ],
      ),
    );
  }
}

/// Both team slots as two stacked, list-tile-style rows — tapping either
/// pushes [SelectTeamScreen] to pick or add that side's team (see
/// [CreateMatchController.onTapTeamA]/[onTapTeamB]); the seam between them
/// carries the "vs" label and the swap button. Replaces the earlier
/// side-by-side two-tone banner: rows read as a standard tappable field
/// (border, chevron) instead of a colored, banner-like block, and reuse the
/// same row language as [SelectTeamScreen]'s own result list.
class _TeamsSection extends StatelessWidget {
  const _TeamsSection({required this.controller});

  final CreateMatchController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // teamAController isn't a `.obs` — it's a plain TextEditingController,
        // same as every other field on this screen — so this row listens to
        // it directly rather than via Obx, which would never fire on it.
        // onTapTeamA/B and swapTeams always change the controller's text
        // whenever they change what this row should show.
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller.teamAController,
          builder: (context, value, _) => _TeamRow(
            rowKey: const Key('teamsSection_teamARow'),
            color: context.colors.teamA,
            name: value.text,
            logoUrl: controller.selectedTeamALogoUrl,
            label: TranslationKeys.teamA.tr,
            onTap: controller.onTapTeamA,
          ),
        ),
        _TeamsSeam(onTap: controller.swapTeams),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller.teamBController,
          builder: (context, value, _) => _TeamRow(
            rowKey: const Key('teamsSection_teamBRow'),
            color: context.colors.teamB,
            name: value.text,
            logoUrl: controller.selectedTeamBLogoUrl,
            label: TranslationKeys.teamB.tr,
            onTap: controller.onTapTeamB,
          ),
        ),
      ],
    );
  }
}

/// The seam between the two team rows — a hairline with the "vs" label and
/// the swap button both centered on it, so swap reads as acting on the pair
/// it sits between rather than as a disconnected footer control.
class _TeamsSeam extends StatelessWidget {
  const _TeamsSeam({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Divider(height: 1, color: context.colorScheme.outline),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colors.chipBackground,
                  borderRadius: 999.radius,
                  border: Border.all(color: context.colorScheme.outline),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: CricketText(
                    text: TranslationKeys.matchVersus.tr,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              10.w,
              Tooltip(
                message: TranslationKeys.swapTeams.tr,
                child: Material(
                  shape: const CircleBorder(),
                  color: context.colors.chipBackground,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.swap_vert,
                        size: 20,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({
    required this.rowKey,
    required this.color,
    required this.name,
    required this.logoUrl,
    required this.label,
    required this.onTap,
  });

  final Key rowKey;
  final Color color;
  final String name;
  final String? logoUrl;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isFilled = name.trim().isNotEmpty;

    return Material(
      key: rowKey,
      // chipBackground rather than surfaceContainerHighest: the latter is
      // derived algorithmically from this app's hand-built ColorScheme and
      // renders indistinguishable from the white card behind it. chipBackground
      // is an explicit, already-used token that reads as a clear inset.
      color: context.colors.chipBackground,
      borderRadius: 12.radius,
      child: InkWell(
        borderRadius: 12.radius,
        onTap: onTap,
        // IntrinsicHeight lets the accent bar stretch to match the content
        // column's real height (which varies with text scale and the
        // hi/mr translations) instead of a guessed fixed number.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.horizontal(left: 12.radius.topLeft),
                child: Container(
                  width: 4,
                  color: isFilled ? color : context.colorScheme.outline,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      _TeamAvatar(
                        name: name,
                        logoUrl: logoUrl,
                        ringColor: color,
                        isFilled: isFilled,
                      ),
                      12.w,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CricketText(
                              text: label,
                              maxLines: 1,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            2.h,
                            CricketText(
                              text: isFilled
                                  ? name
                                  : TranslationKeys.tapToSelectTeam.tr,
                              maxLines: 1,
                              textOverflow: TextOverflow.ellipsis,
                              style: isFilled
                                  ? context.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: context.colorScheme.onSurface,
                                    )
                                  : context.textTheme.bodyMedium?.copyWith(
                                      color:
                                          context.colorScheme.onSurfaceVariant,
                                    ),
                            ),
                          ],
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
            ],
          ),
        ),
      ),
    );
  }
}

/// The avatar plus its team-color ring — a fixed-size wrapper (44x44
/// regardless of state) so a row doesn't shift height when a selection is
/// made: the empty state draws the same border at zero opacity rather than
/// omitting it.
class _TeamAvatar extends StatelessWidget {
  const _TeamAvatar({
    required this.name,
    required this.logoUrl,
    required this.ringColor,
    required this.isFilled,
  });

  final String name;
  final String? logoUrl;
  final Color ringColor;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 2,
          color: isFilled ? ringColor : Colors.transparent,
        ),
      ),
      child: isFilled
          ? CricketEntityAvatar(name: name, logoUrl: logoUrl, size: 36)
          : DecoratedBox(
              // surface, not chipBackground: the row itself is now
              // chipBackground-filled, so that would make this circle
              // invisible against its own row and leave only the "+" icon
              // floating.
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colorScheme.surface,
              ),
              child: Icon(
                Icons.add,
                size: 18,
                color: context.colorScheme.secondary,
              ),
            ),
    );
  }
}

/// Two small dots next to the "Teams" title — hollow until that side is
/// picked, filled in the team's own color once it is. A quiet "0/2 -> 2/2"
/// progress cue the old banner didn't have. Purely decorative: excluded
/// from semantics since each row already announces its own filled/empty
/// state, so a screen-reader user isn't told the same thing twice.
class _TeamsProgressDots extends StatelessWidget {
  const _TeamsProgressDots({required this.controller});

  final CreateMatchController controller;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          controller.teamAController,
          controller.teamBController,
        ]),
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ProgressDot(
              color: context.colors.teamA,
              filled: controller.teamAController.text.trim().isNotEmpty,
            ),
            6.w,
            _ProgressDot(
              color: context.colors.teamB,
              filled: controller.teamBController.text.trim().isNotEmpty,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressDot extends StatelessWidget {
  const _ProgressDot({required this.color, required this.filled});

  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : Colors.transparent,
        border: Border.all(color: color, width: 1.5),
      ),
    );
  }
}

class _MatchFormatSection extends StatelessWidget {
  const _MatchFormatSection({required this.controller});

  final CreateMatchController controller;

  static const _presets = [
    OversPreset.custom,
    OversPreset.five,
    OversPreset.t20,
    OversPreset.odi,
  ];

  String _labelFor(OversPreset preset) => switch (preset) {
    OversPreset.custom => TranslationKeys.oversPresetCustom.tr,
    OversPreset.five => TranslationKeys.oversPresetFive.tr,
    OversPreset.t20 => TranslationKeys.oversPresetT20.tr,
    OversPreset.odi => TranslationKeys.oversPresetOdi.tr,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(
          () => _OversSegmentedControl(
            presets: _presets,
            labelFor: _labelFor,
            selected: controller.selectedOversPreset.value,
            onSelected: controller.selectOversPreset,
          ),
        ),
        12.h,
        CricketTextField(
          controller: controller.oversController,
          hintText: TranslationKeys.enterOvers.tr,
          labelText: TranslationKeys.overs.tr,
          prefixIcon: const Icon(Icons.timer_outlined),
          validator: controller.validateOvers,
          keyboardType: TextInputType.number,
          isRequired: true,
        ),
      ],
    );
  }
}

/// A single-row, equal-width segmented control for the four overs presets —
/// replaces a plain `ChoiceChip` `Wrap`, matching the bordered/filled pill
/// language [_TossDecisionToggle] already established on the Toss card
/// below. Not built by generalizing that widget: it's typed for exactly two
/// team-colored halves, while this needs four `secondary`-accented ones, so
/// nothing existing fit cleanly.
class _OversSegmentedControl extends StatelessWidget {
  const _OversSegmentedControl({
    required this.presets,
    required this.labelFor,
    required this.selected,
    required this.onSelected,
  });

  final List<OversPreset> presets;
  final String Function(OversPreset) labelFor;
  final OversPreset selected;
  final ValueChanged<OversPreset> onSelected;

  @override
  Widget build(BuildContext context) {
    final accent = context.colorScheme.secondary;
    // Darkened so white text on the selected segment clears 4.5:1 in both
    // themes — the raw secondary token is only 4.30:1/2.87:1 against white
    // at this size. Verified with contrast.py: 10.06:1 light, 10.17:1 dark.
    final selectedFill = HSLColor.fromColor(
      accent,
    ).withLightness(0.28).toColor();

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: accent),
        borderRadius: 999.radius,
      ),
      child: ClipRRect(
        borderRadius: 999.radius,
        child: Row(
          children: [
            for (final preset in presets)
              Expanded(
                child: _OversSegment(
                  label: labelFor(preset),
                  selected: preset == selected,
                  color: accent,
                  selectedFill: selectedFill,
                  onTap: () => onSelected(preset),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OversSegment extends StatelessWidget {
  const _OversSegment({
    required this.label,
    required this.selected,
    required this.color,
    required this.selectedFill,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final Color selectedFill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        color: selected ? selectedFill : Colors.transparent,
        alignment: Alignment.center,
        // Sized and weighted as WCAG large text (>=18.66px bold) — same
        // strategy as _ToggleHalf below: the unselected secondary-on-surface
        // pairing is 4.30:1 light / 5.34:1 dark, under the 4.5:1 normal-text
        // bar but clear of the 3:1 large-text one. FittedBox is a layout
        // safety net for "Custom" alongside three short labels on a narrow
        // phone.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: CricketText(
            text: label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 19,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}

class _TossSection extends StatelessWidget {
  const _TossSection({required this.controller});

  final CreateMatchController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          // teamAController/teamBController aren't `.obs`, so this listens
          // to them directly (same idiom as _TeamsProgressDots) rather than
          // via Obx — CoinFlip keeps its own internal flip state across the
          // rebuild since its widget identity doesn't change, only the name
          // props do.
          child: AnimatedBuilder(
            animation: Listenable.merge([
              controller.teamAController,
              controller.teamBController,
            ]),
            builder: (context, _) => CoinFlip(
              onResult: controller.recordTossWinner,
              teamAName: controller.teamAController.text,
              teamBName: controller.teamBController.text,
            ),
          ),
        ),
        // The decision only makes sense once a winner exists — showing it
        // beforehand would let the scorer pick bat/bowl for nobody in
        // particular.
        Obx(() {
          final winner = controller.tossWinner.value;
          if (winner == null) return const SizedBox.shrink();

          final winnerName = winner == 'teamA'
              ? controller.teamAController.text.trim()
              : controller.teamBController.text.trim();
          final winnerColor = winner == 'teamA'
              ? context.colors.teamA
              : context.colors.teamB;

          return Column(
            children: [
              18.h,
              CricketText(
                text: winnerName.isEmpty
                    ? TranslationKeys.wonTheToss.tr
                    : '$winnerName ${TranslationKeys.wonTheToss.tr}',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              10.h,
              _TossDecisionToggle(
                color: winnerColor,
                value: controller.tossDecision.value,
                onChanged: controller.toggleTossDecision,
              ),
            ],
          );
        }),
      ],
    );
  }
}

/// The bat/bowl choice once a toss winner exists — a single filled pill in
/// the winning side's own color instead of two independent chips, so the
/// decision reads as "one choice for this team" rather than two unrelated
/// options.
class _TossDecisionToggle extends StatelessWidget {
  const _TossDecisionToggle({
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final Color color;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    // Darkened so white text on the selected half clears 4.5:1 for both
    // team colors in both themes — the raw teamA/teamB tokens are tuned for
    // icons and large fills, not guaranteed against white text at this
    // size. Verified with contrast.py: >=9.6:1 for every team/theme pair.
    final selectedFill = HSLColor.fromColor(
      color,
    ).withLightness(0.28).toColor();

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: 999.radius,
      ),
      child: ClipRRect(
        borderRadius: 999.radius,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToggleHalf(
              label: TranslationKeys.batFirst.tr,
              selected: value == 'bat',
              color: color,
              selectedFill: selectedFill,
              onTap: () => onChanged('bat'),
            ),
            _ToggleHalf(
              label: TranslationKeys.bowlFirst.tr,
              selected: value == 'bowl',
              color: color,
              selectedFill: selectedFill,
              onTap: () => onChanged('bowl'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleHalf extends StatelessWidget {
  const _ToggleHalf({
    required this.label,
    required this.selected,
    required this.color,
    required this.selectedFill,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final Color selectedFill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        color: selected ? selectedFill : Colors.transparent,
        // Sized and weighted as WCAG large text (>=18.66px bold) — the
        // light-mode teamA token alone is 4.30:1 on white, just under the
        // 4.5:1 normal-text bar but comfortably over the 3:1 large-text one.
        // FittedBox is a layout safety net for a longer hi/mr translation on
        // a narrow phone; every current label fits at full size.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: CricketText(
            text: label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 19,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.controller});

  final CreateMatchController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: context.colorScheme.surface),
      child: SafeArea(
        // Scaffold gives bottomNavigationBar a loose-but-finite height
        // constraint (up to its own full height), so a bare Center would
        // expand to fill that instead of shrink-wrapping this bar's actual
        // content.
        child: Center(
          heightFactor: 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: CricketButton(
              buttonText: TranslationKeys.createMatch.tr,
              onPressed: controller.createMatch,
            ),
          ),
        ),
      ),
    );
  }
}
