import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/main_shell_controller.dart';
import 'package:cricket_scorer/features/home/presentation/pages/home_dashboard_tab.dart';
import 'package:cricket_scorer/features/home/presentation/pages/matches_tab.dart';
import 'package:cricket_scorer/features/home/presentation/pages/profile_tab.dart';
import 'package:cricket_scorer/features/home/presentation/pages/teams_tab.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Registered at [AppRoutes.home] — the app's real entry point now, not
/// `HomePage`'s old flat match list. Four tabs (Home/Matches/Teams/Profile)
/// live inside one `IndexedStack` so switching tabs never re-triggers a
/// fetch. "Start Match" is the bar's docked centre button, available from
/// every tab rather than floating over the lists on two of them.
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  static const _tabs = [
    HomeDashboardTab(),
    MatchesTab(),
    TeamsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<MainShellController>();

    return Obx(() {
      final index = shell.tabIndex.value;
      return Scaffold(
        body: IndexedStack(index: index, children: _tabs),
        bottomNavigationBar: HomeBottomBar(
          currentIndex: index,
          onSelect: shell.showTab,
          actionLabel: TranslationKeys.startMatch.tr,
          onAction: () => Get.toNamed<dynamic>(AppRoutes.createMatch),
          items: [
            HomeNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: TranslationKeys.navHome.tr,
            ),
            HomeNavItem(
              icon: Icons.sports_cricket_outlined,
              activeIcon: Icons.sports_cricket,
              label: TranslationKeys.navMatches.tr,
            ),
            HomeNavItem(
              icon: Icons.groups_outlined,
              activeIcon: Icons.groups_rounded,
              label: TranslationKeys.navTeams.tr,
            ),
            HomeNavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: TranslationKeys.navProfile.tr,
            ),
          ],
        ),
      );
    });
  }
}
