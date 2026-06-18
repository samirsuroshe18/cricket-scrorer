import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/login_request_model.dart';
import 'package:cricket_scorer/features/auth/data/models/login_response.dart';
import 'package:cricket_scorer/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase
    implements
        UseCase<
          Either<CricketResponse<LoginResponse>, CricketFailure>,
          LoginModel
        > {
  final AuthRepository authRepository;

  LoginUseCase({required this.authRepository});

  @override
  Future<Either<CricketResponse<LoginResponse>, CricketFailure>> call({
    LoginModel? params,
  }) {
    return authRepository.login(loginModel: params);
  }
}
