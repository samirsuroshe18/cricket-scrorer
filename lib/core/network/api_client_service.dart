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

  /// The token every request not given its own explicit `cancelToken`
  /// carries — including [AuthInterceptor]'s own retry after a token
  /// refresh, which builds its request by hand on the raw [Dio] instance
  /// rather than through this class's get/post/etc wrappers, and so would
  /// otherwise carry no cancel token at all.
  static CancelToken get currentCancelToken => _cancelToken;

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

  // Every timeout/connection-error variant, alongside a raw SocketException,
  // means Dio never got a response at all — a slow or patchy connection is
  // exactly the same "we can't reach the server" fact as an outright drop,
  // and the offline queue's fallback trigger depends on both reading as
  // CricketNoInternetFailure. Before this, only a bare SocketException did;
  // a timeout fell through to a generic CricketServerErrorFailure, which is
  // indistinguishable from a real 500 and would never route to the queue.
  static const _networkFailureTypes = {
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionError,
  };

  Future<CricketFailure> _handleError(dynamic error) async {
    try {
      if (error is DioException) {
        if (error.response == null) {
          if (error.error is SocketException ||
              _networkFailureTypes.contains(error.type)) {
            return CricketNoInternetFailure(statusCode: 0);
          }
          return CricketServerErrorFailure();
        }
        final code = error.response?.data['code'] as String?;
        switch (error.response?.statusCode ?? 0) {
          case 400:
            return CricketBadRequestFailure(
              message: error.response?.data['message'].toString(),
              statusCode: error.response?.data['statusCode'] as int?,
              code: code,
            );
          case 401:
            return CricketUnauthorizedErrorFailure(
              message:
                  error.response?.data['message'] as String? ??
                  'You are not authorized to access this resource...',
              statusCode: error.response?.data['statusCode'] as int?,
              code: code,
            );
          case 403:
            return CricketForbiddenErrorFailure(
              message: error.response?.data['message'] as String?,
              statusCode: error.response?.data['statusCode'] as int?,
              code: code,
            );
          case 404:
            return CricketNotFoundErrorFailure(
              message: error.response?.data['message'] as String?,
              statusCode: error.response?.data['statusCode'] as int?,
              code: code,
            );
          case 409:
            return CricketConflictFailure(
              message: error.response?.data['message'] as String?,
              statusCode: error.response?.data['statusCode'] as int?,
              code: code,
            );
          case 422:
            // return error.response!.data;
            return CricketSomethingWentWrongFailure(statusCode: 422, code: code);
          case >= 500:
            return CricketServerErrorFailure(statusCode: 500, code: code);
          default:
            return CricketSomethingWentWrongFailure(code: code);
        }
      }
      return CricketSomethingWentWrongFailure();
    } catch (_) {
      return CricketSomethingWentWrongFailure();
    }
  }
}
