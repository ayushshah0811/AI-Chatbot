import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

/// Centralized API client built on [Dio] with interceptors, timeouts,
/// and streaming support.
///
/// Configures:
/// - Base URL from [ApiConstants]
/// - Connection, send, and receive timeouts
/// - [AuthInterceptor] for JWT token injection
/// - [ErrorInterceptor] for global error handling
/// - Streaming support via [ResponseType.stream]
class ApiClient {
  ApiClient({required SecureStorageService secureStorage})
    : _secureStorage = secureStorage {
    _dio = _createDio();
  }

  final SecureStorageService _secureStorage;
  late final Dio _dio;

  /// The underlying [Dio] instance. Prefer using the typed methods below.
  Dio get dio => _dio;

  // ── Factory ─────────────────────────────────────────────────────────────

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Accept': ApiConstants.contentType,
        },
      ),
    );

    // Order matters: Auth first (add token), Error last (catch errors)
    dio.interceptors.addAll([
      AuthInterceptor(secureStorage: _secureStorage),
      ErrorInterceptor(),
    ]);

    return dio;
  }

  // ── Typed Request Methods ───────────────────────────────────────────────

  /// Sends a GET request to [path] and returns the response.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Sends a POST request to [path] with optional [data] body.
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Sends a POST request that returns a streaming response.
  ///
  /// Used for SSE endpoints like `/api/chat`.
  /// Returns a [ResponseBody] whose `.stream` yields raw bytes.
  Future<Response<ResponseBody>> postStream(
    String path, {
    required Object data,
    CancelToken? cancelToken,
  }) {
    return _dio.post<ResponseBody>(
      path,
      data: data,
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Accept': ApiConstants.acceptStream},
      ),
      cancelToken: cancelToken,
    );
  }

  /// Sends a PUT request to [path] with optional [data] body.
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Sends a DELETE request to [path].
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
