import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CricketOutlinedButton extends StatelessWidget {
  const CricketOutlinedButton({
    super.key,
    this.onPressed,
    this.buttonName,
    this.borderColor = AppColor.primaryRed,
    this.textStyle,
    this.child,
    this.padding,
    this.visualDensity,
  });

  final String? buttonName;
  final void Function()? onPressed;
  final Color borderColor;
  final TextStyle? textStyle;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final VisualDensity? visualDensity;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        side: BorderSide(color: borderColor),
        visualDensity: visualDensity,
        padding: padding,
      ),
      onPressed: onPressed,
      child:
          child ??
          CricketText(
            text: buttonName ?? '',
            style: textStyle ?? Get.context?.textTheme.titleLarge,
          ),
    );
  }
}
