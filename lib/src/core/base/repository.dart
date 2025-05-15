import 'package:dio/dio.dart';
import '../logger/log.dart';
import '../../data/services/network/interceptor/failures.dart';
import 'response_modal.dart';

abstract base class Repository<T> {
  Future<T> request(
      Future<dynamic> Function() request, {
        Function(String, {String? code}) onError = _defaultErrorHandler,
      }) async {
    try {
      return await request();
    } on DioException catch (e, stackTrace) {
      Log.error('DioException: Status code ${e.response?.statusCode ?? 'unknown'}');
      Log.error('Stack trace: $stackTrace');

      String errorMessage = 'Request failed';
      String? errorCode;

      if (e.response != null && e.response?.data != null) {
        Log.error('Raw response data: ${e.response!.data}');
        try {
          // Handle response data based on its type
          if (e.response!.data is Map<String, dynamic>) {
            final data = e.response!.data as Map<String, dynamic>;
            // Try parsing with ResponseModel
            final responseModel = ResponseModel.fromJson(data);
            errorMessage = responseModel.message ??
                responseModel.error?.message ??
                _extractErrorMessage(data) ??
                'Invalid request data';
            errorCode = responseModel.error?.code ??
                _extractErrorCode(data) ??
                e.response?.statusCode?.toString();
          } else if (e.response!.data is String) {
            errorMessage = e.response!.data as String;
            errorCode = e.response?.statusCode?.toString();
          } else {
            errorMessage = 'Unexpected response format (status ${e.response?.statusCode})';
            errorCode = e.response?.statusCode?.toString();
          }
        } catch (parseError) {
          Log.error('Failed to parse response: $parseError');
          // Fallback: Extract message from raw data
          if (e.response!.data is Map<String, dynamic>) {
            final data = e.response!.data as Map<String, dynamic>;
            errorMessage = _extractErrorMessage(data) ??
                'Failed to process server response (status ${e.response?.statusCode})';
            errorCode = _extractErrorCode(data) ??
                e.response?.statusCode?.toString();
          } else {
            errorMessage = 'Failed to process server response (status ${e.response?.statusCode})';
            errorCode = e.response?.statusCode?.toString();
          }
        }
      } else {
        errorMessage = e.message ?? 'Network error occurred';
        errorCode = e.response?.statusCode?.toString();
      }

      return onError.call(errorMessage, code: errorCode);
    } on Failure catch (e, stackTrace) {
      Log.error('Failure: ${e.toString()}');
      Log.error('Stack trace: $stackTrace');
      ErrorModel? error = ResponseModel.fromJson(e.error).error;
      return onError.call(
        error?.message ?? 'Network request failed',
        code: error?.code,
      );
    } catch (e, stackTrace) {
      Log.error('Unexpected error: ${e.toString()}');
      Log.error('Stack trace: $stackTrace');
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'An unexpected error occurred';
      return onError.call(errorMessage);
    }
  }

  // Helper to extract error message from raw JSON
  String? _extractErrorMessage(Map<String, dynamic> data) {
    return data['message']?.toString() ??
        data['msg']?.toString() ??
        (data['error'] is Map<String, dynamic>
            ? data['error']['message']?.toString() ?? data['error']['msg']?.toString()
            : null) ??
        data['error']?.toString();
  }

  // Helper to extract error code from raw JSON
  String? _extractErrorCode(Map<String, dynamic> data) {
    return data['code']?.toString() ??
        data['errorCode']?.toString() ??
        (data['error'] is Map<String, dynamic>
            ? data['error']['code']?.toString() ?? data['error']['errorCode']?.toString()
            : null);
  }

  static Future _defaultErrorHandler(String message, {String? code}) {
    return Future.error('$message');
  }
}