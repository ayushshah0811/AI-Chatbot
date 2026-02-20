import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

/// Global Dio error interceptor that converts network/server errors
/// into user-friendly messages.
///
/// Ensures the app NEVER crashes from unhandled API errors.
/// All errors are caught and transformed into readable [DioException]
/// responses that the UI layer can display gracefully.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final userFriendlyError = _mapToUserFriendlyError(err);
    debugPrint('ErrorInterceptor: ${err.type} → ${userFriendlyError.message}');
    handler.next(userFriendlyError);
  }

  /// Maps a [DioException] to one with a user-friendly message.
  DioException _mapToUserFriendlyError(DioException err) {
    String message;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timed out. Please check your network.';
      case DioExceptionType.sendTimeout:
        message = 'Request timed out while sending. Please try again.';
      case DioExceptionType.receiveTimeout:
        message = 'Response timed out. The server may be busy.';
      case DioExceptionType.connectionError:
        message = 'Unable to connect. Please check your internet connection.';
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
      case DioExceptionType.badResponse:
        message = _mapStatusCode(err.response?.statusCode);
      case DioExceptionType.badCertificate:
        message = 'Security certificate error. Please contact support.';
      case DioExceptionType.unknown:
        message = 'Something went wrong. Please try again.';
    }

    return DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: err.error,
      message: message,
    );
  }

  /// Maps HTTP status codes to user-friendly messages.
  String _mapStatusCode(int? statusCode) {
    if (statusCode == null) {
      return 'Something went wrong. Please try again.';
    }
    return switch (statusCode) {
      400 => 'Invalid request. Please check your input.',
      401 => 'Session expired. Please log in again.',
      403 => 'You do not have permission to perform this action.',
      404 => 'The requested resource was not found.',
      408 => 'Request timed out. Please try again.',
      429 => 'Too many requests. Please wait a moment.',
      >= 500 && < 600 => 'Server error. Please try again later.',
      _ => 'Something went wrong. Please try again.',
    };
  }
}
