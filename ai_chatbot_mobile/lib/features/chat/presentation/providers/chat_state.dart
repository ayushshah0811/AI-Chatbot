import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/target_app.dart';

part 'chat_state.freezed.dart';

/// Aggregate state for the chat feature.
///
/// Holds the active conversation, streaming status, selected target app,
/// and any error or response-time metadata. Managed by [ChatProvider].
@freezed
abstract class ChatState with _$ChatState {
  const factory ChatState({
    /// The currently active conversation (null before first message).
    required Conversation? activeConversation,

    /// The backend application context currently selected by the user.
    required TargetApp selectedTargetApp,

    /// Whether a bot response is currently being streamed.
    required bool isStreaming,

    /// Whether the user is allowed to send a new message.
    /// False while a message is being sent or streaming is in progress.
    required bool isSendEnabled,

    /// A user-facing error message, if any. Cleared on next successful action.
    String? errorMessage,

    /// Elapsed time in milliseconds for the last completed bot response.
    int? lastResponseTimeMs,

    /// Text to pre-populate in the message input for rephrasing.
    /// Set by [ChatNotifier.rephrase] and cleared after consumption.
    String? rephraseText,

    /// The text of the last message that failed to send.
    /// Used by the retry mechanism. Cleared on successful send or
    /// explicit user dismissal.
    String? lastFailedMessage,
  }) = _ChatState;

  /// Creates the initial state with defaults.
  ///
  /// No active conversation, default target app (STS_LP), not streaming,
  /// send enabled.
  factory ChatState.initial() => const ChatState(
    activeConversation: null,
    selectedTargetApp: TargetApp(id: 'STS_LP', displayName: 'STS LP'),
    isStreaming: false,
    isSendEnabled: true,
  );
}
