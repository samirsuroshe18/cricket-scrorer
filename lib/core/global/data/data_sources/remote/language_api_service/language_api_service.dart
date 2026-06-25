import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/data/global_endpoint.dart';
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';

class LanguageApiService {
  final ApiClient apiClient;
  final GlobalEndpoint globalEndpoint;

  LanguageApiService({required this.apiClient, required this.globalEndpoint});

  Future<Either<ApiResponseModel, CricketFailure>> getLanguage() async {
    return await apiClient.get(endpoint: globalEndpoint.getLanguage);
  }

  Future<Either<ApiResponseModel, CricketFailure>> getVersion() async {
    return await apiClient.get(endpoint: globalEndpoint.getLangVersion);
  }

  Future<Either<ApiResponseModel, CricketFailure>> getUserLanguage() async {
    return await apiClient.get(endpoint: globalEndpoint.getUserLanguage);
  }

  Future<Either<ApiResponseModel, CricketFailure>> updateUserLanguage({
    required String lang,
  }) async {
    return await apiClient.put(
      endpoint: globalEndpoint.updateLanguage,
      data: {'language': lang},
    );
  }
}
