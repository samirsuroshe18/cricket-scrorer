import 'dart:io';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/data_sources/remote/user_api_service/user_api_service.dart';
import 'package:cricket_scorer/features/auth/data/models/login_request_model.dart';
import 'package:cricket_scorer/features/auth/data/models/login_response.dart';
import 'package:cricket_scorer/features/auth/data/models/request/forgot_pass_req.dart';
import 'package:cricket_scorer/features/auth/data/models/request/register_req.dart';
import 'package:cricket_scorer/features/auth/data/models/request/set_pass_req.dart';
import 'package:cricket_scorer/features/auth/data/models/request/update_profile_req.dart';
import 'package:cricket_scorer/features/auth/data/models/request/verify_otp_req.dart';
import 'package:cricket_scorer/features/auth/data/models/response/verify_otp_res.dart';
import 'package:cricket_scorer/features/auth/data/models/user.dart';
import 'package:cricket_scorer/features/auth/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl extends AuthRepository {
  final UserApiService userApiService;

  AuthRepositoryImpl({required this.userApiService});

  @override
  Future<Either<CricketResponse<User>, CricketFailure>> getUser() async {
    Either<ApiResponseModel, CricketFailure> response = await userApiService
        .getUser();
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: User.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<LoginResponse>, CricketFailure>> login({
    required LoginModel? loginModel,
  }) async {
    Either<ApiResponseModel, CricketFailure> response = await userApiService
        .login(params: loginModel);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: LoginResponse.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  forgotPassword({required ForgotPassReq? forgotPass}) async {
    Either<ApiResponseModel, CricketFailure> response = await userApiService
        .forgotPassword(params: forgotPass);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: {},
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<VerifyOtpRes>, CricketFailure>> verifyOtp({
    required VerifyOtpReq? verifyOtp,
  }) async {
    Either<ApiResponseModel, CricketFailure> response = await userApiService
        .verifyOtp(params: verifyOtp);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: VerifyOtpRes.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  resendOtp({required VerifyOtpReq? resendOtp}) async {
    Either<ApiResponseModel, CricketFailure> response = await userApiService
        .resendOtp(params: resendOtp);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: {},
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  register({required RegisterReq? registerParam}) async {
    Either<ApiResponseModel, CricketFailure> response = await userApiService
        .register(params: registerParam);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: {},
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  setPass({required SetPassReq? params}) async {
    Either<ApiResponseModel, CricketFailure> response = await userApiService
        .setPassword(params: params);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: {},
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  updateProfile({required UpdateProfileReq? params, File? file}) async {
    final formData = FormData.fromMap({
      ...?params?.toJson(),
      if (file != null)
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
    });

    Either<ApiResponseModel, CricketFailure> response = await userApiService
        .updateProfile(params: formData);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: {},
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>> logout({
    required String? refreshToken,
  }) async {
    Either<ApiResponseModel, CricketFailure> response = await userApiService
        .logout(refreshToken: refreshToken);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: {},
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }
}
