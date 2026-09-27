import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/team_player_view_repository.dart';

class GetTeamPlayerMatchesParams {
  final String teamId;
  final int page;
  final int limit;

  /// `all` / `live` / `upcoming` / `completed` — the server's `?status=`.
  final String status;

  const GetTeamPlayerMatchesParams({
    required this.teamId,
    this.page = 1,
    this.limit = 20,
    this.status = 'all',
  });
}

class GetTeamPlayerMatchesUseCase
    implements
        UseCase<
          Either<CricketResponse<MatchHistoryRes>, CricketFailure>,
          GetTeamPlayerMatchesParams
        > {
  final TeamPlayerViewRepository teamPlayerViewRepository;

  GetTeamPlayerMatchesUseCase({required this.teamPlayerViewRepository});

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>> call({
    GetTeamPlayerMatchesParams? params,
  }) {
    final resolved = params!;
    return teamPlayerViewRepository.getTeamPlayerMatches(
      teamId: resolved.teamId,
      page: resolved.page,
      limit: resolved.limit,
      status: resolved.status,
    );
  }
}
