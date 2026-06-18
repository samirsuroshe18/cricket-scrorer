import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/request/register_req.dart';
import 'package:cricket_scorer/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase
    implements
        UseCase<
          Either<CricketResponse<Map<String, dynamic>>, CricketFailure>,
          RegisterReq
        > {
  final AuthRepository authRepository;

  RegisterUseCase({required this.authRepository});

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>> call({
    RegisterReq? params,
  }) {
    return authRepository.register(registerParam: params);
  }
}
