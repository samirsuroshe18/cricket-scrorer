import 'package:cricket_scorer/core/global/domain/usecases/get_language.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_version.dart';
import 'package:cricket_scorer/core/global/domain/usecases/update_language.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/login.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/login_controller.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(
        loginUseCase: Get.find<LoginUseCase>(),
        getVersionUseCase: Get.find<GetVersionUseCase>(),
        getLanguageUseCase: Get.find<GetLanguageUseCase>(),
        updateLanguageUseCase: Get.find<UpdateLanguageUseCase>(),
      ),
    );
  }
}
