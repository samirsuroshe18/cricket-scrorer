import 'package:cricket_scorer/features/auth/domain/usecases/register.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/register_controller.dart';
import 'package:get/get.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(
      () => RegisterController(
        registerUseCase: Get.find<RegisterUseCase>(),
      ),
    );
  }
}
