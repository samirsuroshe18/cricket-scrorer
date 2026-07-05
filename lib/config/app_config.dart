import 'package:cricket_scorer/config/flavors.dart';
import 'package:cricket_scorer/config/routes/app_pages.dart';
import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/enums/app_language.dart';
import 'package:cricket_scorer/core/services/language_service.dart';
import 'package:cricket_scorer/core/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppConfig {
  AppConfig._();

  static Future<void> setup() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    runApp(const CricketScorerApp());
  }
}

class CricketScorerApp extends StatelessWidget {
  const CricketScorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppFlavor.title,
      debugShowCheckedModeBanner: false,
      translations: Get.find<LanguageService>().appTranslations,
      fallbackLocale: Locale(AppLanguage.english.code),
      themeMode: Get.find<ThemeService>().themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      defaultTransition: Transition.rightToLeft,
    );
  }
}
