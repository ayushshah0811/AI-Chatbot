import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import '../storage/secure_storage.dart';

/// Dio interceptor that injects the JWT bearer token into request headers.
///
/// Reads the token from [SecureStorageService] on each request.
/// If no token is stored, the request proceeds without authorization.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required SecureStorageService secureStorage})
    : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _secureStorage.getJwtToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      debugPrint('AuthInterceptor: Failed to inject token: $e');
      // Proceed without token rather than blocking the request.
    }

    handler.next(options);
  }
}
