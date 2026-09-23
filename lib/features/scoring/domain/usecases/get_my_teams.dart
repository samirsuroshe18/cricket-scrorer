import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/team_owner_filter.dart';

export 'package:cricket_scorer/features/scoring/domain/team_owner_filter.dart';

/// `search` narrows by name/shortName (case-insensitive substring), same as
/// the backend's `?q=`. Omitting `params` entirely (as every call site
/// before search/pagination existed still does) is equivalent to the
/// defaults below — page 1, no search, no owner filter.
class GetMyTeamsParams {
  final String? search;
  final int page;
  final int limit;
  final TeamOwnerFilter? owner;

  const GetMyTeamsParams({
    this.search,
    this.page = 1,
    this.limit = 20,
    this.owner,
  });
}

class GetMyTeamsUseCase
    implements
        UseCase<
          Either<CricketResponse<MyTeamsRes>, CricketFailure>,
          GetMyTeamsParams
        > {
  final MatchRepository matchRepository;

  GetMyTeamsUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<MyTeamsRes>, CricketFailure>> call({
    GetMyTeamsParams? params,
  }) {
    final effective = params ?? const GetMyTeamsParams();
    return matchRepository.getMyTeams(
      search: effective.search,
      page: effective.page,
      limit: effective.limit,
      owner: effective.owner,
    );
  }
}
