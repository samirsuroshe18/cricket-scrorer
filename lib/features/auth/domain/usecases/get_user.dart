import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/user.dart';
import 'package:cricket_scorer/features/auth/domain/repositories/auth_repository.dart';

class GetUserUseCase
    implements UseCase<Either<CricketResponse<User>, CricketFailure>, void> {
  final AuthRepository authRepository;

  GetUserUseCase({required this.authRepository});

  @override
  Future<Either<CricketResponse<User>, CricketFailure>> call({
    void params,
  }) {
    return authRepository.getUser();
  }
}
