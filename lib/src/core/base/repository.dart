import '../../data/services/network/interceptor/failures.dart';
import '../logger/log.dart';
import 'response_modal.dart';

abstract base class Repository<T> {
  Future<T> request(
      Future<dynamic> Function() request, {
        Function(String?, {String? code}) onError = _defaultErrorHandler,
      }) async {
    try {
      return await request();
    }  on Failure catch (e, stackTrace) {
      Log.error(e.toString());
      Log.error(stackTrace.toString());
      ErrorModel? error = ErrorModel.fromJson(e.error);
      return onError.call(error.message, code: error.code);
    } catch (e, stackTrace) {
      print('Caught unexpected error: $e, Type: ${e.runtimeType}');
      Log.error(e.toString());
      Log.error(stackTrace.toString());
      return onError.call('Something went wrong!');
    }
  }

  static Future _defaultErrorHandler(String? message, {String? code}) {
    return Future.error(message as Object);
  }
}