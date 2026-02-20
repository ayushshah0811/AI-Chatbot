# Data Model: Mobile Chat Client

**Feature Branch**: `001-chat-client`  
**Date**: 2026-02-16  
**Status**: Complete

## Entity Overview

```
┌─────────────────┐     1:N     ┌─────────────────┐
│   Conversation  │────────────▶│     Message     │
└─────────────────┘             └─────────────────┘
        │
        │ belongs to
        ▼
┌─────────────────┐
│  TargetApp      │
└─────────────────┘
```

---

## Domain Entities

### Message

Represents a single chat message (user or bot).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String | Yes | Unique identifier (UUID) |
| content | String | Yes | Message text content |
| sender | MessageSender | Yes | Enum: `user` or `bot` |
| timestamp | DateTime | Yes | When message was created/received |
| conversationId | String | Yes | Parent conversation UUID |
| status | MessageStatus | Yes | Enum: `sending`, `streaming`, `complete`, `stopped`, `error` |
| responseTimeMs | int? | No | Time to complete (bot messages only) |

**State Transitions**:
```
[User Message]
  sending → complete
  sending → error

[Bot Message]  
  streaming → complete
  streaming → stopped (user paused)
  streaming → error
```

**Validation Rules**:
- `content` must not be empty for user messages
- `content` may be empty during initial `streaming` state for bot messages
- `conversationId` must be valid UUID format
- `responseTimeMs` only set when status is `complete`

**Freezed Definition**:
```dart
@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String content,
    required MessageSender sender,
    required DateTime timestamp,
    required String conversationId,
    required MessageStatus status,
    int? responseTimeMs,
  }) = _Message;
}

enum MessageSender { user, bot }

enum MessageStatus { sending, streaming, complete, stopped, error }
```

---

### Conversation

Represents a chat session with isolated context.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| conversationId | String | Yes | Primary identifier (UUID) |
| userId | String | Yes | User identifier |
| targetApp | TargetApp | Yes | Associated application context |
| createdAt | DateTime | Yes | Session start time |
| messages | List\<Message\> | Yes | Ordered list of messages |
| isActive | bool | Yes | Whether this is the current session |

**Validation Rules**:
- `conversationId` must be unique per session
- `messages` must be ordered by `timestamp` ascending
- Only one conversation may have `isActive = true` at a time
- New `conversationId` required when `targetApp` changes

**State Transitions**:
```
[New Conversation]
  create (New Chat or target app switch)
    → generates new UUID
    → clears messages
    → sets isActive = true
    → previous conversation isActive = false

[Active Conversation]
  send message → message added to messages list
  receive chunk → bot message content updated
  complete → bot message status = complete
```

**Freezed Definition**:
```dart
@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required String conversationId,
    required String userId,
    required TargetApp targetApp,
    required DateTime createdAt,
    required List<Message> messages,
    @Default(true) bool isActive,
  }) = _Conversation;
}
```

---

### TargetApp

Represents a backend application context for the chat.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String | Yes | Unique code (e.g., `STS_LP`) |
| displayName | String | Yes | Human-readable name |
| description | String? | No | Optional description |

**Known Values**:
| ID | Display Name |
|----|--------------|
| STS_LP | STS LP |
| TMS | TMS |
| QMS | QMS |

**Validation Rules**:
- `id` must match backend-supported values
- List may be static or fetched from configuration

**Freezed Definition**:
```dart
@freezed
class TargetApp with _$TargetApp {
  const factory TargetApp({
    required String id,
    required String displayName,
    String? description,
  }) = _TargetApp;
}
```

---

## DTOs (Data Transfer Objects)

### MessageDto

Maps to/from API request/response format.

```dart
@freezed
class MessageDto with _$MessageDto {
  const factory MessageDto({
    required String message,
    required String userId,
    required String conversationId,
    required String targetApp,
  }) = _MessageDto;

  factory MessageDto.fromJson(Map<String, dynamic> json) => 
      _$MessageDtoFromJson(json);
}
```

### ChatHistoryResponseDto

Response from `GET /api/chat/history/{userId}`.

```dart
@freezed
class ChatHistoryResponseDto with _$ChatHistoryResponseDto {
  const factory ChatHistoryResponseDto({
    required List<ChatHistoryItemDto> items,
  }) = _ChatHistoryResponseDto;

  factory ChatHistoryResponseDto.fromJson(Map<String, dynamic> json) => 
      _$ChatHistoryResponseDtoFromJson(json);
}

@freezed
class ChatHistoryItemDto with _$ChatHistoryItemDto {
  const factory ChatHistoryItemDto({
    required String id,
    required String content,
    required String sender, // "user" or "bot"
    required String timestamp,
    required String conversationId,
  }) = _ChatHistoryItemDto;

  factory ChatHistoryItemDto.fromJson(Map<String, dynamic> json) => 
      _$ChatHistoryItemDtoFromJson(json);
}
```

---

## DTO ↔ Domain Mapping

### Message Mapper

```dart
extension MessageMapper on ChatHistoryItemDto {
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

extension MessageDtoMapper on Message {
  MessageDto toDto({required String userId, required String targetApp}) {
    return MessageDto(
      message: content,
      userId: userId,
      conversationId: conversationId,
      targetApp: targetApp,
    );
  }
}
```

---

## Local State Models

### ChatState

Aggregate state for the chat feature.

```dart
@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    required Conversation? activeConversation,
    required TargetApp selectedTargetApp,
    required bool isStreaming,
    required bool isSendEnabled,
    String? errorMessage,
    int? lastResponseTimeMs,
  }) = _ChatState;

  factory ChatState.initial() => ChatState(
    activeConversation: null,
    selectedTargetApp: const TargetApp(id: 'STS_LP', displayName: 'STS LP'),
    isStreaming: false,
    isSendEnabled: true,
  );
}
```

### StreamingState

Tracks ongoing stream for a bot message.

```dart
@freezed
class StreamingState with _$StreamingState {
  const factory StreamingState({
    required String messageId,
    required String accumulatedContent,
    required DateTime startTime,
    required bool isPaused,
  }) = _StreamingState;
}
```

---

## Relationships Summary

| Parent | Child | Cardinality | Notes |
|--------|-------|-------------|-------|
| Conversation | Message | 1:N | Messages belong to exactly one conversation |
| Conversation | TargetApp | N:1 | Conversation uses one target app context |
| ChatState | Conversation | 1:1 | One active conversation at a time |
| ChatState | TargetApp | 1:1 | Currently selected target app |

---

## Storage Strategy

| Data | Storage | Persistence |
|------|---------|-------------|
| conversationId | flutter_secure_storage | Persisted across restarts |
| userId | flutter_secure_storage | Persisted across restarts |
| JWT token | flutter_secure_storage | Persisted across restarts |
| selectedTargetApp | Riverpod state | In-memory (resets to default on restart) |
| messages | Fetched from API | Not persisted locally (loaded from history API) |
| activeConversation | Riverpod state | In-memory |
