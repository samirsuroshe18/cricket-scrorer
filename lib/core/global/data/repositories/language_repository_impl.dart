import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/data/data_sources/remote/language_api_service/language_api_service.dart';
import 'package:cricket_scorer/core/global/data/models/response/translation_model.dart';
import 'package:cricket_scorer/core/global/data/models/response/translation_version.dart';
import 'package:cricket_scorer/core/global/domain/repositories/language_repository.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';

class LanguageRepositoryImpl extends LanguageRepository {
  final LanguageApiService languageApiService;

  LanguageRepositoryImpl({required this.languageApiService});

  @override
  Future<Either<CricketResponse<List<TranslationModel>>, CricketFailure>>
  getLanguage() async {
    Either<ApiResponseModel, CricketFailure> response = await languageApiService
        .getLanguage();
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: (response.result.data as List).map((json) {
            return TranslationModel.fromJson(json as Map<String, dynamic>);
          }).toList(),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<TranslationVersion>, CricketFailure>>
  getVersion() async {
    Either<ApiResponseModel, CricketFailure> response = await languageApiService
        .getVersion();
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: TranslationVersion.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  getUserLanguage() async {
    Either<ApiResponseModel, CricketFailure> response = await languageApiService
        .getUserLanguage();
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: response.result.data as Map<String, dynamic>,
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  updateLanguage({required String language}) async {
    Either<ApiResponseModel, CricketFailure> response = await languageApiService
        .updateUserLanguage(lang: language);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: response.result.data as Map<String, dynamic>,
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }
}
