import 'package:cricket_scorer/features/auth/domain/usecases/set_password.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/set_password_controller.dart';
import 'package:get/get.dart';

class SetPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SetPasswordController>(
      () => SetPasswordController(
        resetPasswordUseCase: Get.find<ResetPasswordUseCase>(),
      ),
    );
  }
}
