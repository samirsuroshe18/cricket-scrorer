import 'package:cricket_scorer/features/auth/domain/usecases/get_user.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/splash_controller.dart';
import 'package:get/get.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(
        getUserUseCase: Get.find<GetUserUseCase>(),
      ),
    );
  }
}
