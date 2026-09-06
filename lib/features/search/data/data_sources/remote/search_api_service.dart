import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/search/data/search_endpoint.dart';

class SearchApiService {
  final ApiClient apiClient;
  final SearchEndpoint searchEndpoint;

  SearchApiService({required this.apiClient, required this.searchEndpoint});

  Future<Either<ApiResponseModel, CricketFailure>> search({
    required String query,
  }) async {
    return await apiClient.get(
      endpoint: searchEndpoint.search,
      queryParameters: {'q': query},
    );
  }
}
