class ApiResponseModel {
  bool? success;
  int? statusCode;
  ApiErrorModel? error;
  dynamic data;
  String? message;

  ApiResponseModel({
    this.success,
    this.error,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponseModel.fromJson(Map<String, dynamic> json) {
    return ApiResponseModel(
      success: json['success'] as bool? ?? false,
      error: ApiErrorModel.fromJson(
        json['error'] as Map<String, dynamic>? ?? {},
      ),
      data: json['data'],
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'error': error, 'data': data};
  }

  @override
  String toString() {
    return 'ApiResponseModel(success: $success, error: $error, data: $data)';
  }
}

class ApiErrorModel {
  int? statusCode;
  String? message;

  ApiErrorModel({this.statusCode, this.message});

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) => ApiErrorModel(
    statusCode: json['statusCode'] as int?,
    message: json['message'] is String ? json['message'] as String? : '',
  );

  Map<String, dynamic> toJson() {
    return {'statusCode': statusCode, 'message': message};
  }

  @override
  String toString() {
    return 'Code : $statusCode ,Error Message : $message';
  }
}
