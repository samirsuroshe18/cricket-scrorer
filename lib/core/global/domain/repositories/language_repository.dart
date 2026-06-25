import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/data/models/response/translation_model.dart';
import 'package:cricket_scorer/core/global/data/models/response/translation_version.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';

abstract class LanguageRepository {
  Future<Either<CricketResponse<List<TranslationModel>>, CricketFailure>>
  getLanguage();

  Future<Either<CricketResponse<TranslationVersion>, CricketFailure>>
  getVersion();

  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  getUserLanguage();

  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  updateLanguage({required String language});
}
