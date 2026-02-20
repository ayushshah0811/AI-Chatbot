import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_history_item_dto.freezed.dart';
part 'chat_history_item_dto.g.dart';

/// A single item from the chat history API response.
///
/// Maps to the `ChatHistoryItem` schema:
/// ```json
/// {
///   "id": "a3bb189e-8bf9-3888-9912-ace4e6543002",
///   "content": "The order 12345 is currently in transit.",
///   "sender": "bot",
///   "timestamp": "2026-02-16T10:30:00Z",
///   "conversationId": "7c9e6679-7425-40de-944b-e07fc1f90ae7"
/// }
/// ```
@freezed
abstract class ChatHistoryItemDto with _$ChatHistoryItemDto {
  const factory ChatHistoryItemDto({
    /// Unique message identifier (UUID).
    required String id,

    /// Message content (may contain markdown).
    required String content,

    /// Who sent the message: `"user"` or `"bot"`.
    required String sender,

    /// ISO 8601 timestamp of when the message was sent.
    required String timestamp,

    /// Conversation this message belongs to.
    required String conversationId,
  }) = _ChatHistoryItemDto;

  factory ChatHistoryItemDto.fromJson(Map<String, dynamic> json) =>
      _$ChatHistoryItemDtoFromJson(json);
}
