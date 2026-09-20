import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:flutter/material.dart';

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
              child: GestureDetector(
                onTap: onAction,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colorScheme.primary,
                    border: Border.all(color: page, width: 4),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ),
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
          onTap: () => onSelect(index),
          borderRadius: 12.radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? item.activeIcon : item.icon,
                  size: 22,
                  color: ink,
                ),
                2.h,
                CricketText(
                  text: item.label,
                  maxLines: 1,
                  textOverflow: TextOverflow.ellipsis,
                  style: context.homeText(
                    11,
                    weight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
