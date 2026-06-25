import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/data/models/response/translation_model.dart';
import 'package:cricket_scorer/core/global/domain/repositories/language_repository.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';

class GetLanguageUseCase
    implements
        UseCase<
          Either<CricketResponse<List<TranslationModel>>, CricketFailure>,
          void
        > {
  final LanguageRepository languageRepository;

  GetLanguageUseCase({required this.languageRepository});

  @override
  Future<Either<CricketResponse<List<TranslationModel>>, CricketFailure>> call({
    void params,
  }) {
    return languageRepository.getLanguage();
  }
}
