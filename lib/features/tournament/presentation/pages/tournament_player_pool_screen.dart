import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/pool_entry_res.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/pool_player_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A tournament's auction pool — reached from `TournamentDetailScreen`'s
/// "Player pool" action. Reuses that screen's own tag-registered
/// `TournamentDetailController`, same pattern as standings/leaderboards:
/// one more piece of tournament data, fetched lazily via `loadPool()` only
/// when this screen actually opens.
class TournamentPlayerPoolScreen extends StatefulWidget {
  const TournamentPlayerPoolScreen({super.key});

  @override
  State<TournamentPlayerPoolScreen> createState() =>
      _TournamentPlayerPoolScreenState();
}

class _TournamentPlayerPoolScreenState
    extends State<TournamentPlayerPoolScreen> {
  late final String _tournamentId = Get.parameters['tournamentId']?.trim() ?? '';
  late final TournamentDetailController controller =
      Get.find<TournamentDetailController>(tag: _tournamentId);

  @override
  void initState() {
    super.initState();
    controller.loadPool();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: TranslationKeys.playerPool.tr,
        actions: [
          Obx(() {
            if (!controller.isOwner) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.person_add_alt_outlined),
              onPressed: () => showPoolPlayerSheet(controller: controller),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final loading = controller.poolLoading.value;
          final error = controller.poolError.value;
          final entries = controller.poolEntries;

          if (loading && entries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null && entries.isEmpty) {
            return Center(
              child: Padding(
                padding: 24.p,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 56,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    16.h,
                    CricketText(text: error, textAlign: TextAlign.center),
                    24.h,
                    CricketButton(
                      buttonText: TranslationKeys.retry.tr,
                      onPressed: controller.loadPool,
                      width: 160,
                    ),
                  ],
                ),
              ),
            );
          }
          if (entries.isEmpty) {
            return Center(
              child: CricketText(
                text: TranslationKeys.noPlayersInPoolYet.tr,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadPool,
            child: ListView.separated(
              padding: 16.p,
              itemCount: entries.length,
              separatorBuilder: (_, _) => 8.h,
              itemBuilder: (context, index) =>
                  _PoolEntryTile(entry: entries[index], controller: controller),
            ),
          );
        }),
      ),
    );
  }
}

class _PoolEntryTile extends StatelessWidget {
  const _PoolEntryTile({required this.entry, required this.controller});

  final PoolEntryRes entry;
  final TournamentDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 12.p,
      decoration: BoxDecoration(
        color: context.colors.chipBackground,
        borderRadius: 12.radius,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CricketText(
                  text: entry.playerName,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                4.h,
                CricketText(
                  text: entry.role,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          CricketText(
            text: '${entry.basePrice}',
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.primary,
            ),
          ),
          Obx(() {
            if (!controller.isOwner) return const SizedBox.shrink();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => showPoolPlayerSheet(
                    controller: controller,
                    existingEntry: entry,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => controller.removePoolEntry(entry.playerId),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
