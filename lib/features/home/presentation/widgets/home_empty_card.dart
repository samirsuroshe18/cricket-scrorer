import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:flutter/material.dart';

/// An empty section on the Teams tab: an icon, one line saying what is
/// missing, and an optional action — inside the same card surface the
/// section's rows would have used, so the layout doesn't jump when the first
/// row arrives.
class HomeEmptyCard extends StatelessWidget {
  const HomeEmptyCard({
    required this.icon,
    required this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: context.homeCardDecoration(),
      child: Column(
        children: [
          Icon(icon, size: 32, color: context.homeMuted),
          8.h,
          CricketText(
            text: message,
            textAlign: TextAlign.center,
            style: context.homeText(14),
          ),
          if (action != null) ...[16.h, action!],
        ],
      ),
    );
  }
}
