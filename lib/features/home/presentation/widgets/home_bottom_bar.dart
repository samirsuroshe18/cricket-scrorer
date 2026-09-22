import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

class HomeNavItem {
  const HomeNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Bottom navigation with the primary action docked in the middle: four
/// destinations either side of a raised "+" that starts a match from any tab.
/// A docked button instead of a floating one so it never sits on top of the
/// last card of a list — it belongs to the bar, not to the content.
class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({
    required this.items,
    required this.currentIndex,
    required this.onSelect,
    required this.actionLabel,
    required this.onAction,
    super.key,
  }) : assert(items.length == 4, 'two destinations either side of the action');

  final List<HomeNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final page = context.colorScheme.surfaceContainerLowest;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: page,
        border: Border(top: BorderSide(color: context.homeLine)),
      ),
      padding: EdgeInsets.only(
        top: 6,
        bottom: bottomInset > 0 ? bottomInset : 8,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Row(
            children: [
              _item(context, 0),
              _item(context, 1),
              const Expanded(child: SizedBox(height: 48)),
              _item(context, 2),
              _item(context, 3),
            ],
          ),
          PositionedDirectional(
            top: -30,
            child: Semantics(
              button: true,
              label: actionLabel,
              excludeSemantics: true,
              child: _DockedActionButton(borderColor: page, onTap: onAction),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, int index) {
    final item = items[index];
    final selected = index == currentIndex;
    final ink = selected ? context.homeLiveText : context.homeMuted;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: item.label,
        excludeSemantics: true,
        child: InkWell(
          onTap: () {
            if (!selected) HapticFeedback.selectionClick();
            onSelect(index);
          },
          borderRadius: 12.radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: ink),
              duration: Durations.short3,
              curve: Easing.standard,
              builder: (context, color, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: Durations.short3,
                      curve: Easing.standard,
                      width: 42,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? context.homeSelectedPillTint
                            : Colors.transparent,
                        borderRadius: 16.radius,
                      ),
                      child: Icon(
                        selected ? item.activeIcon : item.icon,
                        size: 22,
                        color: color,
                      ),
                    ),
                    2.h,
                    CricketText(
                      text: item.label,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                      style: context.homeText(
                        11,
                        weight: selected ? FontWeight.w600 : FontWeight.w400,
                        color: color,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// The docked "+" action: its own press-scale and ripple, since it carries
/// more visual weight than the four tab items either side of it and had no
/// tap feedback at all — the tab items get InkWell's ripple for free, this
/// button previously got none.
class _DockedActionButton extends StatefulWidget {
  const _DockedActionButton({required this.borderColor, required this.onTap});

  final Color borderColor;
  final VoidCallback onTap;

  @override
  State<_DockedActionButton> createState() => _DockedActionButtonState();
}

class _DockedActionButtonState extends State<_DockedActionButton> {
  bool _pressed = false;

  void _setPressed(bool value) => setState(() => _pressed = value);

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.92 : 1,
      duration: Durations.short2,
      curve: Easing.standard,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colorScheme.primary,
          border: Border.all(color: widget.borderColor, width: 4),
          boxShadow: [
            BoxShadow(
              color: context.homeActionShadowColor,
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipOval(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTapDown: (_) => _setPressed(true),
              onTapCancel: () => _setPressed(false),
              onTapUp: (_) => _setPressed(false),
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onTap();
              },
              child: Icon(
                Icons.add_rounded,
                size: 24,
                color: context.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@_MultiPreviewBrightness(name: 'Home bottom bar')
Widget homeBottomBarPreview() => const _HomeBottomBarPreview();

class _HomeBottomBarPreview extends StatefulWidget {
  const _HomeBottomBarPreview();

  @override
  State<_HomeBottomBarPreview> createState() => _HomeBottomBarPreviewState();
}

class _HomeBottomBarPreviewState extends State<_HomeBottomBarPreview> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('Tap a tab or the + button')),
      bottomNavigationBar: HomeBottomBar(
        currentIndex: _index,
        onSelect: (index) => setState(() => _index = index),
        actionLabel: 'Start match',
        onAction: () {},
        items: const [
          HomeNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
          ),
          HomeNavItem(
            icon: Icons.sports_cricket_outlined,
            activeIcon: Icons.sports_cricket,
            label: 'Matches',
          ),
          HomeNavItem(
            icon: Icons.groups_outlined,
            activeIcon: Icons.groups_rounded,
            label: 'Teams',
          ),
          HomeNavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

final class _MultiPreviewBrightness extends MultiPreview {
  const _MultiPreviewBrightness({required this.name});

  final String name;

  @override
  List<Preview> get previews => const [
    Preview(brightness: Brightness.light),
    Preview(brightness: Brightness.dark),
  ];
}
