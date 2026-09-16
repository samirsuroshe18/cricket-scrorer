import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:get/get.dart';

/// Every team the caller has ever created or played under — ad-hoc and
/// organization-owned alike, per `GET /v1/team`. Wires the existing
/// [GetMyTeamsUseCase] (already used by `CreateMatchController`'s
/// reuse-a-team picker) into a destination of its own for the first time —
/// the Teams tab — rather than any new backend logic.
class MyTeamsController extends GetxController {
  final GetMyTeamsUseCase getMyTeamsUseCase;

  MyTeamsController({required this.getMyTeamsUseCase});

  final teams = <TeamSummary>[].obs;
  final isLoading = true.obs;
  final loadError = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadMyTeams();
  }

  Future<void> loadMyTeams() async {
    isLoading.value = true;
    loadError.value = null;

    final response = await getMyTeamsUseCase();

    isLoading.value = false;

    if (response.isResult) {
      teams.assignAll(response.result.data?.teams ?? []);
    } else {
      loadError.value = response.fallback.message;
    }
  }
}
