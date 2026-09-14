import 'package:dio/dio.dart';

/// Wraps the Api's `{error, message}` JSON body (see AshrafBack.Members.Api's ErrorResponse) so
/// screens can show the same Arabic message the web portal already uses, without re-deriving it.
class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  factory ApiException.fromDioError(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return ApiException(data['message'] as String);
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return ApiException('تعذر الاتصال بالخادم، يرجى التحقق من الإنترنت والمحاولة مرة أخرى'
          ' [${error.type.name}: ${error.message}]');
    }
    // TEMPORARY diagnostic detail appended below (remove once the iOS login investigation is
    // done) - the plain Arabic fallback alone gives no way to tell a 404/500 apart from a TLS
    // failure or a timeout when reported secondhand.
    final status = error.response?.statusCode;
    return ApiException('حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى'
        ' [${error.type.name}${status != null ? ' $status' : ''}: ${error.message ?? error.error}]');
  }

  @override
  String toString() => message;
}
