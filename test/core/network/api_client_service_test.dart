import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:flutter_test/flutter_test.dart';

// AuthInterceptor._retryRequest and _forceLogout both rely on this pair
// (currentCancelToken / cancelAllRequests) to make a request retried after
// a token refresh — and every other in-flight request — cancellable at
// logout. See auth_interceptor.dart's own comments on both call sites for
// why: before this, a retried request was built with no cancel token at
// all, and _forceLogout never called cancelAllRequests() to begin with, so
// either could complete after the session it belonged to had already ended.
void main() {
  test(
    'cancelAllRequests cancels the token currentCancelToken was handing out, '
    'and replaces it with a fresh, uncancelled one',
    () {
      final tokenBefore = ApiClient.currentCancelToken;
      expect(tokenBefore.isCancelled, isFalse);

      ApiClient.cancelAllRequests();

      expect(
        tokenBefore.isCancelled,
        isTrue,
        reason:
            'a request that grabbed this token before cancelAllRequests() '
            'ran must actually be cancelled by it',
      );
      expect(
        ApiClient.currentCancelToken.isCancelled,
        isFalse,
        reason: 'the next request must not inherit an already-cancelled token',
      );
      expect(
        identical(ApiClient.currentCancelToken, tokenBefore),
        isFalse,
      );
    },
  );
}
