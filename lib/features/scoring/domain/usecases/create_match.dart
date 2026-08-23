import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_match_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class CreateMatchUseCase
    implements
        UseCase<
          Either<CricketResponse<CreateMatchRes>, CricketFailure>,
          CreateMatchReq
        > {
  final MatchRepository matchRepository;

  CreateMatchUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<CreateMatchRes>, CricketFailure>> call({
    CreateMatchReq? params,
  }) {
    return matchRepository.createMatch(createMatchReq: params);
  }
}
