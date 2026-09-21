import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:flutter/material.dart';

/// One raised surface holding a list of tappable rows, split by hairlines.
/// Dark mode gets the quiet borderless tile and light mode the outline that
/// lifts white off the off-white page — the same treatment as the Home
/// dashboard's cards.
///
/// It is a [Material] on purpose: the rows' `InkWell` splashes paint on the
/// nearest Material, so a plain decorated box here would hide them.
class CricketGroupedCard extends StatelessWidget {
  const CricketGroupedCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Material(
      color: scheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: 12.radius,
        side: context.isDark
            ? BorderSide.none
            : BorderSide(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: scheme.outline),
            children[i],
          ],
        ],
      ),
    );
  }
}
