import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/request/forgot_pass_req.dart';
import 'package:cricket_scorer/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase
    implements
        UseCase<Either<CricketResponse<void>, CricketFailure>, ForgotPassReq> {
  final AuthRepository authRepository;

  ForgotPasswordUseCase({required this.authRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    ForgotPassReq? params,
  }) {
    return authRepository.forgotPassword(forgotPass: params);
  }
}
