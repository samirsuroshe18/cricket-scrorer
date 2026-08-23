import 'package:flutter/material.dart';

class CricketThemeOption {
  final ThemeMode mode;
  final String label;
  final IconData icon;
  bool selected;

  CricketThemeOption({
    required this.mode,
    required this.label,
    required this.icon,
    this.selected = false,
  });
}
