import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/request/verify_otp_req.dart';
import 'package:cricket_scorer/features/auth/data/models/response/verify_otp_res.dart';
import 'package:cricket_scorer/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtpUseCase
    implements
        UseCase<
          Either<CricketResponse<VerifyOtpRes>, CricketFailure>,
          VerifyOtpReq
        > {
  final AuthRepository authRepository;

  VerifyOtpUseCase({required this.authRepository});

  @override
  Future<Either<CricketResponse<VerifyOtpRes>, CricketFailure>> call({
    VerifyOtpReq? params,
  }) {
    return authRepository.verifyOtp(verifyOtp: params);
  }
}
