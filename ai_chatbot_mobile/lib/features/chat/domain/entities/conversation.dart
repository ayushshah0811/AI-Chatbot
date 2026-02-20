import 'package:freezed_annotation/freezed_annotation.dart';

import 'message.dart';
import 'target_app.dart';

part 'conversation.freezed.dart';

/// A chat session with isolated message context.
///
/// Each conversation is scoped to a single [TargetApp] and identified by a
/// unique [conversationId] (UUID). Starting a new chat or switching target
/// apps creates a new conversation and deactivates the previous one.
@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    /// Unique session identifier (UUID).
    required String conversationId,

    /// Identifier of the user who owns this conversation.
    required String userId,

    /// The application context for this conversation.
    required TargetApp targetApp,

    /// When the conversation was created.
    required DateTime createdAt,

    /// All messages in this conversation, ordered by [Message.timestamp].
    required List<Message> messages,

    /// Whether this is the currently active conversation.
    /// Only one conversation should be active at a time.
    @Default(true) bool isActive,
  }) = _Conversation;
}
