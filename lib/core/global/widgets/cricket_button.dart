import 'package:auto_size_text/auto_size_text.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:flutter/material.dart';

class CricketButton extends StatelessWidget {
  const CricketButton({
    super.key,
    this.prefixIcon,
    this.suffixIcon,
    required this.buttonText,
    required this.onPressed,
    this.buttonTextStyle,
    this.buttonStyle,
    this.isAutoSize = false,
    this.isDisabled = false,
    this.height = 48,
  });

  final Widget? prefixIcon, suffixIcon;
  final String buttonText;
  final VoidCallback? onPressed;
  final TextStyle? buttonTextStyle;
  final ButtonStyle? buttonStyle;
  final bool isDisabled;
  final bool isAutoSize;
  final double height;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isDisabled ? null : onPressed;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: buttonStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (prefixIcon != null) ...[
              prefixIcon!,
              8.w,
            ],

            Flexible(
              child: isAutoSize
                  ? AutoSizeText(
                      buttonText,
                      maxLines: 1,
                      minFontSize: 12,
                      maxFontSize: 16,
                      textAlign: TextAlign.center,
                      style: buttonTextStyle,
                    )
                  : CricketText(
                      text: buttonText,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: buttonTextStyle,
                    ),
            ),

            if (suffixIcon != null) ...[
              8.w,
              suffixIcon!,
            ],
          ],
        ),
      ),
    );
  }
}
