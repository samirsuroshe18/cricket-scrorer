import 'package:cricket_scorer/core/global/data/models/cricket_theme_options.dart';
import 'package:cricket_scorer/core/services/theme_service.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';

class ChooseTheme extends StatefulWidget {
  const ChooseTheme({super.key});

  @override
  State<ChooseTheme> createState() => _ChooseThemeState();
}

class _ChooseThemeState extends State<ChooseTheme> {
  final List<CricketThemeOption> themeList = [
    CricketThemeOption(
      mode: ThemeMode.light,
      label: TranslationKeys.light.tr,
      icon: Icons.light_mode,
    ),
    CricketThemeOption(
      mode: ThemeMode.dark,
      label: TranslationKeys.dark.tr,
      icon: Icons.dark_mode,
    ),
    CricketThemeOption(
      mode: ThemeMode.system,
      label: TranslationKeys.system.tr,
      icon: Icons.settings_suggest,
    ),
  ];

  CricketThemeOption? selectedTheme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentMode = Get.find<ThemeService>().themeMode;

    for (var theme in themeList) {
      if (theme.mode == currentMode) {
        theme.selected = true;
        selectedTheme = theme;
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
            itemCount: themeList.length,
            separatorBuilder: (_, _) => 16.h,
            itemBuilder: (context, index) {
              final item = themeList[index];

              return InkWell(
                onTap: () {
                  for (final t in themeList) {
                    t.selected = false;
                  }

                  setState(() {
                    item.selected = true;
                    selectedTheme = item;
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
                        child: Icon(
                          item.icon,
                          size: 20,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      12.w,
                      Opacity(
                        opacity: item.selected ? 1.0 : 0.4,
                        child: CricketText(
                          text: item.label,
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: item.selected
                                ? null
                                : context.colorScheme.onSurfaceVariant,
                          ),
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
              selectedTheme != null &&
                  selectedTheme?.mode != Get.find<ThemeService>().themeMode
              ? () {
                  Get.back(result: selectedTheme);
                }
              : null,
        ),
      ],
    );
  }
}
