import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/next_auction_lot.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/pause_auction.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resume_auction.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_auction.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/auction_room_controller.dart';
import 'package:get/get.dart';

class AuctionRoomBinding extends Bindings {
  @override
  void dependencies() {
    final tournamentId = Get.parameters['tournamentId']?.trim() ?? '';
    Get.lazyPut<AuctionRoomController>(
      () => AuctionRoomController(
        tournamentId: tournamentId,
        tournamentRepository: Get.find<TournamentRepository>(),
        startAuctionUseCase: Get.find<StartAuctionUseCase>(),
        pauseAuctionUseCase: Get.find<PauseAuctionUseCase>(),
        resumeAuctionUseCase: Get.find<ResumeAuctionUseCase>(),
        nextAuctionLotUseCase: Get.find<NextAuctionLotUseCase>(),
      ),
      tag: tournamentId,
    );
  }
}
