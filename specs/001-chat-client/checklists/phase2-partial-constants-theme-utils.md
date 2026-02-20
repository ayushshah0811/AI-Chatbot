# Phase 2 (Partial): Constants, Theme & Core Utilities — Implementation Checklist

**Feature**: Mobile Chat Client  
**Phase**: 2.1, 2.2, 2.3 (Foundational — Constants, Theme, Core Utilities)  
**Completed**: 2026-02-19

## Tasks Completed

| Task | Description | Status |
|------|-------------|--------|
| T008 | Create API constants (`api_constants.dart`) | ✅ Done |
| T009 | Create app constants (`app_constants.dart`) | ✅ Done |
| T010 | Create design tokens (`design_tokens.dart`) | ✅ Done |
| T011 | Create app theme (`app_theme.dart`) | ✅ Done |
| T012 | Create UUID generator (`uuid_generator.dart`) | ✅ Done |
| T013 | Create clipboard utils (`clipboard_utils.dart`) | ✅ Done |
| T014 | Create secure storage wrapper (`secure_storage.dart`) | ✅ Done |

## Functionalities Implemented

### 2.1 Constants & Configuration

#### API Constants (`lib/core/constants/api_constants.dart`)
- [x] `baseUrl` — configurable via `--dart-define=API_BASE_URL`, default `http://localhost:3978`
- [x] `useMockData` — configurable via `--dart-define=USE_MOCK_DATA`, default `false`
- [x] `chatEndpoint` — POST `/api/chat` for sending messages with SSE response
- [x] `historyEndpoint(userId)` — GET `/api/chat/history/{userId}` for chat history
- [x] `connectTimeout` — 30s connection timeout
- [x] `receiveTimeout` — 60s receive timeout (accommodates SSE streaming)
- [x] `sendTimeout` — 30s send timeout
- [x] `contentType` — `application/json` for requests
- [x] `acceptStream` — `text/event-stream` for SSE responses
- [x] `sseDataPrefix` — `data: ` SSE line prefix
- [x] `sseDoneMarker` — `[DONE]` SSE stream termination marker

#### App Constants (`lib/core/constants/app_constants.dart`)
- [x] `appName` — Application display name (`AI Chatbot`)
- [x] `appVersion` — Version string (`1.0.0`)
- [x] `targetApps` — List of 3 target apps: STS_LP, TMS, QMS with display names
- [x] `defaultTargetAppId` — Default selection (`STS_LP`)
- [x] Secure storage key constants: `jwt_token`, `conversation_id`, `user_id`, `target_app_id`
- [x] UI defaults: `maxMessageLength` (4000), `typingDebounceDurationMs` (300), `autoScrollThreshold` (100px)
- [x] `TargetAppConfig` class with `id`, `displayName`, `description` fields

### 2.2 Theme & Design System

#### Design Tokens (`lib/core/theme/design_tokens.dart`)
- [x] 8px grid spacing system: `xxxs` (2px) through `huge` (64px) — 11 spacing values
- [x] Border radius tokens: `none` through `full` — 8 radius values
- [x] Typography scale: `caption` (10px) through `display` (32px) — 10 sizes
- [x] Elevation tokens: `none` (0) through `xl` (16) — 5 levels
- [x] Icon size tokens: `sm` (16px) through `xxl` (48px) — 5 sizes
- [x] Animation duration tokens: `instant` (100ms) through `verySlow` (800ms) — 5 durations

#### App Theme (`lib/core/theme/app_theme.dart`)
- [x] FlexColorScheme integration with Material 3 enabled
- [x] Light theme with `FlexScheme.blueM3` base scheme
- [x] Dark theme with matching scheme and higher blend level
- [x] Surface mode: `highScaffoldLowSurface` for both modes
- [x] Sub-theme customization: input decorators (12px radius), buttons (12px), FAB (16px), cards (12px, 1dp elevation), dialogs (20px, 6dp), bottom sheets (20px), snackbar (8px)
- [x] AppBar: surface style, 0.5dp elevation, scroll-under elevation 1dp
- [x] Comfortable platform-adaptive visual density
- [x] Chat-specific color accessors: `userBubbleColor`, `botBubbleColor`, `userBubbleTextColor`, `botBubbleTextColor`
- [x] Code block color accessors: dark background with light text for both light/dark themes

### 2.3 Core Utilities

#### UUID Generator (`lib/core/utils/uuid_generator.dart`)
- [x] `generate()` — Generates RFC 4122 v4 random UUIDs for `conversationId`/`messageId`
- [x] `isValid(String)` — Validates UUID format
- [x] Static utility class (no instantiation required)

#### Clipboard Utils (`lib/core/utils/clipboard_utils.dart`)
- [x] `copyToClipboard(String)` — Copy text, returns `bool` success status
- [x] `readFromClipboard()` — Read clipboard text, returns `String?`
- [x] `copyWithFeedback(String, context)` — Copy with visual overlay toast (2s duration)
- [x] Graceful error handling — catches exceptions, returns failure state
- [x] Customizable success/failure messages

#### Secure Storage (`lib/core/storage/secure_storage.dart`)
- [x] JWT token: `saveJwtToken`, `getJwtToken`, `deleteJwtToken`
- [x] Conversation ID: `saveConversationId`, `getConversationId`, `deleteConversationId`
- [x] User ID: `saveUserId`, `getUserId`, `deleteUserId`
- [x] Target App: `saveTargetAppId`, `getTargetAppId`
- [x] Bulk operations: `clearAll()`, `containsKey(String)`
- [x] Uses platform secure storage (Keychain iOS, EncryptedSharedPreferences Android)
- [x] Injectable dependency: accepts `FlutterSecureStorage` for testing
- [x] Error resilience: all operations catch exceptions with debug logging

## Static Analysis

- [x] `flutter analyze` on all 7 files: **No issues found**

## Checkpoint Status: ✅ PASS

Sections 2.1, 2.2, and 2.3 of Phase 2 complete. Ready to proceed to 2.4 (Networking Infrastructure).
