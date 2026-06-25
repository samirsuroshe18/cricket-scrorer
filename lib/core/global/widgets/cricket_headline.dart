import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CricketHeadline extends StatelessWidget {
  const CricketHeadline({
    super.key,
    required this.headlineText,
    this.textStyle,
    this.widthFactor,
  });

  final String headlineText;
  final TextStyle? textStyle;
  final double? widthFactor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Expanded(
          child: Container(
            height: 2,
            width: widthFactor,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Get.theme.colorScheme.surface,
                  Get.theme.colorScheme.outline,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
        CricketText(
          text: headlineText,
          style: textStyle ?? context.textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        Expanded(
          child: Container(
            height: 2,
            width: widthFactor,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Get.theme.colorScheme.outline,
                  Get.theme.colorScheme.surface,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CricketHeadlineWithFixedOutline extends StatelessWidget {
  const CricketHeadlineWithFixedOutline({
    super.key,
    required this.headlineText,
    this.textStyle,
    this.widthFactor = 0.1,
    this.useFlexible = false,
  });

  final String headlineText;
  final TextStyle? textStyle;
  final double widthFactor;
  final bool useFlexible;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Expanded(
          child: Container(
            height: 2,
            width: context.width * widthFactor,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Get.theme.colorScheme.surface,
                  Get.theme.colorScheme.outline,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),

        if (useFlexible)
          Flexible(
            flex: 6,
            child: CricketText(
              text: headlineText,
              style: textStyle ?? context.textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
          )
        else
          CricketText(
            text: headlineText,
            style: textStyle ?? context.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),

        Expanded(
          child: Container(
            height: 2,
            width: context.width * widthFactor,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Get.theme.colorScheme.outline,
                  Get.theme.colorScheme.surface,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
