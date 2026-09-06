import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/search/data/models/response/search_res.dart';
import 'package:cricket_scorer/features/search/domain/repositories/search_repository.dart';

class SearchParams {
  final String query;

  SearchParams({required this.query});
}

class SearchUseCase
    implements
        UseCase<Either<CricketResponse<SearchRes>, CricketFailure>,
            SearchParams> {
  final SearchRepository searchRepository;

  SearchUseCase({required this.searchRepository});

  @override
  Future<Either<CricketResponse<SearchRes>, CricketFailure>> call({
    SearchParams? params,
  }) {
    return searchRepository.search(query: params!.query);
  }
}
