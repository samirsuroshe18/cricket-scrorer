import 'dart:async';
import 'dart:convert';

import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/enums/app_language.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/extensions/app_language_extension.dart';
import 'package:cricket_scorer/core/global/data/models/cricket_language.dart';
import 'package:cricket_scorer/core/global/data/models/response/translation_model.dart';
import 'package:cricket_scorer/core/global/data/models/response/translation_version.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_language.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_user_language.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_version.dart';
import 'package:cricket_scorer/core/global/domain/usecases/update_language.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/choose_language.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:cricket_scorer/core/translations/app_translations.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageService extends GetxService {
  final RxString _currentLanguage = 'en'.obs;

  String get currentLanguage => _currentLanguage.value;

  Locale get currentLocale => Locale(_currentLanguage.value);

  Locale get currentCountryLangLocale =>
      AppLanguageExtension.fromCode(_currentLanguage.value).locale;

  late AppTranslations appTranslations;

  @override
  Future<void> onInit() async {
    super.onInit();
    appTranslations = AppTranslations();
    await _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final String? savedLanguage =
          await SharedPreferenceService.sharedPrefService.get(
                SharedPrefKey.language,
              )
              as String?;

      if (savedLanguage != null) {
        _currentLanguage.value = savedLanguage;
      } else {
        final deviceLang = Get.deviceLocale?.languageCode ?? 'en';
        _currentLanguage.value = AppLanguage.isSupported(deviceLang)
            ? deviceLang
            : 'en';
      }

      await Get.updateLocale(
        currentCountryLangLocale,
      );
    } catch (e) {
      if (kDebugMode) print('[LanguageService] Error loading language: $e');
    }
  }

  Future<void> fetchTranslationKeys({
    required GetVersionUseCase getVersionUseCase,
    required GetLanguageUseCase getLanguageUseCase,
  }) async {
    try {
      final String? savedVersion =
          await SharedPreferenceService.sharedPrefService.get(
                SharedPrefKey.savedLangVersion,
              )
              as String?;

      Either<CricketResponse<TranslationVersion>, CricketFailure> response =
          await getVersionUseCase();

      if (!response.isResult) {
        if (kDebugMode) {
          print(
            '[LanguageService] Version fetch failed: ${response.fallback.message}',
          );
        }
      }

      final String? remoteVersion = response.result.data?.globalVersion
          .toString();

      if (savedVersion != null && savedVersion == remoteVersion) {
        unawaited(loadSavedTranslations());
        return;
      }

      Either<CricketResponse<List<TranslationModel>>, CricketFailure> language =
          await getLanguageUseCase();

      if (language.isResult) {
        final Map<String, Map<String, String>> translations = {
          for (final TranslationModel translation
              in (language.result.data as List<TranslationModel>))
            translation.languageCode: translation.strings,
        };

        Get.addTranslations(translations);

        await SharedPreferenceService.sharedPrefService.set(
          SharedPrefKey.translations,
          jsonEncode(translations),
        );

        await SharedPreferenceService.sharedPrefService.set(
          SharedPrefKey.savedLangVersion,
          remoteVersion ?? '1',
        );
      } else {
        CricketSnackbar.showErrorMessage(language.fallback.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> setLanguage(
    String languageCode, {
    UpdateLanguageUseCase? updateLanguageUseCase,
  }) async {
    try {
      await SharedPreferenceService.sharedPrefService.set(
        SharedPrefKey.language,
        languageCode,
      );
      _currentLanguage.value = languageCode;
      await Get.updateLocale(
        AppLanguageExtension.fromCode(languageCode).locale,
      );

      if (updateLanguageUseCase != null) {
        unawaited(_syncLanguageToServer(languageCode, updateLanguageUseCase));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting language: $e');
      }
    }
  }

  Future<void> selectLanguage({
    required GetVersionUseCase getVersionUseCase,
    required GetLanguageUseCase getLanguageUseCase,
    UpdateLanguageUseCase? updateLanguageUseCase,
  }) async {
    try {
      final value = await CustomBottomSheet.cricketCustomBottomSheet<dynamic>(
        child: const ChooseLanguage(),
        heightFactor: 0.5,
        headlineText: TranslationKeys.selectYourLanguage.tr,
      );
      if (value is CricketLanguage) {
        if (kDebugMode) {
          print(value.language);
        }
        await fetchTranslationKeys(
          getVersionUseCase: getVersionUseCase,
          getLanguageUseCase: getLanguageUseCase,
        );

        await setLanguage(
          value.language.code,
          updateLanguageUseCase: updateLanguageUseCase,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting language: $e');
      }
    }
  }

  Future<void> _syncLanguageToServer(
    String languageCode,
    UpdateLanguageUseCase updateLanguageUseCase,
  ) async {
    try {
      Either<CricketResponse<Map<String, dynamic>>, CricketFailure> result =
          await updateLanguageUseCase(params: languageCode);
      if (result.isResult) {
        if (kDebugMode) {
          print('[LanguageService] Server language updated successfully');
        }
      } else {
        if (kDebugMode) {
          print(
            '[LanguageService] Server language update failed: ${result.fallback.message}',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[LanguageService] _syncLanguageToServer error: $e');
      }
    }
  }

  Future<void> syncLanguageFromServer({
    required GetUserLanguageUseCase getUserLanguageUseCase,
    required UpdateLanguageUseCase updateLanguageUseCase,
  }) async {
    try {
      String? serverLanguage;
      final String? savedLanguage =
          await SharedPreferenceService.sharedPrefService.get(
                SharedPrefKey.language,
              )
              as String?;

      // Get the JSON string
      final String? userJson =
          await SharedPreferenceService.sharedPrefService.get(
                SharedPrefKey.userDetails,
              )
              as String?;

      // Decode and convert back to your user object
      if (userJson != null) {
        final Map<String, dynamic> userMap =
            jsonDecode(userJson) as Map<String, dynamic>;
        final user = User.fromJson(userMap);
        serverLanguage = user.language;
      }

      if (savedLanguage != null) {
        unawaited(_syncLanguageToServer(savedLanguage, updateLanguageUseCase));
        return;
      } else {
        if (serverLanguage != null) {
          await setLanguage(serverLanguage);
        } else {
          if (kDebugMode) {
            print(
              '[LanguageService] Server language fetch failed',
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[LanguageService] syncLanguageFromServer error: $e');
      }
    }
  }

  Future<void> loadSavedTranslations() async {
    final String? json =
        await SharedPreferenceService.sharedPrefService.get(
              SharedPrefKey.translations,
            )
            as String?;

    if (json == null) return;

    final Map<String, dynamic> decoded =
        jsonDecode(json) as Map<String, dynamic>;

    final translations = decoded.map(
      (language, value) => MapEntry(
        language,
        Map<String, String>.from(value as Map),
      ),
    );

    Get.addTranslations(translations);
  }
}
