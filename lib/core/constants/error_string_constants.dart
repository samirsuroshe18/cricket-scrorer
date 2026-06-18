class ErrorStringConstants {
  /// Socket Exception
  static var connectionError = 'You are not connected to the internet. Please try again';

  /// when api status code is >=500
  static var serverError = 'Server Error unable to process. Please try in sometime.';

  /// 400
  /// Bad Request from client(App) side
  static const String badRequestError = 'Bad Request, please contact Developer Team or try again after some time...';

  /// 401
  static const String unAuthorizedError = 'You are not Authorized to make this Request';

  /// 403
  /// forbidden
  static const String forbiddenError = 'You are forbid to make request';

  /// 404
  static const String notFoundError = 'Server not found, unable to make request';

  /// unknown error
  /// something went wrong
  static const String somethingWentWrong = 'Something Went wrong...';

  static const String genericErrorMessage = 'Something went wrong. Please try again.';

  static const String genericAlertMessage = 'No data available.';
}