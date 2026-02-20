# Tasks: Mobile Chat Client

**Feature Branch**: `001-chat-client`  
**Date**: 2026-02-16  
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅

**Test Approach**: TDD - Tests written first, verified to fail, then implementation  
**Mock Data**: USE_MOCK_DATA flag for backend unavailability

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4, US5, US6)
- All paths relative to repository root

---

## Phase 1: Setup (Project Initialization)

**Purpose**: Create Flutter project with all dependencies and folder structure

- [x] T001 Create Flutter project with `flutter create ai_chatbot_mobile --platforms android,ios`
- [x] T002 Replace pubspec.yaml with exact dependency versions from quickstart.md
- [x] T003 Run `flutter pub get` and verify all dependencies resolve
- [x] T004 [P] Create directory structure per plan.md: lib/core/, lib/features/chat/, test/
- [x] T005 [P] Configure analysis_options.yaml with flutter_lints rules
- [x] T006 [P] Create .env.example with API_BASE_URL placeholder
- [x] T007 Run initial build to verify project compiles: `flutter build apk --debug`

**Checkpoint**: Project structure created, dependencies installed, compiles without errors

---

## Phase 2: Foundational (Core Infrastructure)

**Purpose**: Core utilities that ALL user stories depend on - MUST complete before user story work

### 2.1 Constants & Configuration

- [x] T008 [P] Create API constants in lib/core/constants/api_constants.dart
  - Base URL from environment, endpoints, timeouts, USE_MOCK_DATA flag
- [x] T009 [P] Create app constants in lib/core/constants/app_constants.dart
  - Target app list (STS_LP, TMS, QMS), default values

### 2.2 Theme & Design System

- [x] T010 [P] Create design tokens in lib/core/theme/design_tokens.dart
  - Spacing (8px grid), border radius, typography scales
- [x] T011 [P] Create app theme in lib/core/theme/app_theme.dart
  - FlexColorScheme setup, Material 3, light/dark modes

### 2.3 Core Utilities

- [x] T012 [P] Create UUID generator in lib/core/utils/uuid_generator.dart
  - Wrapper around uuid package for conversationId generation
- [x] T013 [P] Create clipboard utils in lib/core/utils/clipboard_utils.dart
  - Copy to clipboard with success feedback
- [x] T014 [P] Create secure storage wrapper in lib/core/storage/secure_storage.dart
  - flutter_secure_storage abstraction for JWT, conversationId, userId

### 2.4 Networking Infrastructure

- [x] T015 Create error interceptor in lib/core/network/error_interceptor.dart
  - Global error handling, user-friendly messages, no crashes
- [x] T016 Create auth interceptor in lib/core/network/auth_interceptor.dart
  - JWT token injection from secure storage
- [x] T017 Create SSE handler in lib/core/network/sse_handler.dart
  - Stream transformer for "data: " prefix parsing, chunk extraction
- [x] T018 Create API client in lib/core/network/api_client.dart
  - Dio setup with interceptors, timeouts, streaming support

### 2.5 Navigation

- [x] T019 Create app router in lib/core/router/app_router.dart
  - GoRouter configuration with chat route

### 2.6 App Entry Point

- [x] T020 Create main.dart in lib/main.dart
  - ProviderScope, MaterialApp.router, theme application

### 2.7 Code Generation Setup

- [x] T021 Run `dart run build_runner build --delete-conflicting-outputs` to verify setup

**Checkpoint**: Core infrastructure complete. App launches with empty chat screen shell. All user stories can now begin. 

---

## Phase 3: User Story 1 - Send Message and Receive Streaming Response (Priority: P1) 🎯 MVP

**Goal**: User can type a message, send it, and see the AI response stream progressively into a single bubble

**Independent Test**: Send any message → see typing indicator → see response stream character-by-character → see "Answered in X seconds"

### 3.1 Domain Layer (US1)

- [x] T022 [P] [US1] Create MessageSender enum in lib/features/chat/domain/entities/message_sender.dart
- [x] T023 [P] [US1] Create MessageStatus enum in lib/features/chat/domain/entities/message_status.dart
- [x] T024 [US1] Create Message entity (Freezed) in lib/features/chat/domain/entities/message.dart
  - Fields: id, content, sender, timestamp, conversationId, status, responseTimeMs
- [x] T025 [P] [US1] Create TargetApp entity (Freezed) in lib/features/chat/domain/entities/target_app.dart
- [x] T026 [US1] Create Conversation entity (Freezed) in lib/features/chat/domain/entities/conversation.dart
- [x] T027 [US1] Create ChatRepository abstract interface in lib/features/chat/domain/repositories/chat_repository.dart
  - Methods: sendMessage (Stream), loadHistory, generateConversationId
- [x] T028 [US1] Run code generation: `dart run build_runner build --delete-conflicting-outputs`

### 3.2 Data Layer (US1)

- [x] T029 [P] [US1] Create MessageDto (Freezed + json_serializable) in lib/features/chat/data/models/message_dto.dart
  - Request DTO: message, userId, conversationId, targetApp
- [x] T030 [P] [US1] Create ChatHistoryItemDto in lib/features/chat/data/models/chat_history_item_dto.dart
- [x] T031 [P] [US1] Create ChatHistoryResponseDto in lib/features/chat/data/models/chat_history_response_dto.dart
- [x] T032 [US1] Create DTO-Domain mappers in lib/features/chat/data/mappers/message_mapper.dart
- [x] T033 [US1] Create ChatRemoteDataSource in lib/features/chat/data/datasources/chat_remote_datasource.dart
  - POST /api/chat with SSE streaming, GET /api/chat/history/{userId}
- [x] T034 [US1] Create MockChatDataSource in lib/features/chat/data/datasources/mock_chat_datasource.dart
  - Simulates streaming with delayed chunks for testing without backend
- [x] T035 [US1] Create ChatRepositoryImpl in lib/features/chat/data/repositories/chat_repository_impl.dart
  - Switches between real/mock based on USE_MOCK_DATA flag
- [x] T036 [US1] Run code generation: `dart run build_runner build --delete-conflicting-outputs`

### 3.3 Presentation Layer - Providers (US1)

- [x] T037 [US1] Create ChatState (Freezed) in lib/features/chat/presentation/providers/chat_state.dart
  - Fields: activeConversation, selectedTargetApp, isStreaming, isSendEnabled, errorMessage, lastResponseTimeMs
- [x] T038 [US1] Create StreamingState (Freezed) in lib/features/chat/presentation/providers/streaming_state.dart
  - Fields: messageId, accumulatedContent, startTime, isPaused
- [x] T039 [US1] Create SessionProvider (@riverpod) in lib/features/chat/presentation/providers/session_provider.dart
  - Manages conversationId, userId persistence
- [x] T040 [US1] Create ChatProvider (@riverpod) in lib/features/chat/presentation/providers/chat_provider.dart
  - sendMessage(), pauseStreaming(), clearError()
  - AsyncValue for loading/error/data states
- [x] T041 [US1] Run code generation: `dart run build_runner build --delete-conflicting-outputs`

### 3.4 Presentation Layer - Widgets (US1)

- [x] T042 [P] [US1] Create MessageBubble widget in lib/features/chat/presentation/widgets/message_bubble.dart
  - Distinct styling for user vs bot, status indicators
- [x] T043 [P] [US1] Create TypingIndicator widget in lib/features/chat/presentation/widgets/typing_indicator.dart
  - Shows "Searching..." or "Thinking..." with animation
- [x] T044 [P] [US1] Create MessageInput widget in lib/features/chat/presentation/widgets/message_input.dart
  - TextField with Send button, disabled state during streaming
- [x] T045 [P] [US1] Create PauseButton widget in lib/features/chat/presentation/widgets/pause_button.dart
  - Visible during streaming, cancels request via CancelToken
- [x] T046 [P] [US1] Create ResponseTimeIndicator widget in lib/features/chat/presentation/widgets/response_time_indicator.dart
  - Shows "Answered in X.X seconds" after completion
- [x] T047 [US1] Create MessageList widget in lib/features/chat/presentation/widgets/message_list.dart
  - ListView.builder with auto-scroll to bottom on new messages

### 3.5 Screen Assembly (US1)

- [x] T048 [US1] Create ChatScreen in lib/features/chat/presentation/screens/chat_screen.dart
  - Integrates MessageList, MessageInput, TypingIndicator, PauseButton
  - Wires up ChatProvider for state management
- [x] T049 [US1] Update app_router.dart to include ChatScreen as home route
- [x] T050 [US1] Run full app and test: send message → streaming response → completion

**Checkpoint**: User Story 1 complete. Can send message, see streaming response in single bubble, see typing indicator, pause streaming, see response time.

---

## Phase 4: User Story 2 - View and Continue Chat History (Priority: P2)

**Goal**: Chat history loads on app open, displays in correct order, supports scrolling

**Independent Test**: Send messages → close app → reopen → previous messages visible in order

### 4.1 History Loading (US2)

- [x] T051 [US2] Add loadHistory() method to ChatProvider in lib/features/chat/presentation/providers/chat_provider.dart
  - Calls GET /api/chat/history/{userId} on init
- [x] T052 [US2] Update MockChatDataSource to return mock history data
- [x] T053 [US2] Update ChatScreen to call loadHistory on mount
- [x] T054 [US2] Implement auto-scroll behavior in MessageList
  - Scroll to bottom when new messages arrive (if already at bottom)

### 4.2 Storage Integration (US2)

- [x] T055 [US2] Persist userId to secure storage on first launch in SessionProvider
- [x] T056 [US2] Load userId from secure storage on app start

**Checkpoint**: User Story 2 complete. History loads on app open, scrolling works, new messages auto-scroll.

---

## Phase 5: User Story 3 - Switch Target Application (Priority: P2)

**Goal**: User can switch between STS_LP, TMS, QMS and get isolated conversations

**Independent Test**: Select different target app → chat clears → new conversationId → send message uses new context

### 5.1 Target App Selector (US3)

- [x] T057 [P] [US3] Create TargetAppSelector widget in lib/features/chat/presentation/widgets/target_app_selector.dart
  - Dropdown with available apps from app_constants.dart
- [x] T058 [US3] Add switchTargetApp() method to ChatProvider
  - Generates new conversationId, clears messages, updates state
- [x] T059 [US3] Integrate TargetAppSelector into ChatScreen app bar

### 5.2 Session Isolation (US3)

- [x] T060 [US3] Update SessionProvider to handle target app changes
  - Persist new conversationId, clear old session
- [x] T061 [US3] Test: switch app → verify new conversationId → verify messages cleared

**Checkpoint**: User Story 3 complete. Target app switching creates new isolated session.

---

## Phase 6: User Story 4 - Start New Chat Session (Priority: P3)

**Goal**: User can start fresh conversation without changing target app

**Independent Test**: Tap New Chat → messages clear → new conversationId → target app unchanged

### 6.1 New Chat Button (US4)

- [x] T062 [P] [US4] Create NewChatButton widget in lib/features/chat/presentation/widgets/new_chat_button.dart
  - Icon button in app bar
- [x] T063 [US4] Add startNewSession() method to ChatProvider
  - Generates new conversationId, clears messages, keeps targetApp
- [x] T064 [US4] Integrate NewChatButton into ChatScreen app bar
- [x] T065 [US4] Test: tap New Chat → verify messages clear → verify target app same

**Checkpoint**: User Story 4 complete. New Chat button starts fresh conversation.

---

## Phase 7: User Story 5 - View Rich Content (Markdown, Tables, Code) (Priority: P3)

**Goal**: Bot responses render markdown correctly with code copy and table export

**Independent Test**: Request SQL query → see syntax-highlighted code block with Copy → request table → see formatted table with Excel download

### 7.1 Markdown Renderer (US5)

- [x] T066 [US5] Create MarkdownRenderer widget in lib/features/chat/presentation/widgets/markdown_renderer.dart
  - flutter_markdown with custom builders, link handling
- [x] T067 [P] [US5] Create CodeBlockWidget in lib/features/chat/presentation/widgets/code_block_widget.dart
  - Styled container, syntax highlighting for SQL, Copy button
- [x] T068 [P] [US5] Create TableWidget in lib/features/chat/presentation/widgets/table_widget.dart
  - Horizontal scroll, proper column alignment
- [x] T069 [US5] Create CodeBlockBuilder (MarkdownElementBuilder) in lib/features/chat/presentation/widgets/code_block_builder.dart
  - Detects language, renders CodeBlockWidget
- [x] T070 [US5] Create TableBuilder (MarkdownElementBuilder) in lib/features/chat/presentation/widgets/table_builder.dart
  - Parses markdown table, renders TableWidget

### 7.2 Excel Export (US5)

- [x] T071 [US5] Create ExcelExporter utility in lib/core/utils/excel_exporter.dart
  - Uses excel package to create .xlsx from table data
- [x] T072 [US5] Add Download Excel button to TableWidget
  - Exports via share_plus
- [x] T073 [US5] Update MessageBubble to use MarkdownRenderer for bot messages

### 7.3 Testing Rich Content (US5)

- [x] T074 [US5] Update MockChatDataSource to return markdown-rich responses
  - Include headings, code blocks (SQL), tables
- [x] T075 [US5] Test: verify markdown renders → copy code block → download Excel

**Checkpoint**: User Story 5 complete. All markdown renders correctly with copy and export.

---

## Phase 8: User Story 6 - Copy and Rephrase Responses (Priority: P4)

**Goal**: User can copy bot responses and rephrase user messages

**Independent Test**: Tap Copy on bot message → verify clipboard → Tap Rephrase on user message → verify re-send

### 8.1 Copy Response (US6)

- [x] T076 [P] [US6] Create CopyButton widget in lib/features/chat/presentation/widgets/copy_button.dart
  - Uses clipboard_utils, shows success feedback
- [x] T077 [US6] Add CopyButton to MessageBubble for bot messages

### 8.2 Rephrase Message (US6)

- [x] T078 [P] [US6] Create RephraseButton widget in lib/features/chat/presentation/widgets/rephrase_button.dart
- [x] T079 [US6] Add rephrase() method to ChatProvider
  - Populates input field with original message text
- [x] T080 [US6] Add RephraseButton to MessageBubble for user messages
- [x] T081 [US6] Test: tap Rephrase → verify input populated → send → verify message goes

**Checkpoint**: User Story 6 complete. Copy and Rephrase functionality works.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Error handling, edge cases, final integration

### 9.1 Error Handling

- [x] T082 Create ErrorDisplay widget in lib/features/chat/presentation/widgets/error_display.dart
  - Shows "Something went wrong. Please try again."
- [x] T083 Add retry mechanism to ChatProvider for failed requests
- [x] T084 Handle network disconnect mid-stream: preserve partial response, show stopped indicator
- [x] T085 Handle malformed markdown gracefully: fallback to plain text

### 9.2 Edge Cases

- [x] T086 Disable Send button during streaming (prevent rapid sends)
- [x] T087 Handle empty backend response: show user-friendly error
- [x] T088 Prevent message duplication in history

### 9.3 Performance

- [x] T089 Optimize MessageList rebuild with proper keys
- [x] T090 Ensure 60fps during streaming with efficient state updates

### 9.4 Documentation & Cleanup

- [x] T091 [P] Add inline documentation to all public APIs
- [x] T092 [P] Update README.md with setup and run instructions
- [x] T093 Run quickstart.md validation: verify all setup steps work

### 9.5 Final Verification

- [x] T094 Run `flutter analyze` and fix all warnings
- [x] T095 Run full app flow manually: all 6 user stories
- [x] T096 Build release APK: `flutter build apk --release`

**Checkpoint**: All user stories complete and polished. App ready for testing/deployment.

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1: Setup
    ↓
Phase 2: Foundational (BLOCKS all user stories)
    ↓
    ├── Phase 3: US1 (P1) - Core messaging 🎯 MVP
    │       ↓
    │   Phase 4: US2 (P2) - Chat history [depends on US1 messages]
    │       
    ├── Phase 5: US3 (P2) - Target app switching [can start after US1]
    │       
    ├── Phase 6: US4 (P3) - New chat [can start after US1]
    │       
    ├── Phase 7: US5 (P3) - Rich content [can start after US1 MessageBubble]
    │       
    └── Phase 8: US6 (P4) - Copy/Rephrase [can start after US1 MessageBubble]
            ↓
    Phase 9: Polish (after all desired user stories complete)
```

### MVP Delivery

**Minimum Viable Product = Phase 1 + Phase 2 + Phase 3 (User Story 1)**

After T050, the app delivers core value: send message and see streaming response.

### Parallel Execution Matrix

| Task Group | Can Parallelize With |
|------------|---------------------|
| T008-T009 (Constants) | T010-T011 (Theme), T012-T014 (Utils) |
| T022-T023 (Enums) | T025 (TargetApp entity) |
| T029-T031 (DTOs) | Each other |
| T042-T046 (US1 Widgets) | Each other |
| T057, T062 (App bar buttons) | Each other |
| T066-T068 (Markdown widgets) | Each other |

### Worker Assignment Example

**Single developer**: Execute sequentially T001 → T096

**Two developers**:
- Dev 1: Phases 1-2, then US1 (T022-T050)
- Dev 2: After Phase 2, start US3 + US4 in parallel

**Three developers**:
- Dev 1: Phases 1-2, US1
- Dev 2: After Phase 2, US2 + US3
- Dev 3: After Phase 2, US4 + US5 + US6

---

## Summary

| Phase | Tasks | Parallelizable | Estimated Complexity |
|-------|-------|----------------|---------------------|
| 1. Setup | T001-T007 | 3 | Simple |
| 2. Foundational | T008-T021 | 8 | Medium |
| 3. US1 (P1) MVP | T022-T050 | 12 | Complex |
| 4. US2 (P2) | T051-T056 | 0 | Medium |
| 5. US3 (P2) | T057-T061 | 1 | Medium |
| 6. US4 (P3) | T062-T065 | 1 | Simple |
| 7. US5 (P3) | T066-T075 | 4 | Complex |
| 8. US6 (P4) | T076-T081 | 2 | Simple |
| 9. Polish | T082-T096 | 2 | Medium |
| **Total** | **96 tasks** | **33** | — |

---

## Validation Checkpoints

| After Task | Validation |
|------------|------------|
| T007 | `flutter run` shows default counter app |
| T021 | `flutter run` shows themed app shell |
| T050 | Send message → see streaming response |
| T056 | Close app → reopen → history visible |
| T061 | Switch target app → new conversation |
| T065 | New Chat → fresh session |
| T075 | SQL/tables render with copy/export |
| T081 | Copy/Rephrase buttons work |
| T096 | Release build succeeds |
