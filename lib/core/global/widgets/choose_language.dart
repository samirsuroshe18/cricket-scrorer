import 'package:cricket_scorer/core/constants/assets_util.dart';
import 'package:cricket_scorer/core/enums/app_language.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/data/models/cricket_language.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image_source.dart';
import 'package:cricket_scorer/core/services/language_service.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChooseLanguage extends StatefulWidget {
  const ChooseLanguage({super.key});

  @override
  State<ChooseLanguage> createState() {
    return ChooseLanguageState();
  }
}

class ChooseLanguageState extends State<ChooseLanguage> {
  List<CricketLanguage> languageList = [
    CricketLanguage(
      imageAsset: AssetsUtil.englishFlag,
      language: AppLanguage.english,
    ),
    CricketLanguage(
      imageAsset: AssetsUtil.englishFlag,
      language: AppLanguage.marathi,
    ),
    CricketLanguage(
      imageAsset: AssetsUtil.englishFlag,
      language: AppLanguage.hindi,
    ),
  ];

  CricketLanguage? selectedLanguage;
  final languageService = Get.find<LanguageService>();
  late String currentCode;

  @override
  void initState() {
    super.initState();

    currentCode = languageService.currentLanguage;
    for (var lang in languageList) {
      if (lang.language.code == currentCode) {
        lang.selected = true;
        selectedLanguage = lang;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 32, bottom: 32),
            itemCount: languageList.length,
            separatorBuilder: (_, _) => 16.h,
            itemBuilder: (context, index) {
              final item = languageList[index];

              return InkWell(
                onTap: () {
                  for (final t in languageList) {
                    t.selected = false;
                  }

                  setState(() {
                    item.selected = true;
                    selectedLanguage = item;
                  });
                },
                child: Container(
                  padding: 16.p,
                  decoration: BoxDecoration(
                    borderRadius: 12.radius,
                    border: Border.all(
                      color: item.selected
                          ? context.colorScheme.primary
                          : context.colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Opacity(
                        opacity: item.selected ? 1.0 : 0.4,
                        child: CricketImage(
                          source: CricketImageSource.svg(item.imageAsset),
                          width: 20,
                          height: 20,
                        )
                      ),
                      8.w,
                      CricketText(
                        text: item.language.label,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: item.selected
                              ? null
                              : context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        CricketButton(
          buttonText: TranslationKeys.confirm.tr,
          onPressed:
              (selectedLanguage != null &&
                  selectedLanguage!.language.code != currentCode)
              ? () {
                  Get.back(result: selectedLanguage);
                }
              : null,
        ),
      ],
    );
  }
}
