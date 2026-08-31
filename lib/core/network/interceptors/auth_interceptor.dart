import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/global/data/global_endpoint.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/services/language_service.dart';
import 'package:cricket_scorer/core/services/secure_storages_service.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

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

    options.headers['accept-language'] =
        Get.find<LanguageService>().currentLanguage;

    // A caller that has already set its own Authorization header knows
    // better than this interceptor's default — never clobber it. The one
    // caller that does this is logout (user_api_service.dart), which must
    // send the refresh token, not the access token; every other call site
    // relies on this interceptor to attach the access token, so this branch
    // only ever changes logout's behavior. Without it, logout's deliberately-
    // set header was silently overwritten below, the request carried the
    // wrong token, and the server-side session was never actually revoked.
    if (options.headers.containsKey('Authorization')) {
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
    final errorCode = err.response?.data?['code']?.toString() ?? '';

    if (statusCode != 401 && statusCode != 403) {
      return super.onError(err, handler);
    }

    final isAccessTokenError = _accessTokenErrors.contains(errorCode);
    final isRefreshTokenError = _refreshTokenErrors.contains(errorCode);

    if (!isAccessTokenError && !isRefreshTokenError) {
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

    // Refresh token itself is expired/invalid → nothing to refresh with
    if (isRefreshTokenError) {
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

      final response = await freshDio.get<Map<String, dynamic>>(
        GlobalEndpoint.refreshToken,
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
    await SharedPreferenceService.sharedPrefService.clearForLogout();
    await SecureStorageService.secure.clearForLogout();

    unawaited(Get.offAllNamed<dynamic>(AppRoutes.login));

    CricketSnackbar.showAlertMessage(
      TranslationKeys.sessionExpired.tr,
    );
  }

  // Backend error codes are bare SCREAMING_SNAKE_CASE i18n keys — match exactly,
  // not by substring (REFRESH_TOKEN_EXPIRED is a prefix of
  // REFRESH_TOKEN_EXPIRED_OR_USED).

  // The access token is stale but the refresh token may still be good → refresh.
  static const Set<String> _accessTokenErrors = {
    'UNAUTHORIZED_REQUEST',
    'ACCESS_TOKEN_EXPIRED',
    'INVALID_ACCESS_TOKEN',
  };

  // The refresh token itself is rejected → nothing to recover with, log out.
  static const Set<String> _refreshTokenErrors = {
    'REFRESH_TOKEN_EXPIRED',
    'REFRESH_TOKEN_EXPIRED_OR_USED',
    'INVALID_REFRESH_TOKEN',
  };
}
