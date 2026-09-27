import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/looked_up_user_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/player_invite_repository.dart';

class LookupUserParams {
  final String email;

  LookupUserParams({required this.email});
}

class LookupUserByEmailUseCase
    implements
        UseCase<
          Either<CricketResponse<LookedUpUserRes>, CricketFailure>,
          LookupUserParams
        > {
  final PlayerInviteRepository playerInviteRepository;

  LookupUserByEmailUseCase({required this.playerInviteRepository});

  @override
  Future<Either<CricketResponse<LookedUpUserRes>, CricketFailure>> call({
    LookupUserParams? params,
  }) {
    return playerInviteRepository.lookupUserByEmail(
      email: params!.email,
    );
  }
}
