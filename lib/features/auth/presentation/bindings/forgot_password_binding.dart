import 'package:cricket_scorer/features/auth/domain/usecases/forgot_password.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:get/get.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(
        forgotPasswordUseCase: Get.find<ForgotPasswordUseCase>(),
      ),
    );
  }
}
