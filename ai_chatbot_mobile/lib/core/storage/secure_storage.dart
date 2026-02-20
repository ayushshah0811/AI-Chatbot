import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

/// Abstraction layer over [FlutterSecureStorage] for persisting sensitive data.
///
/// Stores JWT tokens, conversation IDs, and user IDs securely using
/// platform-native secure storage (Keychain on iOS, EncryptedSharedPreferences
/// on Android).
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  // ── JWT Token ───────────────────────────────────────────────────────────

  /// Stores the JWT authentication token.
  Future<void> saveJwtToken(String token) async {
    await _write(AppConstants.storageKeyJwt, token);
  }

  /// Retrieves the stored JWT token, or `null` if not set.
  Future<String?> getJwtToken() async {
    return _read(AppConstants.storageKeyJwt);
  }

  /// Deletes the stored JWT token.
  Future<void> deleteJwtToken() async {
    await _delete(AppConstants.storageKeyJwt);
  }

  // ── Conversation ID ─────────────────────────────────────────────────────

  /// Stores the current conversation ID.
  Future<void> saveConversationId(String conversationId) async {
    await _write(AppConstants.storageKeyConversationId, conversationId);
  }

  /// Retrieves the stored conversation ID, or `null` if not set.
  Future<String?> getConversationId() async {
    return _read(AppConstants.storageKeyConversationId);
  }

  /// Deletes the stored conversation ID.
  Future<void> deleteConversationId() async {
    await _delete(AppConstants.storageKeyConversationId);
  }

  // ── User ID ─────────────────────────────────────────────────────────────

  /// Stores the user's unique identifier.
  Future<void> saveUserId(String userId) async {
    await _write(AppConstants.storageKeyUserId, userId);
  }

  /// Retrieves the stored user ID, or `null` if not set.
  Future<String?> getUserId() async {
    return _read(AppConstants.storageKeyUserId);
  }

  /// Deletes the stored user ID.
  Future<void> deleteUserId() async {
    await _delete(AppConstants.storageKeyUserId);
  }

  // ── Target App ──────────────────────────────────────────────────────────

  /// Stores the currently selected target app ID.
  Future<void> saveTargetAppId(String targetAppId) async {
    await _write(AppConstants.storageKeyTargetApp, targetAppId);
  }

  /// Retrieves the stored target app ID, or `null` if not set.
  Future<String?> getTargetAppId() async {
    return _read(AppConstants.storageKeyTargetApp);
  }

  // ── Bulk Operations ─────────────────────────────────────────────────────

  /// Clears all stored data. Use with caution.
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('SecureStorageService: Failed to clear all: $e');
    }
  }

  /// Checks whether any value is stored for the given [key].
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      debugPrint('SecureStorageService: Failed to check key "$key": $e');
      return false;
    }
  }

  // ── Private Helpers ─────────────────────────────────────────────────────

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('SecureStorageService: Failed to write "$key": $e');
    }
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint('SecureStorageService: Failed to read "$key": $e');
      return null;
    }
  }

  Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('SecureStorageService: Failed to delete "$key": $e');
    }
  }
}
