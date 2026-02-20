import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_sender.dart';
import '../../domain/entities/message_status.dart';
import '../models/message_dto.dart';

/// Remote data source that communicates with the backend chat API.
///
/// Endpoints consumed:
/// - `POST /api/chat/` — sends a message, returns SSE-formatted response
/// - `GET /api/chat/history/{userId}/` — retrieves conversation history
class ChatRemoteDataSource {
  ChatRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Sends a chat message and returns the complete response text.
  ///
  /// The backend returns SSE-formatted data:
  /// ```
  /// data: {"text":null,"type":"typing"}
  /// data: {"text":"Hello!","type":"message"}
  /// ```
  /// We parse each SSE line, collect all "message" type texts,
  /// and return the concatenated result.
  Future<String> sendMessage({required MessageDto messageDto}) async {
    final response = await _apiClient.post<String>(
      ApiConstants.chatEndpoint,
      data: messageDto.toJson(),
      options: Options(responseType: ResponseType.plain),
    );

    final raw = response.data;
    if (raw == null || raw.isEmpty) return '';

    return _parseSseResponse(raw);
  }

  /// Parses an SSE-formatted response string and extracts message text.
  String _parseSseResponse(String raw) {
    final buffer = StringBuffer();

    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (!trimmed.startsWith(ApiConstants.sseDataPrefix)) continue;

      final jsonStr = trimmed.substring(ApiConstants.sseDataPrefix.length);
      if (jsonStr.isEmpty || jsonStr == ApiConstants.sseDoneMarker) continue;

      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        final type = map['type'] as String?;
        final text = map['text'] as String?;

        if (type == 'message' && text != null && text.isNotEmpty) {
          buffer.write(text);
        }
      } catch (_) {
        // Skip malformed SSE lines
      }
    }

    return buffer.toString();
  }

  /// Loads the full chat history for the given [userId].
  ///
  /// Returns domain [Message] entities.
  /// Returns an empty list if no history exists or on error.
  Future<List<Message>> loadHistory({required String userId}) async {
    try {
      final response = await _apiClient.get<dynamic>(
        ApiConstants.historyEndpoint(userId),
      );

      final data = response.data;
      if (data == null) return [];

      // Handle list response: [{...}, {...}, ...]
      if (data is List) {
        return _parseHistoryList(data);
      }

      // Handle map response: { "items": [...] } or { "messages": [...] }
      if (data is Map<String, dynamic>) {
        final items =
            data['items'] ??
            data['messages'] ??
            data['history'] ??
            data['data'] ??
            data['results'] ??
            data['chats'];
        if (items is List) {
          return _parseHistoryList(items);
        }
      }

      // Handle string response (might be SSE or plain text)
      if (data is String && data.isNotEmpty) {
        try {
          final parsed = jsonDecode(data);
          if (parsed is List) return _parseHistoryList(parsed);
          if (parsed is Map<String, dynamic>) {
            final items =
                parsed['items'] ??
                parsed['messages'] ??
                parsed['history'] ??
                parsed['data'] ??
                parsed['results'] ??
                parsed['chats'];
            if (items is List) return _parseHistoryList(items);
          }
        } catch (_) {
          // String is not valid JSON
        }
      }

      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Parses a list of history items into domain [Message] entities.
  List<Message> _parseHistoryList(List<dynamic> items) {
    final messages = <Message>[];
    for (final item in items) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      final id = (item['id'] ?? item['_id'] ?? '').toString();

      // Extract content: handle Gemini-style {parts: [{text: "..."}]} format
      String content = '';
      final parts = item['parts'];
      if (parts is List && parts.isNotEmpty) {
        // Gemini format: concatenate all text parts
        final textParts = <String>[];
        for (final part in parts) {
          if (part is Map<String, dynamic> && part['text'] != null) {
            textParts.add(part['text'].toString());
          }
        }
        content = textParts.join('\n');
      }
      if (content.isEmpty) {
        content =
            (item['content'] ??
                    item['text'] ??
                    item['message'] ??
                    item['query'] ??
                    '')
                .toString();
      }

      // Check for 'response' field which may contain the bot's reply
      final responseText = (item['response'] ?? '').toString();
      final senderStr = (item['sender'] ?? item['role'] ?? '')
          .toString()
          .toLowerCase();
      final timestampStr =
          item['timestamp'] ?? item['created_at'] ?? item['createdAt'];

      // Map 'model' role to bot (Gemini-style)
      final sender = (senderStr == 'user')
          ? MessageSender.user
          : MessageSender.bot;

      final timestamp = _parseTimestamp(timestampStr);
      final convId = (item['conversationId'] ?? item['conversation_id'] ?? '')
          .toString();

      // If there's a 'query' + 'response' pair, create both user and bot messages
      final query = (item['query'] ?? '').toString();
      if (query.isNotEmpty && responseText.isNotEmpty) {
        messages.add(
          Message(
            id: id.isNotEmpty ? '${id}_user' : '${messages.length}_user',
            content: query,
            sender: MessageSender.user,
            timestamp: timestamp,
            conversationId: convId,
            status: MessageStatus.complete,
          ),
        );
        messages.add(
          Message(
            id: id.isNotEmpty ? '${id}_bot' : '${messages.length}_bot',
            content: responseText,
            sender: MessageSender.bot,
            timestamp: timestamp,
            conversationId: convId,
            status: MessageStatus.complete,
          ),
        );
        continue;
      }

      if (content.isEmpty) {
        continue;
      }

      messages.add(
        Message(
          id: id.isNotEmpty ? id : '${messages.length}',
          content: content,
          sender: sender,
          timestamp: timestamp,
          conversationId: convId,
          status: MessageStatus.complete,
        ),
      );
    }
    return messages;
  }

  DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
