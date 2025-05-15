base class ResponseModel {
  final bool success;
  final String? message;
  final ErrorModel? error;
  final Object? data;

  ResponseModel({
    required this.success,
    this.message,
    this.error,
    this.data,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      success: json['success'] as bool? ?? false, // Default to false if missing
      message: json['message'] as String?,
      error: json['error'] != null
          ? ErrorModel.fromJson(json['error'] as Map<String, dynamic>)
          : null,
      data: json['data'],
    );
  }
}

base class ErrorModel {
  final String message;
  final String? code;
  final String? stack;

  ErrorModel({
    required this.message,
    this.code,
    this.stack,
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      message: json['message'] as String? ?? 'Unknown error',
      code: json['code'] as String?,
      stack: json['stack'] as String?,
    );
  }
}