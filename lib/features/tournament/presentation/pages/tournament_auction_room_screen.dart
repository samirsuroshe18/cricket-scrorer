import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/auction_room_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The live auction room — Task 16 fills in the player card, bid button,
/// live ticker, and countdown; this task only wires routing and DI so the
/// screen is reachable.
class TournamentAuctionRoomScreen extends StatelessWidget {
  const TournamentAuctionRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tournamentId = Get.parameters['tournamentId']?.trim() ?? '';
    final controller = Get.find<AuctionRoomController>(tag: tournamentId);

    return Scaffold(
      appBar: AppBar(title: Text(TranslationKeys.liveAuction.tr)),
      body: Obx(() => Center(child: Text(controller.sessionStatus.value ?? 'not_started'))),
    );
  }
}
