import 'package:cricket_scorer/features/scoring/domain/usecases/claim_player.dart';
import 'package:get/get.dart';

/// The confirmation screen a `cricketscorer:///claim-player/<id>?name=<name>`
/// link opens — self-service only (see docs/api.md's
/// `POST /v1/player/:playerId/claim`): this screen exists specifically so
/// claiming is a deliberate tap by the account holder themselves, never
/// something that happens just by a link being opened.
class ClaimPlayerController extends GetxController {
  final ClaimPlayerUseCase claimPlayerUseCase;

  ClaimPlayerController({required this.claimPlayerUseCase});

  late final String playerId;
  late final String playerName;

  final isSubmitting = false.obs;
  final claimed = false.obs;
  final errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    playerId = Get.parameters['playerId'] ?? '';
    playerName = Get.parameters['name'] ?? '';
  }

  Future<void> confirmClaim() async {
    if (playerId.isEmpty || isSubmitting.value) return;

    isSubmitting.value = true;
    errorMessage.value = null;

    final response = await claimPlayerUseCase(params: playerId);

    isSubmitting.value = false;

    if (response.isResult) {
      claimed.value = true;
    } else {
      errorMessage.value = response.fallback.message;
    }
  }
}
