import 'package:cricket_scorer/features/search/domain/usecases/search.dart';
import 'package:cricket_scorer/features/search/presentation/controllers/search_controller.dart';
import 'package:get/get.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CricketSearchController>(
      () => CricketSearchController(
        searchUseCase: Get.find<SearchUseCase>(),
      ),
    );
  }
}
