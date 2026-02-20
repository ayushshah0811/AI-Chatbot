/// Application-wide constants for the AI Chatbot mobile client.
class AppConstants {
  AppConstants._();

  // ── App Info ────────────────────────────────────────────────────────────

  /// Application display name shown in the UI.
  static const String appName = 'AI Chatbot';

  /// Application version string.
  static const String appVersion = '1.0.0';

  // ── Target Applications ─────────────────────────────────────────────────

  /// Available target applications for chat context switching.
  /// Each entry maps an internal ID to its display name.
  static const List<TargetAppConfig> targetApps = [
    TargetAppConfig(id: 'STS_LP', displayName: 'STS LP'),
    TargetAppConfig(id: 'TMS', displayName: 'TMS'),
    TargetAppConfig(id: 'QMS', displayName: 'QMS'),
  ];

  /// The default target app selected on first launch.
  static const String defaultTargetAppId = 'STS_LP';

  // ── Secure Storage Keys ─────────────────────────────────────────────────

  /// Key for storing the JWT token in secure storage.
  static const String storageKeyJwt = 'jwt_token';

  /// Key for storing the current conversation ID.
  static const String storageKeyConversationId = 'conversation_id';

  /// Key for storing the user ID.
  static const String storageKeyUserId = 'user_id';

  /// Key for storing the selected target app ID.
  static const String storageKeyTargetApp = 'target_app_id';

  // ── UI Defaults ─────────────────────────────────────────────────────────

  /// Maximum character length for a single chat message.
  static const int maxMessageLength = 4000;

  /// Debounce duration for typing detection (milliseconds).
  static const int typingDebounceDurationMs = 300;

  /// Auto-scroll threshold: if user is within this many pixels of the
  /// bottom, new messages will trigger auto-scroll.
  static const double autoScrollThreshold = 100.0;
}

/// Configuration for a target application available in the chat.
class TargetAppConfig {
  const TargetAppConfig({
    required this.id,
    required this.displayName,
    this.description,
  });

  /// Unique identifier sent to the backend (e.g., `STS_LP`).
  final String id;

  /// Human-readable name shown in the UI dropdown.
  final String displayName;

  /// Optional description for additional context.
  final String? description;
}
