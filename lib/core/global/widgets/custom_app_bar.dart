import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLeading;
  final Widget? leading;
  final String title;
  final List<Widget>? actions;
  final Widget? bottom;
  final double toolbarHeight;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    this.isLeading = true,
    this.leading,
    required this.title,
    this.actions,
    this.bottom,
    this.toolbarHeight = 60,
    this.backgroundColor,
  });

  @override
  Size get preferredSize {
    double bottomHeight = 0;

    if (bottom != null) {
      bottomHeight = 50;
    }

    return Size.fromHeight(toolbarHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: isLeading,
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: toolbarHeight,
      elevation: 4,
      leading: leading,
      title: CricketText(
        text: title,
        style: context.textTheme.titleLarge,
      ),
      actions: actions,
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: bottom!,
            )
          : null,
    );
  }
}
