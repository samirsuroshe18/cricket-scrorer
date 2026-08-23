import 'package:cricket_scorer/features/scoring/domain/usecases/create_match.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/create_match_controller.dart';
import 'package:get/get.dart';

class CreateMatchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateMatchController>(
      () => CreateMatchController(
        createMatchUseCase: Get.find<CreateMatchUseCase>(),
      ),
    );
  }
}
