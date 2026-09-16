import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/main_shell_controller.dart';
import 'package:cricket_scorer/features/home/presentation/pages/home_dashboard_tab.dart';
import 'package:cricket_scorer/features/home/presentation/pages/matches_tab.dart';
import 'package:cricket_scorer/features/home/presentation/pages/profile_tab.dart';
import 'package:cricket_scorer/features/home/presentation/pages/teams_tab.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Registered at [AppRoutes.home] — the app's real entry point now, not
/// `HomePage`'s old flat match list. Four tabs (Home/Matches/Teams/Profile)
/// live inside one `IndexedStack` so switching tabs never re-triggers a
/// fetch, plus one persistent "Start Match" FAB shown only where it's the
/// primary action (Home and Matches), not on Teams or Profile.
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
        floatingActionButton: (index == 0 || index == 1)
            ? FloatingActionButton.extended(
                onPressed: () => Get.toNamed<dynamic>(AppRoutes.createMatch),
                icon: const Icon(Icons.add),
                label: CricketText(text: TranslationKeys.startMatch.tr),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: shell.showTab,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: TranslationKeys.navHome.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.sports_cricket_outlined),
              activeIcon: const Icon(Icons.sports_cricket),
              label: TranslationKeys.navMatches.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.groups_outlined),
              activeIcon: const Icon(Icons.groups),
              label: TranslationKeys.navTeams.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: TranslationKeys.navProfile.tr,
            ),
          ],
        ),
      );
    });
  }
}
