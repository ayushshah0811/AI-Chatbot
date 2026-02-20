import 'package:freezed_annotation/freezed_annotation.dart';

part 'streaming_state.freezed.dart';

/// Tracks the state of an in-progress bot response stream.
///
/// Created when a streaming response begins and disposed when it completes,
/// errors out, or is stopped by the user.
@freezed
abstract class StreamingState with _$StreamingState {
  const factory StreamingState({
    /// The ID of the bot [Message] being streamed into.
    required String messageId,

    /// Text accumulated so far from SSE chunks.
    required String accumulatedContent,

    /// When the streaming started (used to calculate response time).
    required DateTime startTime,

    /// Whether the user has paused/stopped the stream.
    required bool isPaused,
  }) = _StreamingState;
}
