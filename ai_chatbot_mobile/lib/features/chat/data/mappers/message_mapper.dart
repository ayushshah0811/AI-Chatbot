import '../../domain/entities/message.dart';
import '../../domain/entities/message_sender.dart';
import '../../domain/entities/message_status.dart';
import '../models/chat_history_item_dto.dart';
import '../models/message_dto.dart';

/// Bidirectional mappers between DTOs and domain entities.

// ── ChatHistoryItemDto → Message ──────────────────────────────────────

/// Extension to convert a [ChatHistoryItemDto] (API response) into a
/// domain [Message] entity.
extension ChatHistoryItemDtoMapper on ChatHistoryItemDto {
  /// Converts this history DTO to a domain [Message].
  ///
  /// History items are always in [MessageStatus.complete] state since they
  /// represent previously finished exchanges.
  Message toDomain() {
    return Message(
      id: id,
      content: content,
      sender: sender == 'user' ? MessageSender.user : MessageSender.bot,
      timestamp: DateTime.parse(timestamp),
      conversationId: conversationId,
      status: MessageStatus.complete,
    );
  }
}

// ── Message → MessageDto ──────────────────────────────────────────────

/// Extension to convert a domain [Message] into a [MessageDto] for the
/// API request body.
extension MessageToDtoMapper on Message {
  /// Creates a [MessageDto] suitable for `POST /api/chat`.
  ///
  /// Requires the [userId] and [targetApp] since those are not stored
  /// on the [Message] entity itself.
  MessageDto toDto({required String userId, required String targetApp}) {
    return MessageDto(
      message: content,
      userId: userId,
      conversationId: conversationId,
      targetApp: targetApp,
    );
  }
}
