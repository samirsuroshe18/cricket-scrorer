import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_auction_setup_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_setup_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The organizer's pre-event auction config surface — squad-composition
/// rules plus, per enrolled team, which org member owns it and their
/// budget. Reuses the tag-registered `TournamentDetailController` (same
/// pattern as standings/leaderboards): auction setup is one more piece of
/// tournament data, fetched lazily via `loadAuctionSetup()` only when this
/// screen actually opens.
///
/// One screen, one Save: the visible rows represent the *complete* current
/// state, not a partial edit, so `owners` is always sent (even empty) on
/// save.
class TournamentAuctionSetupScreen extends StatefulWidget {
  const TournamentAuctionSetupScreen({super.key});

  @override
  State<TournamentAuctionSetupScreen> createState() =>
      _TournamentAuctionSetupScreenState();
}

class _TournamentAuctionSetupScreenState
    extends State<TournamentAuctionSetupScreen> {
  late final String _tournamentId = Get.parameters['tournamentId']?.trim() ?? '';
  late final TournamentDetailController controller =
      Get.find<TournamentDetailController>(tag: _tournamentId);

  final _minSquadSizeController = TextEditingController();
  final _maxSquadSizeController = TextEditingController();
  final Map<String, String?> _selectedOwnerId = {};
  final Map<String, TextEditingController> _budgetControllers = {};

  bool _seeded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    controller.loadAuctionSetup();
  }

  @override
  void dispose() {
    _minSquadSizeController.dispose();
    _maxSquadSizeController.dispose();
    for (final c in _budgetControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Prefills every field once, the first time this is called with a
  /// resolved [setup] — mirrors `edit_tournament_sheet.dart`'s own one-shot
  /// prefill reasoning, since this is transient form state the controller
  /// shouldn't own. Callers only invoke this once `tournament`/`setup` are
  /// both known-final for this render (see the loading guard in `build`) —
  /// gating on `_seeded` alone here (rather than re-checking the loading
  /// flags) avoids a mismatch where the outer guard has already decided the
  /// data is ready but this method's own guard disagrees and skips seeding,
  /// leaving the per-team maps empty while the row widgets below still try
  /// to read them.
  void _maybeSeed(TournamentDetailRes tournament, AuctionSetupRes? setup) {
    if (_seeded) return;
    _seeded = true;

    _minSquadSizeController.text = setup?.minSquadSize?.toString() ?? '';
    _maxSquadSizeController.text = setup?.maxSquadSize?.toString() ?? '';

    for (final team in tournament.teams) {
      AuctionOwnerRes? existing;
      for (final owner in setup?.owners ?? const <AuctionOwnerRes>[]) {
        if (owner.teamId == team.id) {
          existing = owner;
          break;
        }
      }
      _selectedOwnerId[team.id] = existing?.userId;
      _budgetControllers[team.id] =
          TextEditingController(text: existing?.budget.toString() ?? '');
    }
  }

  Future<void> _save() async {
    final tournament = controller.detail.value;
    if (tournament == null) return;

    final owners = <AuctionOwnerInput>[];
    for (final team in tournament.teams) {
      final ownerId = _selectedOwnerId[team.id];
      final budgetText = _budgetControllers[team.id]?.text.trim() ?? '';
      if (ownerId == null || budgetText.isEmpty) continue;
      final budget = int.tryParse(budgetText);
      if (budget == null) continue;
      owners.add(AuctionOwnerInput(teamId: team.id, userId: ownerId, budget: budget));
    }

    final minText = _minSquadSizeController.text.trim();
    final maxText = _maxSquadSizeController.text.trim();

    setState(() => _saving = true);
    final success = await controller.updateAuctionSetup(
      minSquadSize: minText.isEmpty ? null : int.tryParse(minText),
      maxSquadSize: maxText.isEmpty ? null : int.tryParse(maxText),
      owners: owners,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      CricketSnackbar.showSuccessMessage(TranslationKeys.auctionSetupSaved.tr);
    } else {
      CricketSnackbar.showErrorMessage(TranslationKeys.somethingWentWrong.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.auctionSetup.tr),
      body: SafeArea(
        child: Obx(() {
          final tournamentLoading = controller.isLoading.value;
          final auctionLoading = controller.auctionSetupLoading.value;
          final error = controller.auctionSetupError.value;
          final tournament = controller.detail.value;
          final organization = controller.organizationDetail.value;
          final setup = controller.auctionSetup.value;

          // The tournament/organization fetch and the auction-setup fetch
          // are two independent requests (see TournamentDetailController) —
          // each gate below checks only the flag its own outcome depends
          // on, rather than a combined flag, so a fast failure on one
          // request can't stay hidden behind a slow-to-resolve spinner from
          // the other.
          if (auctionLoading && setup == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null && setup == null) {
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
                      onPressed: controller.loadAuctionSetup,
                      width: 160,
                    ),
                  ],
                ),
              ),
            );
          }
          if (tournamentLoading && (tournament == null || organization == null)) {
            return const Center(child: CircularProgressIndicator());
          }
          if (tournament == null || organization == null || setup == null) {
            return const SizedBox.shrink();
          }

          _maybeSeed(tournament, setup);

          final isOwner = controller.isOwner;

          return SingleChildScrollView(
            padding: 16.p,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CricketText(
                  text: TranslationKeys.squadRules.tr,
                  style: context.textTheme.titleSmall,
                ),
                12.h,
                CricketTextField(
                  key: const Key('minSquadSizeField'),
                  controller: _minSquadSizeController,
                  labelText: TranslationKeys.minSquadSize.tr,
                  hintText: TranslationKeys.minSquadSize.tr,
                  keyboardType: TextInputType.number,
                ),
                12.h,
                CricketTextField(
                  key: const Key('maxSquadSizeField'),
                  controller: _maxSquadSizeController,
                  labelText: TranslationKeys.maxSquadSize.tr,
                  hintText: TranslationKeys.maxSquadSize.tr,
                  keyboardType: TextInputType.number,
                ),
                24.h,
                CricketText(
                  text: TranslationKeys.teams.tr,
                  style: context.textTheme.titleSmall,
                ),
                12.h,
                for (final team in tournament.teams) ...[
                  _TeamOwnerRow(
                    team: team,
                    members: organization.members,
                    selectedOwnerId: _selectedOwnerId[team.id],
                    budgetController: _budgetControllers[team.id]!,
                    enabled: isOwner,
                    onOwnerChanged: (ownerId) =>
                        setState(() => _selectedOwnerId[team.id] = ownerId),
                  ),
                  12.h,
                ],
                if (isOwner) ...[
                  12.h,
                  CricketButton(
                    buttonText: TranslationKeys.save.tr,
                    onPressed: _save,
                    isDisabled: _saving,
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TeamOwnerRow extends StatelessWidget {
  const _TeamOwnerRow({
    required this.team,
    required this.members,
    required this.selectedOwnerId,
    required this.budgetController,
    required this.enabled,
    required this.onOwnerChanged,
  });

  final TournamentTeamRef team;
  final List<OrganizationMemberRes> members;
  final String? selectedOwnerId;
  final TextEditingController budgetController;
  final bool enabled;
  final ValueChanged<String?> onOwnerChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 12.p,
      decoration: BoxDecoration(
        color: context.colors.chipBackground.withValues(alpha: 0.4),
        borderRadius: 12.radius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CricketText(
            text: team.name,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          8.h,
          DropdownButtonFormField<String?>(
            key: Key('ownerDropdown_${team.id}'),
            initialValue: selectedOwnerId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: TranslationKeys.teamOwner.tr,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: CricketText(text: TranslationKeys.noOwnerAssigned.tr),
              ),
              for (final member in members)
                DropdownMenuItem<String?>(
                  value: member.id,
                  child: CricketText(text: member.name),
                ),
            ],
            onChanged: enabled ? onOwnerChanged : null,
          ),
          8.h,
          CricketTextField(
            key: Key('budgetField_${team.id}'),
            controller: budgetController,
            labelText: TranslationKeys.budget.tr,
            hintText: TranslationKeys.budget.tr,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
