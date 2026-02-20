import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/uuid_generator.dart';

part 'session_provider.g.dart';

/// Provides the [SecureStorageService] instance.
///
/// Override this provider in tests to inject a fake/mock storage.
@riverpod
SecureStorageService secureStorageService(Ref ref) {
  return SecureStorageService();
}

/// Manages session identity: userId, conversationId, and targetAppId.
///
/// Persists values to [SecureStorageService] so that sessions survive
/// app restarts. Generates new UUIDs on first launch or when a new
/// conversation is requested.
@riverpod
class SessionNotifier extends _$SessionNotifier {
  late final SecureStorageService _storage;

  @override
  FutureOr<SessionData> build() async {
    _storage = ref.read(secureStorageServiceProvider);

    // Use a fixed userId that matches the backend
    const userId = '1';

    var conversationId = await _storage.getConversationId();
    if (conversationId == null) {
      conversationId = UuidGenerator.generate();
      await _storage.saveConversationId(conversationId);
    }

    // Restore persisted target app or use default
    final targetAppId =
        await _storage.getTargetAppId() ?? AppConstants.defaultTargetAppId;

    return SessionData(
      userId: userId,
      conversationId: conversationId,
      targetAppId: targetAppId,
    );
  }

  /// Creates a new conversation with a fresh UUID.
  ///
  /// Called when the user taps "New Chat" or switches the target app.
  Future<void> newConversation() async {
    final current = state.value;
    if (current == null) return;

    final newConversationId = UuidGenerator.generate();
    await _storage.saveConversationId(newConversationId);

    state = AsyncData(current.copyWith(conversationId: newConversationId));
  }

  /// Handles a target app switch: persists the new target app ID,
  /// generates a fresh conversationId, and clears the old session data.
  Future<void> switchTargetApp(String targetAppId) async {
    final current = state.value;
    if (current == null) return;
    if (current.targetAppId == targetAppId) return;

    // Persist the new target app selection
    await _storage.saveTargetAppId(targetAppId);

    // Generate a new conversation for the new target context
    final newConversationId = UuidGenerator.generate();
    await _storage.saveConversationId(newConversationId);

    state = AsyncData(
      current.copyWith(
        targetAppId: targetAppId,
        conversationId: newConversationId,
      ),
    );
  }

  /// Replaces the current userId (e.g., after authentication).
  Future<void> setUserId(String userId) async {
    final current = state.value;
    if (current == null) return;

    await _storage.saveUserId(userId);
    state = AsyncData(current.copyWith(userId: userId));
  }
}

/// Immutable holder for the session's identity values.
class SessionData {
  const SessionData({
    required this.userId,
    required this.conversationId,
    required this.targetAppId,
  });

  /// Unique identifier for the current user, persisted in secure storage.
  final String userId;

  /// UUID for the active conversation, regenerated on new chat or app switch.
  final String conversationId;

  /// The ID of the currently selected target application (e.g. 'STS_LP').
  final String targetAppId;

  /// Creates a copy with optional field overrides.
  SessionData copyWith({
    String? userId,
    String? conversationId,
    String? targetAppId,
  }) {
    return SessionData(
      userId: userId ?? this.userId,
      conversationId: conversationId ?? this.conversationId,
      targetAppId: targetAppId ?? this.targetAppId,
    );
  }
}
