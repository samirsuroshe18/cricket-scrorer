import 'dart:io';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class UpdateTeamLogoParams {
  final String teamId;
  final File file;

  UpdateTeamLogoParams({required this.teamId, required this.file});
}

class UpdateTeamLogoUseCase
    implements
        UseCase<
          Either<CricketResponse<String>, CricketFailure>,
          UpdateTeamLogoParams
        > {
  final MatchRepository matchRepository;

  UpdateTeamLogoUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<String>, CricketFailure>> call({
    UpdateTeamLogoParams? params,
  }) {
    return matchRepository.updateTeamLogo(
      teamId: params!.teamId,
      file: params.file,
    );
  }
}
