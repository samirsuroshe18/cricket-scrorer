import 'package:cricket_scorer/features/auth/domain/usecases/logout.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/delete_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_match_history.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => HomeController(
        logoutUseCase: Get.find<LogoutUseCase>(),
        getMatchHistoryUseCase: Get.find<GetMatchHistoryUseCase>(),
        deleteMatchUseCase: Get.find<DeleteMatchUseCase>(),
      ),
    );
  }
}
