import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/playing_for_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/team_player_view_repository.dart';

class GetPlayingForTeamsParams {
  final int page;
  final int limit;

  const GetPlayingForTeamsParams({this.page = 1, this.limit = 20});
}

class GetPlayingForTeamsUseCase
    implements
        UseCase<
          Either<CricketResponse<PlayingForTeamsRes>, CricketFailure>,
          GetPlayingForTeamsParams
        > {
  final TeamPlayerViewRepository teamPlayerViewRepository;

  GetPlayingForTeamsUseCase({required this.teamPlayerViewRepository});

  @override
  Future<Either<CricketResponse<PlayingForTeamsRes>, CricketFailure>> call({
    GetPlayingForTeamsParams? params,
  }) {
    final resolved = params!;
    return teamPlayerViewRepository.getPlayingForTeams(
      page: resolved.page,
      limit: resolved.limit,
    );
  }
}
