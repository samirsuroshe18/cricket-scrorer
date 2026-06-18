import 'package:cricket_scorer/features/auth/domain/usecases/login.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/login_controller.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(
        loginUseCase: Get.find<LoginUseCase>(),
      ),
    );
  }
}
