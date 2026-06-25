import 'package:cricket_scorer/core/global/data/data_sources/remote/language_api_service/language_api_service.dart';
import 'package:cricket_scorer/core/global/data/global_endpoint.dart';
import 'package:cricket_scorer/core/global/data/repositories/language_repository_impl.dart';
import 'package:cricket_scorer/core/global/domain/repositories/language_repository.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_language.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_user_language.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_version.dart';
import 'package:cricket_scorer/core/global/domain/usecases/update_language.dart';
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:get/get.dart';

class GlobalInjection {
  GlobalInjection._();

  static void init() {
    const globalEndpoint = GlobalEndpoint();

    Get.lazyPut<LanguageApiService>(
      () => LanguageApiService(
        apiClient: Get.find<ApiClient>(),
        globalEndpoint: globalEndpoint,
      ),
      fenix: true,
    );

    Get.lazyPut<LanguageRepository>(
      () => LanguageRepositoryImpl(
        languageApiService: Get.find<LanguageApiService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetLanguageUseCase>(
      () => GetLanguageUseCase(
        languageRepository: Get.find<LanguageRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetVersionUseCase>(
      () => GetVersionUseCase(
        languageRepository: Get.find<LanguageRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetUserLanguageUseCase>(
      () => GetUserLanguageUseCase(
        languageRepository: Get.find<LanguageRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<UpdateLanguageUseCase>(
      () => UpdateLanguageUseCase(
        languageRepository: Get.find<LanguageRepository>(),
      ),
      fenix: true,
    );
  }
}
