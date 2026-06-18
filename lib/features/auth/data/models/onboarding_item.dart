import 'package:flutter/material.dart';

class OnboardingItem {
  final String image;
  final String title;
  final String description;
  final Color? color;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
    this.color,
  });
}
