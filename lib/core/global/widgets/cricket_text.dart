import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CricketText extends StatelessWidget {
  const CricketText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.textOverflow,
    this.textAlign,
    this.softWrap = true,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? textOverflow;
  final TextAlign? textAlign;
  final bool softWrap;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ?? context.textTheme.bodyLarge,
      maxLines: maxLines,
      overflow: textOverflow,
      textAlign: textAlign,
      softWrap: softWrap,
    );
  }
}
