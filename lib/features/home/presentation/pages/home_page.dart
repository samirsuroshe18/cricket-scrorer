import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_language.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_version.dart';
import 'package:cricket_scorer/core/global/domain/usecases/update_language.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/services/language_service.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: TranslationKeys.cricketMatch.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: controller.logout,
          ),
          IconButton(
            onPressed: () => Get.find<LanguageService>().selectLanguage(
              getVersionUseCase: Get.find<GetVersionUseCase>(),
              getLanguageUseCase: Get.find<GetLanguageUseCase>(),
              updateLanguageUseCase: Get.find<UpdateLanguageUseCase>(),
            ),
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CricketButton(
            buttonText: TranslationKeys.startMatch.tr,
            onPressed: () => Get.toNamed<dynamic>(AppRoutes.createMatch),
          ),
        ),
      ),
    );
  }
}
