import 'package:flutter/material.dart';

@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color liveCard;
  final Color premiumCard;
  final Color warningCard;
  final Color successCard;

  final Color teamA;
  final Color teamB;

  final Color scorePositive;
  final Color scoreNegative;

  // NEW
  final Color chipBackground;
  final Color chipSelected;
  final Color sliderOverlay;
  final Color valueIndicator;

  /// Foreground severity colors — for meters, badges and status labels
  /// (the `*Card` colors above are backgrounds, these are drawn on top).
  final Color statusDanger;
  final Color statusWarning;
  final Color statusInfo;
  final Color statusSuccess;

  /// The toss coin's metallic edge (`CoinFlip`) — a dedicated token rather
  /// than reusing `statusWarning`, even though both land in the same amber
  /// family: the coin is decorative, not a severity signal, so it shouldn't
  /// move if a future warning-color change is only about warnings.
  final Color coinRim;

  const AppCustomColors({
    required this.liveCard,
    required this.premiumCard,
    required this.warningCard,
    required this.successCard,
    required this.teamA,
    required this.teamB,
    required this.scorePositive,
    required this.scoreNegative,
    required this.chipBackground,
    required this.chipSelected,
    required this.sliderOverlay,
    required this.valueIndicator,
    required this.statusDanger,
    required this.statusWarning,
    required this.statusInfo,
    required this.statusSuccess,
    required this.coinRim,
  });

  @override
  AppCustomColors copyWith({
    Color? liveCard,
    Color? premiumCard,
    Color? warningCard,
    Color? successCard,
    Color? teamA,
    Color? teamB,
    Color? scorePositive,
    Color? scoreNegative,
    Color? chipBackground,
    Color? chipSelected,
    Color? sliderOverlay,
    Color? valueIndicator,
    Color? statusDanger,
    Color? statusWarning,
    Color? statusInfo,
    Color? statusSuccess,
    Color? coinRim,
  }) {
    return AppCustomColors(
      liveCard: liveCard ?? this.liveCard,
      premiumCard: premiumCard ?? this.premiumCard,
      warningCard: warningCard ?? this.warningCard,
      successCard: successCard ?? this.successCard,
      teamA: teamA ?? this.teamA,
      teamB: teamB ?? this.teamB,
      scorePositive: scorePositive ?? this.scorePositive,
      scoreNegative: scoreNegative ?? this.scoreNegative,
      chipBackground: chipBackground ?? this.chipBackground,
      chipSelected: chipSelected ?? this.chipSelected,
      sliderOverlay: sliderOverlay ?? this.sliderOverlay,
      valueIndicator: valueIndicator ?? this.valueIndicator,
      statusDanger: statusDanger ?? this.statusDanger,
      statusWarning: statusWarning ?? this.statusWarning,
      statusInfo: statusInfo ?? this.statusInfo,
      statusSuccess: statusSuccess ?? this.statusSuccess,
      coinRim: coinRim ?? this.coinRim,
    );
  }

  @override
  AppCustomColors lerp(
    ThemeExtension<AppCustomColors>? other,
    double t,
  ) {
    if (other is! AppCustomColors) return this;

    return AppCustomColors(
      liveCard: Color.lerp(liveCard, other.liveCard, t)!,
      premiumCard: Color.lerp(premiumCard, other.premiumCard, t)!,
      warningCard: Color.lerp(warningCard, other.warningCard, t)!,
      successCard: Color.lerp(successCard, other.successCard, t)!,
      teamA: Color.lerp(teamA, other.teamA, t)!,
      teamB: Color.lerp(teamB, other.teamB, t)!,
      scorePositive: Color.lerp(scorePositive, other.scorePositive, t)!,
      scoreNegative: Color.lerp(scoreNegative, other.scoreNegative, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
      chipSelected: Color.lerp(chipSelected, other.chipSelected, t)!,
      sliderOverlay: Color.lerp(sliderOverlay, other.sliderOverlay, t)!,
      valueIndicator: Color.lerp(valueIndicator, other.valueIndicator, t)!,
      statusDanger: Color.lerp(statusDanger, other.statusDanger, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusInfo: Color.lerp(statusInfo, other.statusInfo, t)!,
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
      coinRim: Color.lerp(coinRim, other.coinRim, t)!,
    );
  }
}
