import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/search/data/models/response/search_res.dart';
import 'package:cricket_scorer/features/search/presentation/controllers/search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Name search across every organization and tournament, regardless of the
/// caller's membership — reached from Home's app bar. Debounced
/// search-as-you-type; see [CricketSearchController] for the debounce and
/// stale-response-guard logic this screen just renders the output of.
class SearchScreen extends GetView<CricketSearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.search.tr),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: 16.p,
              child: CricketTextField(
                hintText: TranslationKeys.searchHint.tr,
                prefixIcon: const Icon(Icons.search),
                onChanged: controller.onQueryChanged,
              ),
            ),
            Expanded(
              child: Obx(() {
                final hasQuery = controller.query.value.trim().isNotEmpty;
                final loading = controller.isLoading.value;
                final error = controller.error.value;
                final hasSearched = controller.hasSearched.value;
                final organizations = controller.organizations;
                final tournaments = controller.tournaments;

                if (!hasQuery) {
                  return Center(
                    child: Icon(
                      Icons.search,
                      size: 56,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                if (loading && !hasSearched) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (error != null) {
                  return _MessageState(
                    icon: Icons.error_outline,
                    message: error,
                    action: CricketButton(
                      buttonText: TranslationKeys.retry.tr,
                      onPressed: () =>
                          controller.onQueryChanged(controller.query.value),
                      width: 160,
                    ),
                  );
                }
                if (hasSearched && organizations.isEmpty && tournaments.isEmpty) {
                  return _MessageState(
                    icon: Icons.search_off,
                    message: TranslationKeys.noSearchResultsFound.tr,
                  );
                }

                return ListView(
                  padding: 16.p,
                  children: [
                    if (organizations.isNotEmpty) ...[
                      CricketText(
                        text: TranslationKeys.organizations.tr,
                        style: context.textTheme.titleSmall,
                      ),
                      8.h,
                      for (final org in organizations) ...[
                        _OrganizationResultRow(org: org),
                        8.h,
                      ],
                      16.h,
                    ],
                    if (tournaments.isNotEmpty) ...[
                      CricketText(
                        text: TranslationKeys.tournaments.tr,
                        style: context.textTheme.titleSmall,
                      ),
                      8.h,
                      for (final t in tournaments) ...[
                        _TournamentResultRow(tournament: t),
                        8.h,
                      ],
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: 24.p,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: context.colorScheme.onSurfaceVariant),
            16.h,
            CricketText(
              text: message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            if (action != null) ...[24.h, action!],
          ],
        ),
      ),
    );
  }
}

class _OrganizationResultRow extends StatelessWidget {
  const _OrganizationResultRow({required this.org});

  final SearchOrganizationRes org;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surfaceContainerHighest,
      borderRadius: 12.radius,
      child: InkWell(
        borderRadius: 12.radius,
        onTap: () => Get.toNamed<dynamic>(AppRoutes.organizationDetailPath(org.id)),
        child: Padding(
          padding: 12.p,
          child: Row(
            children: [
              Icon(Icons.groups_outlined, color: context.colorScheme.primary),
              12.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CricketText(text: org.name, style: context.textTheme.titleSmall),
                    CricketText(
                      text: '${org.memberCount} ${TranslationKeys.members.tr}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: context.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _TournamentResultRow extends StatelessWidget {
  const _TournamentResultRow({required this.tournament});

  final SearchTournamentRes tournament;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surfaceContainerHighest,
      borderRadius: 12.radius,
      child: InkWell(
        borderRadius: 12.radius,
        onTap: () => Get.toNamed<dynamic>(AppRoutes.tournamentDetailPath(tournament.id)),
        child: Padding(
          padding: 12.p,
          child: Row(
            children: [
              Icon(Icons.emoji_events_outlined, color: context.colorScheme.primary),
              12.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CricketText(text: tournament.name, style: context.textTheme.titleSmall),
                    CricketText(
                      text: tournament.organizationName,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: context.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
