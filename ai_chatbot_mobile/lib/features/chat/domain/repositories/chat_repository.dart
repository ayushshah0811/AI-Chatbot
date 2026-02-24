import '../entities/message.dart';

/// Contract for chat data operations.
///
/// Defines the boundary between the domain and data layers.
/// Implementations may connect to a real API ([ChatRemoteDataSource]) or
/// return simulated data ([MockChatDataSource]) based on the
/// `USE_MOCK_DATA` flag.
abstract interface class ChatRepository {
  /// Sends a user [message] and returns the complete AI response.
  ///
  /// - [message]: The user's text input.
  /// - [userId]: Unique identifier for the current user.
  /// - [conversationId]: Active conversation UUID.
  /// - [targetApp]: Backend application code (e.g., `STS_LP`).
  ///
  /// Returns the full response text once available.
  // NOTE: SSE streaming variant commented out — kept for future reference.
  // Stream<String> sendMessageStream({...});
  Future<String> sendMessage({
    required String message,
    required String userId,
    required String conversationId,
    required String targetApp,
  });

  /// Loads the chat history for the given [userId] and [appCode].
  ///
  /// Returns a list of [Message] entities ordered by timestamp ascending.
  /// Returns an empty list if no history exists.
  Future<List<Message>> loadHistory({
    required String userId,
    required String appCode,
  });

  /// Deletes all chat history for [userId] and [appCode].
  /// Returns true on success.
  Future<bool> deleteHistory({required String userId, required String appCode});

  /// Generates a new unique conversation identifier (UUID v4).
  String generateConversationId();
}
