# Implementation Plan: Mobile Chat Client

**Branch**: `001-chat-client` | **Date**: 2026-02-16 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-chat-client/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Build a production-ready Flutter mobile chat client that connects to existing backend APIs, featuring real-time SSE streaming responses, markdown rendering (including tables, code blocks with SQL syntax highlighting), session management with isolated conversations, and multi-app targeting (STS_LP, TMS, QMS). Uses Clean Architecture with Riverpod 3.x state management, Dio networking, and Material 3 theming.

## Technical Context

**Language/Version**: Dart 3.11.0 / Flutter 3.41.0 (stable)  
**Primary Dependencies**: flutter_riverpod 3.2.1, dio 5.9.1, freezed 3.2.5, go_router 17.1.0, flex_color_scheme 8.4.0, flutter_secure_storage 10.0.0, flutter_markdown (latest stable)  
**Storage**: flutter_secure_storage for JWT/conversationId, local state via Riverpod  
**Testing**: flutter_test (unit), integration_test (integration), mockito for mocking  
**Target Platform**: Android 5.0+ (SDK 21-35), iOS 12.2+  
**Project Type**: mobile  
**Performance Goals**: Streaming response start within 2 seconds, chat history load within 3 seconds, 60 fps UI rendering  
**Constraints**: No crashes under any error condition, graceful network failure handling, single message bubble during streaming  
**Scale/Scope**: Single chat screen, ~10 UI components, 3 API endpoints, multi-target-app support

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Backend API Compliance | ✅ PASS | Uses exact endpoints: POST /api/chat, GET /api/chat/history/{userId}. Request body matches spec. Configurable base URL. |
| II. Session Isolation | ✅ PASS | conversationId generated as UUID, persisted locally, recreated on New Chat or target app switch. Messages isolated per session. |
| III. Streaming-First UI | ✅ PASS | SSE streaming via Dio, single bubble updates, typing indicator, pause button, response time tracking. Send disabled during stream. |
| IV. Rich Content Rendering | ✅ PASS | flutter_markdown for headings, bold/italic, lists, links. Custom code block with copy. SQL detection. Table with scroll + Excel download. |
| V. Error Resilience | ✅ PASS | Global Dio error interceptor, user-friendly messages, no crashes requirement explicit in spec. |
| Mandatory UI Features | ✅ PASS | All 9 required features specified: input, send, typing indicator, new session, pause, rephrase, copy, response time, target selector. |
| Standard Chatbot Behaviors | ✅ PASS | Message ordering, no duplicates, session isolation, scroll behavior, history preservation all addressed. |

**Gate Status**: ✅ PASSED - All constitution principles satisfied. Proceeding to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/001-chat-client/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (OpenAPI specs)
│   └── chat-api.yaml
└── tasks.md             # Phase 2 output
```

### Source Code (Clean Architecture - Flutter)

```text
lib/
├── main.dart                          # App entry, ProviderScope, MaterialApp
├── core/
│   ├── constants/
│   │   └── api_constants.dart         # Base URL, endpoints
│   ├── network/
│   │   ├── api_client.dart            # Dio setup with interceptors
│   │   ├── auth_interceptor.dart      # JWT injection
│   │   ├── error_interceptor.dart     # Global error handling
│   │   └── sse_handler.dart           # SSE streaming parser
│   ├── router/
│   │   └── app_router.dart            # GoRouter configuration
│   ├── theme/
│   │   ├── app_theme.dart             # FlexColorScheme + M3
│   │   └── design_tokens.dart         # Spacing, radius, typography
│   ├── utils/
│   │   ├── uuid_generator.dart        # UUID for conversationId
│   │   └── clipboard_utils.dart       # Clipboard operations
│   └── storage/
│       └── secure_storage.dart        # flutter_secure_storage wrapper
│
├── features/
│   └── chat/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── chat_remote_datasource.dart
│       │   ├── models/
│       │   │   ├── message_dto.dart           # Freezed + json_serializable
│       │   │   ├── conversation_dto.dart
│       │   │   └── target_app_dto.dart
│       │   └── repositories/
│       │       └── chat_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── message.dart               # Freezed domain model
│       │   │   ├── conversation.dart
│       │   │   └── target_app.dart
│       │   └── repositories/
│       │       └── chat_repository.dart       # Abstract interface
│       └── presentation/
│           ├── providers/
│           │   ├── chat_provider.dart         # @riverpod annotated
│           │   ├── message_provider.dart
│           │   └── session_provider.dart
│           ├── screens/
│           │   └── chat_screen.dart
│           └── widgets/
│               ├── message_bubble.dart
│               ├── message_input.dart
│               ├── typing_indicator.dart
│               ├── target_app_selector.dart
│               ├── markdown_renderer.dart
│               ├── code_block_widget.dart
│               ├── table_widget.dart
│               └── response_time_indicator.dart

test/
├── unit/
│   ├── providers/
│   └── repositories/
├── widget/
│   └── widgets/
└── integration/
    └── chat_flow_test.dart
```

**Structure Decision**: Flutter Clean Architecture with feature-based modular structure. Single `chat` feature containing data, domain, and presentation layers. Core utilities shared across features.

## Complexity Tracking

> All constitution gates passed. No violations requiring justification.

*No entries required.*

## Constitution Re-Check (Post-Design)

*Re-evaluated after Phase 1 design completion.*

| Principle | Status | Evidence from Design |
|-----------|--------|----------------------|
| I. Backend API Compliance | ✅ PASS | [chat-api.yaml](contracts/chat-api.yaml) documents exact endpoints. MessageDto maps to required request format. |
| II. Session Isolation | ✅ PASS | [data-model.md](data-model.md) defines Conversation entity with conversationId rules and state transitions. |
| III. Streaming-First UI | ✅ PASS | [research.md](research.md) specifies Dio streaming with CancelToken for pause. StreamingState model tracks in-progress streams. |
| IV. Rich Content Rendering | ✅ PASS | [research.md](research.md) defines flutter_markdown setup, custom CodeBlockBuilder, and excel package for table export. |
| V. Error Resilience | ✅ PASS | Dio error interceptor pattern documented. ChatState includes errorMessage field for graceful display. |
| Mandatory UI Features | ✅ PASS | Project structure includes all required widgets: message_bubble, typing_indicator, target_app_selector, etc. |
| Standard Chatbot Behaviors | ✅ PASS | ChatState and Conversation models enforce message ordering and session isolation. |

**Post-Design Gate Status**: ✅ PASSED - Design artifacts align with constitution requirements.
