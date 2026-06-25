import 'package:auto_size_text/auto_size_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CricketButton extends StatelessWidget {
  const CricketButton({
    super.key,
    this.prefixIcon,
    this.suffixIcon,
    required this.buttonText,
    required this.onPressed,
    this.buttonTextStyle,
    this.buttonStyle,
    this.isAutoSize,
    this.isDisabled = false,
  });

  final Widget? prefixIcon, suffixIcon;
  final String buttonText;
  final void Function()? onPressed;
  final TextStyle? buttonTextStyle;
  final ButtonStyle? buttonStyle;
  final bool isDisabled;
  final bool? isAutoSize;

  @override
  Widget build(BuildContext context) {
    final textColor = (isDisabled || onPressed == null)
        ? Get.theme.colorScheme.onSurface.withValues(alpha: 0.38)
        : Get.theme.colorScheme.onPrimary;

    return FilledButton(
      onPressed: isDisabled ? null : onPressed,
      style: buttonStyle,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          ?prefixIcon,

          Visibility(
            visible: isAutoSize ?? false,
            replacement: Flexible(
              child: CricketText(
                text: buttonText,
                maxLines: 2,
                textAlign: TextAlign.center,
                style:
                    buttonTextStyle ??
                    context.textTheme.headlineLarge?.copyWith(
                      color: textColor,
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
            ),
            child: Flexible(
              child: AutoSizeText(
                buttonText,
                maxLines: 1,
                textAlign: TextAlign.center,
                maxFontSize: 16,
                minFontSize: 12,
                style:
                    buttonTextStyle ??
                    context.textTheme.headlineLarge?.copyWith(
                      color: textColor,
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
            ),
          ),

          ?suffixIcon,
        ],
      ),
    );
  }
}
