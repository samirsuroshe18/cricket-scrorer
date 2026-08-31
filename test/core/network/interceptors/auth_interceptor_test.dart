import 'dart:typed_data';

import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/network/interceptors/auth_interceptor.dart';
import 'package:cricket_scorer/core/services/language_service.dart';
import 'package:cricket_scorer/core/services/secure_storages_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Never touches the real `flutter_secure_storage` platform channel —
/// `SecureStorageService.get` is overridden to answer from an in-memory map.
class _FakeSecureStorageService extends SecureStorageService {
  _FakeSecureStorageService(this._values);
  final Map<String, String> _values;

  @override
  Future<String?> get(String key) async => _values[key];
}

/// Captures whatever `RequestOptions` actually reaches the wire, after every
/// interceptor (including [AuthInterceptor]) has run — the only way to prove
/// what header value a real request would have sent, rather than asserting
/// against `onRequest` in isolation.
class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? lastOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late _CapturingAdapter adapter;

  setUp(() {
    Get.put<SecureStorageService>(
      _FakeSecureStorageService({
        SharedPrefKey.accessToken: 'the-access-token',
      }),
    );
    Get.put<LanguageService>(LanguageService());

    adapter = _CapturingAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(AuthInterceptor());
  });

  tearDown(() {
    Get.reset();
  });

  // logout (user_api_service.dart) sets `Authorization: Bearer <refreshToken>`
  // itself, precisely because the backend's logout contract reads the
  // refresh token from that header — never the access token every other
  // call site relies on this interceptor to attach automatically.
  test(
    'does not clobber an Authorization header the caller already set — '
    'this is what logout needs to actually send the refresh token',
    () async {
      await dio.get<dynamic>(
        '/logout',
        options: Options(
          headers: {'Authorization': 'Bearer the-refresh-token'},
        ),
      );

      expect(
        adapter.lastOptions?.headers['Authorization'],
        'Bearer the-refresh-token',
        reason:
            'before the fix, onRequest unconditionally overwrote this with '
            'the stored access token, so the server-side session was never '
            'actually revoked',
      );
    },
  );

  test(
    'still attaches the stored access token for an ordinary request with no '
    'Authorization header of its own',
    () async {
      await dio.get<dynamic>('/some-endpoint');

      expect(
        adapter.lastOptions?.headers['Authorization'],
        'Bearer the-access-token',
      );
    },
  );

  test(
    'still sends accept-language even when Authorization is preset',
    () async {
      await dio.get<dynamic>(
        '/logout',
        options: Options(
          headers: {'Authorization': 'Bearer the-refresh-token'},
        ),
      );

      expect(adapter.lastOptions?.headers['accept-language'], 'en');
    },
  );
}
