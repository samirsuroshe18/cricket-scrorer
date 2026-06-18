import 'package:get/get.dart';

import '../constants/error_string_constants.dart';

class CricketFailure {
  final String message;
  final int? statusCode;

  CricketFailure({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'Failure(message: $message,)';
}

// No Internet Failure
class CricketNoInternetFailure extends CricketFailure {
  CricketNoInternetFailure({String? message, super.statusCode})
    : super(
        message: message ?? ErrorStringConstants.connectionError.tr,
      );
}

// Bad Request Failure
class CricketBadRequestFailure extends CricketFailure {
  CricketBadRequestFailure({String? message, super.statusCode})
    : super(message: message ?? ErrorStringConstants.badRequestError.tr);
}

// Server Error Failure
class CricketServerErrorFailure extends CricketFailure {
  CricketServerErrorFailure({String? message, super.statusCode})
    : super(message: message ?? ErrorStringConstants.serverError.tr);
}

// Not Found Error Failure
class CricketNotFoundErrorFailure extends CricketFailure {
  CricketNotFoundErrorFailure({String? message, super.statusCode})
    : super(message: message ?? ErrorStringConstants.notFoundError.tr);
}

// Forbidden Error Failure
class CricketForbiddenErrorFailure extends CricketFailure {
  CricketForbiddenErrorFailure({String? message, super.statusCode})
    : super(message: message ?? ErrorStringConstants.forbiddenError.tr);
}

// Unauthorized Error Failure
class CricketUnauthorizedErrorFailure extends CricketFailure {
  CricketUnauthorizedErrorFailure({String? message, super.statusCode})
    : super(message: message ?? ErrorStringConstants.unAuthorizedError.tr);
}

// Something Went Wrong Error Failure
class CricketSomethingWentWrongFailure extends CricketFailure {
  CricketSomethingWentWrongFailure({String? message, super.statusCode})
    : super(message: message ?? ErrorStringConstants.somethingWentWrong.tr);
}
