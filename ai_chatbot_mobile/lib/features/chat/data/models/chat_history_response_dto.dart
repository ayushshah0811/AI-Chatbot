import 'package:freezed_annotation/freezed_annotation.dart';

import 'chat_history_item_dto.dart';

part 'chat_history_response_dto.freezed.dart';
part 'chat_history_response_dto.g.dart';

/// Response envelope from `GET /api/chat/history/{userId}`.
///
/// Contains a list of [ChatHistoryItemDto] in chronological order.
@freezed
abstract class ChatHistoryResponseDto with _$ChatHistoryResponseDto {
  const factory ChatHistoryResponseDto({
    /// Chat messages in chronological order.
    required List<ChatHistoryItemDto> items,
  }) = _ChatHistoryResponseDto;

  factory ChatHistoryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ChatHistoryResponseDtoFromJson(json);
}
