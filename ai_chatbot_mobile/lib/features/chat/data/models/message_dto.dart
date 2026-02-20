import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_dto.freezed.dart';
part 'message_dto.g.dart';

/// Data transfer object for the chat request body.
///
/// Maps to the `ChatRequest` schema in the API contract:
/// ```json
/// {
///   "message": "What is the status of order 12345?",
///   "userId": "550e8400-e29b-41d4-a716-446655440000",
///   "conversationId": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
///   "targetApp": "STS_LP"
/// }
/// ```
@freezed
abstract class MessageDto with _$MessageDto {
  const factory MessageDto({
    /// The user's message text.
    required String message,

    /// Unique identifier for the user.
    required String userId,

    /// Active conversation session UUID.
    required String conversationId,

    /// Target application context (e.g., `STS_LP`, `TMS`, `QMS`).
    required String targetApp,
  }) = _MessageDto;

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);
}
