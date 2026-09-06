import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/search/data/data_sources/remote/search_api_service.dart';
import 'package:cricket_scorer/features/search/data/models/response/search_res.dart';
import 'package:cricket_scorer/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchApiService searchApiService;

  SearchRepositoryImpl({required this.searchApiService});

  @override
  Future<Either<CricketResponse<SearchRes>, CricketFailure>> search({
    required String query,
  }) async {
    final response = await searchApiService.search(query: query);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: SearchRes.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    }
    return Either.fallback(response.fallback);
  }
}
