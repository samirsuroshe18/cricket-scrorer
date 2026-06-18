import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/auth_endpoint.dart';
import 'package:cricket_scorer/features/auth/data/models/login_request_model.dart';
import 'package:cricket_scorer/features/auth/data/models/request/forgot_pass_req.dart';
import 'package:cricket_scorer/features/auth/data/models/request/register_req.dart';
import 'package:cricket_scorer/features/auth/data/models/request/set_pass_req.dart';
import 'package:cricket_scorer/features/auth/data/models/request/verify_otp_req.dart';
import 'package:dio/dio.dart';

class UserApiService {
  final ApiClient apiClient;
  final AuthEndpoint authEndpoint;

  UserApiService({required this.apiClient, required this.authEndpoint});

  Future<Either<ApiResponseModel, CricketFailure>> getUser() async {
    return await apiClient.get(endpoint: authEndpoint.getUser);
  }

  Future<Either<ApiResponseModel, CricketFailure>> login({
    required LoginModel? params,
  }) async {
    return await apiClient.post(
      endpoint: authEndpoint.login,
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> forgotPassword({
    required ForgotPassReq? params,
  }) async {
    return await apiClient.post(
      endpoint: authEndpoint.forgotPassword,
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> verifyOtp({
    required VerifyOtpReq? params,
  }) async {
    return await apiClient.post(
      endpoint: authEndpoint.verifyOtp,
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> resendOtp({
    required VerifyOtpReq? params,
  }) async {
    return await apiClient.post(
      endpoint: authEndpoint.resendOtp,
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> register({
    required RegisterReq? params,
  }) async {
    return await apiClient.post(
      endpoint: authEndpoint.register,
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> setPassword({
    required SetPassReq? params,
  }) async {
    return await apiClient.post(
      endpoint: authEndpoint.setPass,
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> updateProfile({
    required FormData? params,
  }) async {
    return await apiClient.post(
      endpoint: authEndpoint.updateProfile,
      data: params,
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> logout({
    required String? refreshToken,
  }) async {
    return await apiClient.get(
      endpoint: authEndpoint.logout,
      options: Options(
        headers: {
          'Authorization': 'Bearer $refreshToken',
        },
      ),
    );
  }
}
