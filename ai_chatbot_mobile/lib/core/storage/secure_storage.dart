import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Abstraction layer over [SharedPreferences] for persisting app data.
///
/// Stores JWT tokens, conversation IDs, and user IDs using
/// SharedPreferences (localStorage on web, SharedPreferences on Android).
/// Replaces flutter_secure_storage to avoid Web Crypto OperationError issues.
class SecureStorageService {
  SecureStorageService();

  /// Lazy-loaded SharedPreferences instance.
  SharedPreferencesAsync? _prefs;

  Future<SharedPreferencesAsync> get _storage async {
    return _prefs ??= SharedPreferencesAsync();
  }

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
      final prefs = await _storage;
      await prefs.clear();
    } catch (e) {
      debugPrint('SecureStorageService: Failed to clear all: $e');
    }
  }

  /// Checks whether any value is stored for the given [key].
  Future<bool> containsKey(String key) async {
    try {
      final prefs = await _storage;
      final value = await prefs.getString(key);
      return value != null;
    } catch (e) {
      debugPrint('SecureStorageService: Failed to check key "$key": $e');
      return false;
    }
  }

  // ── Private Helpers ─────────────────────────────────────────────────────

  Future<void> _write(String key, String value) async {
    try {
      final prefs = await _storage;
      await prefs.setString(key, value);
    } catch (e) {
      debugPrint('SecureStorageService: Failed to write "$key": $e');
    }
  }

  Future<String?> _read(String key) async {
    try {
      final prefs = await _storage;
      return await prefs.getString(key);
    } catch (e) {
      debugPrint('SecureStorageService: Failed to read "$key": $e');
      return null;
    }
  }

  Future<void> _delete(String key) async {
    try {
      final prefs = await _storage;
      await prefs.remove(key);
    } catch (e) {
      debugPrint('SecureStorageService: Failed to delete "$key": $e');
    }
  }
}
