import 'dart:io';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/login_request_model.dart';
import 'package:cricket_scorer/features/auth/data/models/login_response.dart';
import 'package:cricket_scorer/features/auth/data/models/request/forgot_pass_req.dart';
import 'package:cricket_scorer/features/auth/data/models/request/register_req.dart';
import 'package:cricket_scorer/features/auth/data/models/request/set_pass_req.dart';
import 'package:cricket_scorer/features/auth/data/models/request/update_profile_req.dart';
import 'package:cricket_scorer/features/auth/data/models/request/verify_otp_req.dart';
import 'package:cricket_scorer/features/auth/data/models/response/verify_otp_res.dart';
import 'package:cricket_scorer/features/auth/data/models/user.dart';

abstract class AuthRepository {
  Future<Either<CricketResponse<LoginResponse>, CricketFailure>> login({
    required LoginModel? loginModel,
  });

  Future<Either<CricketResponse<User>, CricketFailure>> getUser();

  Future<Either<CricketResponse<void>, CricketFailure>> forgotPassword({
    required ForgotPassReq? forgotPass,
  });

  Future<Either<CricketResponse<VerifyOtpRes>, CricketFailure>> verifyOtp({
    required VerifyOtpReq? verifyOtp,
  });

  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  resendOtp({
    required VerifyOtpReq? resendOtp,
  });

  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  register({
    required RegisterReq? registerParam,
  });

  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  setPass({
    required SetPassReq? params,
  });

  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  updateProfile({
    required UpdateProfileReq? params,
    File? file,
  });

  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>> logout({
    required String? refreshToken,
  });
}
