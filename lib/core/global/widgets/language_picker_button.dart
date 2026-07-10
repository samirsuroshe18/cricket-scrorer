import 'package:cricket_scorer/core/global/domain/usecases/get_language.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_version.dart';
import 'package:cricket_scorer/core/services/language_service.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguagePickerButton extends StatelessWidget {
  const LanguagePickerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = Get.find<LanguageService>();
    final versionUseCase = Get.find<GetVersionUseCase>();
    final languageUseCase = Get.find<GetLanguageUseCase>();

    return IconButton(
      icon: const Icon(Icons.language),
      tooltip: TranslationKeys.language.tr,
      onPressed: () {
        languageService.selectLanguage(
          getVersionUseCase: versionUseCase,
          getLanguageUseCase: languageUseCase,
        );
      },
    );
  }
}