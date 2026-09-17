import 'package:cricket_scorer/features/scoring/domain/usecases/claim_player.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/claim_player_controller.dart';
import 'package:get/get.dart';

class ClaimPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClaimPlayerController>(
      () => ClaimPlayerController(
        claimPlayerUseCase: Get.find<ClaimPlayerUseCase>(),
      ),
    );
  }
}
