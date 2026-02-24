/// API configuration constants for the AI Chatbot backend.
///
/// All values are configurable via `--dart-define` flags at build time.
/// Example: `flutter run --dart-define=API_BASE_URL=http://10.30.0.233:8055`
class ApiConstants {
  ApiConstants._();

  /// Base URL for the backend API server.
  /// Override with `--dart-define=API_BASE_URL=<url>`.
  // TODO: Restore original base URL after testing
  // static const String baseUrl = String.fromEnvironment(
  //   'API_BASE_URL',
  //   defaultValue: 'http://10.30.0.233:8055',
  // );
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.30.0.168:3979',
  );

  // ── Endpoints ──────────────────────────────────────────────────────────

  /// POST endpoint for sending a chat message.
  // TODO: Restore original endpoint after testing
  // static const String chatEndpoint = '/api/chat/';
  static const String chatEndpoint = '/api/chat/';

  /// GET endpoint for retrieving chat history by user ID and app code.
  static String historyEndpoint(String userId, String appCode) =>
      '/api/chat/history/$userId/$appCode';

  /// DELETE endpoint for resetting chat history by user ID and app code.
  static String resetHistoryEndpoint(String userId, String appCode) =>
      '/api/chat/history/$userId/$appCode';

  // ── Timeouts ───────────────────────────────────────────────────────────

  /// Connection timeout for establishing a socket connection.
  static const Duration connectTimeout = Duration(seconds: 30);

  /// Receive timeout for waiting between data packets.
  /// Set high to accommodate SSE streaming responses.
  static const Duration receiveTimeout = Duration(seconds: 60);

  /// Send timeout for uploading request body.
  static const Duration sendTimeout = Duration(seconds: 30);

  // ── Headers ────────────────────────────────────────────────────────────

  /// Default content type for API requests.
  static const String contentType = 'application/json';

  /// Accept header for SSE streaming responses.
  static const String acceptStream = 'text/event-stream';

  // ── SSE Markers ────────────────────────────────────────────────────────

  /// Prefix for SSE data lines.
  static const String sseDataPrefix = 'data: ';

  /// Marker indicating the SSE stream is complete.
  static const String sseDoneMarker = '[DONE]';
}
