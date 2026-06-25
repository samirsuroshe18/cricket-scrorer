import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/data/models/response/translation_version.dart';
import 'package:cricket_scorer/core/global/domain/repositories/language_repository.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/login_request_model.dart';

class GetVersionUseCase
    implements
        UseCase<
          Either<CricketResponse<TranslationVersion>, CricketFailure>,
          LoginModel
        > {
  final LanguageRepository languageRepository;

  GetVersionUseCase({required this.languageRepository});

  @override
  Future<Either<CricketResponse<TranslationVersion>, CricketFailure>> call({
    void params,
  }) {
    return languageRepository.getVersion();
  }
}
