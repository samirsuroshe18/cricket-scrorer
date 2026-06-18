import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/request/set_pass_req.dart';
import 'package:cricket_scorer/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase
    implements
        UseCase<Either<CricketResponse<void>, CricketFailure>, SetPassReq> {
  final AuthRepository authRepository;

  ResetPasswordUseCase({required this.authRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    SetPassReq? params,
  }) {
    return authRepository.setPass(params: params);
  }
}
