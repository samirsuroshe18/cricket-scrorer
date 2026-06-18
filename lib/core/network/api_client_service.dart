import 'dart:io';

import 'package:cricket_scorer/config/flavor_config.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/interceptors/auth_interceptor.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/services/flavor_service.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiClient extends GetxService {
  late final Dio _dio;

  late FlavorConfig _flavorConfig;

  Dio get dio => _dio;

  static CancelToken _cancelToken = CancelToken();

  static void cancelAllRequests() {
    _cancelToken.cancel();
    _cancelToken = CancelToken();
  }

  Future<ApiClient> init() async {
    _flavorConfig = Get.find<FlavorService>().config;

    _dio = Dio(
      BaseOptions(
        baseUrl: _flavorConfig.baseUrl,
        responseType: ResponseType.json,
        sendTimeout: const Duration(seconds: 60),
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    _dio.interceptors.add(AuthInterceptor());

    _dio.interceptors.add(
      PrettyDioLogger(
        enabled: kDebugMode,
        error: true,
        request: true,
        requestBody: true,
        requestHeader: true,
        responseBody: true,
        responseHeader: true,
        maxWidth: 90,
      ),
    );

    return this;
  }

  Future<Either<ApiResponseModel, CricketFailure>> get({
    Object? data,
    Options? options,
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    void Function(int count, int total)? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      Response<dynamic> response = await _dio.get(
        endpoint,
        onReceiveProgress: onReceiveProgress,
        data: data,
        options: options,
        cancelToken: cancelToken ?? _cancelToken,
        queryParameters: queryParameters,
      );

      return Either.result(
        ApiResponseModel.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Either.fallback(await _handleError(e));
    }
  }

  Future<Either<ApiResponseModel, CricketFailure>> post({
    required String endpoint,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParameters,
    void Function(int count, int total)? onSendProgress,
    void Function(int count, int total)? onReceiveProgress,
  }) async {
    try {
      Response<dynamic> response = await _dio.post(
        endpoint,
        data: data,
        options: options,
        cancelToken: cancelToken ?? _cancelToken,
        onSendProgress: onSendProgress,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );

      return Either.result(
        ApiResponseModel.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Either.fallback(await _handleError(e));
    }
  }

  Future<Either<ApiResponseModel, CricketFailure>> put({
    required String endpoint,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    void Function(int count, int total)? onSendProgress,
    void Function(int count, int total)? onReceiveProgress,
  }) async {
    try {
      Response<dynamic> response = await _dio.put(
        endpoint,
        data: data,
        cancelToken: cancelToken ?? _cancelToken,
        options: options,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
      );

      return Either.result(
        ApiResponseModel.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Either.fallback(await _handleError(e));
    }
  }

  Future<Either<ApiResponseModel, CricketFailure>> delete({
    required String endpoint,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      Response<dynamic> response = await _dio.delete(
        endpoint,
        data: data,
        cancelToken: cancelToken ?? _cancelToken,
        options: options,
      );

      return Either.result(
        ApiResponseModel.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Either.fallback(await _handleError(e));
    }
  }

  Future<CricketFailure> _handleError(dynamic error) async {
    try {
      if (error is DioException) {
        if (error.response == null) {
          if (error.error is SocketException) {
            return CricketNoInternetFailure(statusCode: 0);
          }
          return CricketServerErrorFailure();
        }
        switch (error.response?.statusCode ?? 0) {
          case 400:
            return CricketBadRequestFailure(
              message: error.response?.data['message'].toString(),
              statusCode: error.response?.data['statusCode'] as int?,
            );
          case 401:
            return CricketUnauthorizedErrorFailure(
              message:
                  error.response?.data['message'] as String? ??
                  'You are not authorized to access this resource...',
              statusCode: error.response?.data['statusCode'] as int?,
            );
          case 403:
            return CricketForbiddenErrorFailure(
              message: error.response?.data['message'] as String?,
              statusCode: error.response?.data['statusCode'] as int?,
            );
          case 404:
            return CricketNotFoundErrorFailure(
              message: error.response?.data['message'] as String?,
              statusCode: error.response?.data['statusCode'] as int?,
            );
          case 422:
            // return error.response!.data;
            return CricketSomethingWentWrongFailure(statusCode: 422);
          case >= 500:
            return CricketServerErrorFailure(statusCode: 500);
          default:
            return CricketSomethingWentWrongFailure();
        }
      }
      return CricketSomethingWentWrongFailure();
    } catch (_) {
      return CricketSomethingWentWrongFailure();
    }
  }
}
