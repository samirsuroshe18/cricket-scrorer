import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:get/get.dart';

class CricketFailure {
  final String message;
  final int? statusCode;

  /// The backend's machine-readable error code (a bare SCREAMING_SNAKE_CASE
  /// i18n key, e.g. `SYNC_CONFLICT`, `BOWLER_NOT_SELECTED`) — the same field
  /// `AuthInterceptor` already reads separately for its refresh/logout
  /// branching. Null for failures with no server response (timeouts, no
  /// internet) or a body that carries no `code`.
  final String? code;

  CricketFailure({
    required this.message,
    this.statusCode,
    this.code,
  });

  @override
  String toString() => 'Failure(message: $message,)';
}

// No Internet Failure
class CricketNoInternetFailure extends CricketFailure {
  CricketNoInternetFailure({String? message, super.statusCode, super.code})
    : super(
        message: message ?? TranslationKeys.connectionError.tr,
      );
}

// Bad Request Failure
class CricketBadRequestFailure extends CricketFailure {
  CricketBadRequestFailure({String? message, super.statusCode, super.code})
    : super(message: message ?? TranslationKeys.badRequestError.tr);
}

// Server Error Failure
class CricketServerErrorFailure extends CricketFailure {
  CricketServerErrorFailure({String? message, super.statusCode, super.code})
    : super(message: message ?? TranslationKeys.serverError.tr);
}

// Not Found Error Failure
class CricketNotFoundErrorFailure extends CricketFailure {
  CricketNotFoundErrorFailure({String? message, super.statusCode, super.code})
    : super(message: message ?? TranslationKeys.notFoundError.tr);
}

// Forbidden Error Failure
class CricketForbiddenErrorFailure extends CricketFailure {
  CricketForbiddenErrorFailure({String? message, super.statusCode, super.code})
    : super(message: message ?? TranslationKeys.forbiddenError.tr);
}

// Unauthorized Error Failure
class CricketUnauthorizedErrorFailure extends CricketFailure {
  CricketUnauthorizedErrorFailure({String? message, super.statusCode, super.code})
    : super(message: message ?? TranslationKeys.unAuthorizedError.tr);
}

// Something Went Wrong Error Failure
class CricketSomethingWentWrongFailure extends CricketFailure {
  CricketSomethingWentWrongFailure({String? message, super.statusCode, super.code})
    : super(message: message ?? TranslationKeys.somethingWentWrong.tr);
}

// Socket Disconnected Failure
class CricketSocketDisconnectedFailure extends CricketFailure {
  CricketSocketDisconnectedFailure({String? message, super.statusCode, super.code})
    : super(message: message ?? TranslationKeys.connectionLost.tr);
}

// Conflict Failure (409) — the sync endpoint's SYNC_CONFLICT lands here.
// A distinct subclass rather than folded into CricketBadRequestFailure
// because the offline queue branches on this specifically: a conflict must
// never be retried automatically and must never touch the local queue,
// unlike every other failure shape.
class CricketConflictFailure extends CricketFailure {
  CricketConflictFailure({String? message, super.statusCode, super.code})
    : super(message: message ?? TranslationKeys.syncConflict.tr);
}
