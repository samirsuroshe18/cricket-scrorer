import 'dart:async';

import 'package:cricket_scorer/features/search/data/models/response/search_res.dart';
import 'package:cricket_scorer/features/search/domain/usecases/search.dart';
import 'package:get/get.dart';

/// Search-as-you-type over `GET /v1/search` — debounced so every keystroke
/// doesn't fire its own request, and guarded against stale responses: a
/// slow early keystroke's result must never overwrite a faster later one's,
/// which plain "last request wins by callback order" would get wrong.
class CricketSearchController extends GetxController {
  final SearchUseCase searchUseCase;
  final Duration debounceDuration;

  CricketSearchController({
    required this.searchUseCase,
    this.debounceDuration = const Duration(milliseconds: 400),
  });

  final query = ''.obs;
  final isLoading = false.obs;
  final error = Rxn<String>();

  /// False until the first real (non-empty) search has resolved — lets the
  /// screen distinguish "haven't searched yet" from "searched, found
  /// nothing" without a separate flag for every empty-result case.
  final hasSearched = false.obs;

  final organizations = <SearchOrganizationRes>[].obs;
  final tournaments = <SearchTournamentRes>[].obs;

  Timer? _debounceTimer;

  void onQueryChanged(String value) {
    query.value = value;
    _debounceTimer?.cancel();

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _resetToIdle();
      return;
    }

    _debounceTimer = Timer(debounceDuration, () => _runSearch(trimmed));
  }

  void _resetToIdle() {
    _debounceTimer = null;
    isLoading.value = false;
    error.value = null;
    hasSearched.value = false;
    organizations.clear();
    tournaments.clear();
  }

  Future<void> _runSearch(String trimmedQuery) async {
    isLoading.value = true;
    error.value = null;

    final response = await searchUseCase(params: SearchParams(query: trimmedQuery));

    // The query may have changed again (and that newer request may have
    // already resolved) while this one was in flight — dropping a stale
    // response here is what keeps a slow request from clobbering a fast one.
    if (query.value.trim() != trimmedQuery) return;

    hasSearched.value = true;
    isLoading.value = false;

    if (!response.isResult) {
      error.value = response.fallback.message;
      return;
    }

    organizations.assignAll(response.result.data!.organizations);
    tournaments.assignAll(response.result.data!.tournaments);
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
