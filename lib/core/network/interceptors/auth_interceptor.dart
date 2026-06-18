import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/services/secure_storages_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

import '../../global/widgets/snackbars/cricket_snackbar.dart';
import '../../services/shared_preference_service.dart';
import '../api_client_service.dart';

// Holds in-flight refresh so parallel 401s don't trigger multiple refresh calls
Completer<String>? _refreshCompleter;

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for the refresh endpoint itself
    if (options.extra['skipAuth'] == true) {
      return super.onRequest(options, handler);
    }

    final accessToken = await Get.find<SecureStorageService>().get(
      SharedPrefKey.accessToken,
    );

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      if (kDebugMode) {
        print(options.headers['Authorization']);
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final errorMessage = err.response?.data?['message']?.toString() ?? '';

    if (statusCode != 401 && statusCode != 403) {
      return super.onError(err, handler);
    }

    if (!_isRefreshTokenError(errorMessage)) {
      return super.onError(err, handler);
    }

    if (err.requestOptions.extra['retried'] == true) {
      return handler.reject(err);
    }

    // Already on login screen — nothing to refresh, just reject
    if (Get.currentRoute == AppRoutes.login) {
      _refreshCompleter = null;
      return handler.reject(err);
    }

    // Skip refresh for the refresh endpoint itself — avoids infinite loop
    if (err.requestOptions.extra['skipAuth'] == true) {
      await _forceLogout();
      return handler.reject(err);
    }

    // Refresh token is expired/invalid → force logout immediately
    if (_isRefreshTokenError(errorMessage)) {
      await _forceLogout();
      return handler.reject(err);
    }

    // Another refresh is already in progress — wait for it, then retry
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      try {
        final newAccessToken = await _refreshCompleter!.future;
        return handler.resolve(
          await _retryRequest(err.requestOptions, newAccessToken),
        );
      } catch (_) {
        return handler.reject(err);
      }
    }

    // Start a new refresh
    _refreshCompleter = Completer<String>();

    try {
      final newAccessToken = await _refreshTokens();

      if (newAccessToken == null) {
        _refreshCompleter!.completeError('Refresh failed');
        await _forceLogout();
        return handler.reject(err);
      }

      _refreshCompleter!.complete(newAccessToken);

      // Retry the original failed request with the new access token
      return handler.resolve(
        await _retryRequest(err.requestOptions, newAccessToken),
      );
    } catch (e) {
      _refreshCompleter?.completeError(e);
      await _forceLogout();
      return handler.reject(err);
    } finally {
      _refreshCompleter = null;
    }
  }

  // Refresh tokens
  Future<String?> _refreshTokens() async {
    try {
      final refreshToken = await SecureStorageService.secure.get(
        SharedPrefKey.refreshToken,
      );

      if (refreshToken == null || refreshToken.isEmpty) return null;

      // Use a fresh Dio instance to avoid interceptor loop
      final freshDio = Dio(
        BaseOptions(
          baseUrl: Get.find<ApiClient>().dio.options.baseUrl,
          receiveTimeout: const Duration(seconds: 30),
          connectTimeout: const Duration(seconds: 30),
        ),
      );

      final response = await freshDio.post<Map<String, dynamic>>(
        '/api/v1/user/refresh-token',
        options: Options(
          headers: {'x-refresh-token': refreshToken},
          extra: {'skipAuth': true},
        ),
      );

      final data = response.data?['data'];
      final newAccessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String;

      // Persist rotated tokens
      await SecureStorageService.secure.set(
        SharedPrefKey.accessToken,
        newAccessToken,
      );
      await SecureStorageService.secure.set(
        SharedPrefKey.refreshToken,
        newRefreshToken,
      );

      return newAccessToken;
    } catch (_) {
      return null;
    }
  }

  // Retry original request with new token
  Future<Response<dynamic>> _retryRequest(
    RequestOptions options,
    String newAccessToken,
  ) {
    return Get.find<ApiClient>().dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: {
          ...options.headers,
          'Authorization': 'Bearer $newAccessToken',
        },
        extra: {
          ...options.extra,
          'retried': true,
        },
      ),
    );
  }

  // Force logout
  Future<void> _forceLogout() async {
    await SecureStorageService.secure.clear();
    await SharedPreferenceService.sharedPrefService.clear();

    unawaited(Get.offAllNamed<dynamic>(AppRoutes.login));

    CricketSnackbar.showAlertMessage(
      'Your session has expired. Please log in again.',
    );
  }

  // Detect refresh token errors from backend message
  bool _isRefreshTokenError(String message) {
    return message.contains('Refresh token is expired') ||
        message.contains('Unauthorized request') ||
        message.contains('Invalid refresh token') ||
        message.contains('Refresh token is expired or used');
  }
}
