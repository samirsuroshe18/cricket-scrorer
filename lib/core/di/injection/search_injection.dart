import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/features/search/data/data_sources/remote/search_api_service.dart';
import 'package:cricket_scorer/features/search/data/repositories/search_repository_impl.dart';
import 'package:cricket_scorer/features/search/data/search_endpoint.dart';
import 'package:cricket_scorer/features/search/domain/repositories/search_repository.dart';
import 'package:cricket_scorer/features/search/domain/usecases/search.dart';
import 'package:get/get.dart';

class SearchInjection {
  SearchInjection._();

  static void init() {
    const searchEndpoint = SearchEndpoint();

    Get.lazyPut<SearchApiService>(
      () => SearchApiService(
        apiClient: Get.find<ApiClient>(),
        searchEndpoint: searchEndpoint,
      ),
      fenix: true,
    );

    Get.lazyPut<SearchRepository>(
      () => SearchRepositoryImpl(
        searchApiService: Get.find<SearchApiService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<SearchUseCase>(
      () => SearchUseCase(
        searchRepository: Get.find<SearchRepository>(),
      ),
      fenix: true,
    );
  }
}
