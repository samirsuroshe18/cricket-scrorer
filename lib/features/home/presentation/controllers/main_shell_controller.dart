import 'package:get/get.dart';

/// Which of the four bottom-nav tabs (Home/Matches/Teams/Profile) is
/// showing inside [MainShellScreen]'s `IndexedStack` — presentation-only
/// state, not a route change, so every tab's own controller (`HomeController`
/// included) stays alive and doesn't re-fetch when switching tabs.
class MainShellController extends GetxController {
  final tabIndex = 0.obs;

  void showTab(int index) => tabIndex.value = index;
}
