import 'package:cricket_scorer/core/extensions/app_custom_colors.dart';
import 'package:flutter/material.dart';

// AppCustomColorsPalette colors is for if your app has colors that are specific to cricket
class AppCustomColorsPalette {
  AppCustomColorsPalette._();

  static const light = AppCustomColors(
    liveCard: Color(0xffFFD54F),
    premiumCard: Color(0xffE3F2FD),
    warningCard: Color(0xffFFF3CD),
    successCard: Color(0xffD1FADF),

    teamA: Color(0xff1F78E6),
    teamB: Color(0xffDA1414),

    scorePositive: Color(0xff2EB86B),
    scoreNegative: Color(0xffDA1414),

    chipBackground: Color(0xffF7F7FA),
    chipSelected: Color(0xffE0EDFF),

    sliderOverlay: Color(0x1F1F78E6),
    valueIndicator: Color(0xff141F38),

    statusDanger: Color(0xffDA1414),
    statusWarning: Color(0xffB26A00),
    statusInfo: Color(0xff1F78E6),
    // Darkened from the original 0xff2EB86B (~2.6:1 against white, failing
    // WCAG AA) to ~4.7:1 — matches statusWarning's existing precedent of a
    // deliberately darker light-mode shade for use as foreground/text.
    statusSuccess: Color(0xff1A8449),
  );

  static const dark = AppCustomColors(
    liveCard: Color(0xff665500),
    premiumCard: Color(0xff1A3366),
    warningCard: Color(0xff5A4500),
    successCard: Color(0xff174D33),

    teamA: Color(0xff4D99FF),
    teamB: Color(0xffFF5959),

    scorePositive: Color(0xff38D980),
    scoreNegative: Color(0xffFF5959),

    chipBackground: Color(0xff242E4D),
    chipSelected: Color(0xff1A3366),

    sliderOverlay: Color(0x1F4D99FF),
    valueIndicator: Color(0xff1F2B4A),

    statusDanger: Color(0xffFF5959),
    statusWarning: Color(0xffFFB84D),
    statusInfo: Color(0xff4D99FF),
    statusSuccess: Color(0xff38D980),
  );
}
