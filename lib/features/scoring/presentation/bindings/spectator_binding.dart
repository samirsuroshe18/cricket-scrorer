import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_public_match.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/spectator_controller.dart';
import 'package:get/get.dart';

/// The whole point of this binding is what it does NOT construct.
///
/// [ScoreBallUseCase], [StartInningsUseCase], [SelectBowlerUseCase] and
/// [UndoBallUseCase] are never referenced here, so [SpectatorController] has
/// no way to reach them — not "must not call them", but literally no
/// constructor parameter through which one could arrive. The same guarantee
/// docs/api.md states for the server (no inbound socket write, every scoring
/// route behind verifyJwt + createdBy) is enforced here at the shape of the
/// dependency graph: a spectator screen cannot accidentally acquire a
/// scoring capability during a refactor, because there is nothing to wire up.
class SpectatorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SpectatorController>(
      () => SpectatorController(
        getPublicMatchUseCase: Get.find<GetPublicMatchUseCase>(),
        matchRepository: Get.find<MatchRepository>(),
      ),
    );
  }
}
