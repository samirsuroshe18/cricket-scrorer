import 'package:cricket_scorer/core/enums/app_language.dart';

class CricketLanguage {
  String imageAsset;
  bool selected;
  AppLanguage language;

  CricketLanguage({
    this.selected = false,
    required this.language,
    required this.imageAsset,
  });
}
