# Phase 2: Foundational — Implementation Checklist

All items verified against `flutter analyze` (zero issues) and `flutter build apk --debug` (success).

---

## 2.1 Constants & Configuration

- [x] **T008 — API Constants** (`lib/core/constants/api_constants.dart`)
  - [x] Base URL from environment variable (default `localhost:3978`)
  - [x] Chat endpoint path (`/api/chat`)
  - [x] History endpoint path (`/api/chat/history`)
  - [x] Connection timeout (30s)
  - [x] Receive timeout (60s)
  - [x] SSE data prefix (`data: `)
  - [x] SSE done marker (`[DONE]`)
  - [x] `USE_MOCK_DATA` flag from environment

- [x] **T009 — App Constants** (`lib/core/constants/app_constants.dart`)
  - [x] App name constant (`AI Chatbot`)
  - [x] Target app enum/list: STS_LP, TMS, QMS
  - [x] `TargetAppConfig` class with id, label, description
  - [x] Storage key constants (jwt, conversationId, userId, targetApp)
  - [x] Default UI values (max message length, etc.)

## 2.2 Theme & Design System

- [x] **T010 — Design Tokens** (`lib/core/theme/design_tokens.dart`)
  - [x] 8px grid spacing system (xs=4, sm=8, md=16, lg=24, xl=32, xxl=48)
  - [x] Border radius tokens (sm=4, md=8, lg=12, xl=16, pill=100)
  - [x] Typography scale tokens (display, headline, title, body, label sizes)
  - [x] Elevation tokens (none, low, medium, high)
  - [x] Animation duration tokens (fast=150ms, normal=300ms, slow=500ms)

- [x] **T011 — App Theme** (`lib/core/theme/app_theme.dart`)
  - [x] FlexColorScheme integration with Material 3
  - [x] Light theme definition
  - [x] Dark theme definition
  - [x] Chat-specific colors (user bubble, bot bubble, code block background)
  - [x] Custom text theme integration with design tokens

## 2.3 Core Utilities

- [x] **T012 — UUID Generator** (`lib/core/utils/uuid_generator.dart`)
  - [x] `generate()` method returning UUID v4 string
  - [x] `isValid()` validation method with regex

- [x] **T013 — Clipboard Utils** (`lib/core/utils/clipboard_utils.dart`)
  - [x] `copyToClipboard()` — copies text to system clipboard
  - [x] `readFromClipboard()` — reads text from system clipboard
  - [x] `copyWithFeedback()` — copy with overlay snackbar notification

- [x] **T014 — Secure Storage** (`lib/core/storage/secure_storage.dart`)
  - [x] `SecureStorageService` class wrapping `FlutterSecureStorage`
  - [x] `saveJwt()` / `getJwt()` / `deleteJwt()`
  - [x] `saveConversationId()` / `getConversationId()` / `deleteConversationId()`
  - [x] `saveUserId()` / `getUserId()` / `deleteUserId()`
  - [x] `saveTargetApp()` / `getTargetApp()` / `deleteTargetApp()`
  - [x] `clearAll()` method for full reset

## 2.4 Networking Infrastructure

- [x] **T015 — Error Interceptor** (`lib/core/network/error_interceptor.dart`)
  - [x] Extends `Interceptor` with `onError` override
  - [x] Maps `DioExceptionType` to user-friendly messages
  - [x] Connection timeout → "Connection timed out"
  - [x] Receive timeout → "Server took too long to respond"
  - [x] Cancel → "Request was cancelled"
  - [x] Connection error → "No internet connection"
  - [x] HTTP status code mapping (401, 403, 404, 5xx, etc.)
  - [x] Null-safe handling of nullable status codes

- [x] **T016 — Auth Interceptor** (`lib/core/network/auth_interceptor.dart`)
  - [x] Extends `Interceptor` with `onRequest` override
  - [x] Reads JWT from `SecureStorageService`
  - [x] Injects `Authorization: Bearer <token>` header when token exists
  - [x] No-op when no token stored

- [x] **T017 — SSE Handler** (`lib/core/network/sse_handler.dart`)
  - [x] `SseHandler` class with `transformStream()` method
  - [x] UTF-8 decoding of raw byte stream
  - [x] Line splitting via `LineSplitter`
  - [x] `data: ` prefix stripping to extract content
  - [x] `[DONE]` marker detection via `takeWhile`
  - [x] Empty line filtering

- [x] **T018 — API Client** (`lib/core/network/api_client.dart`)
  - [x] `ApiClient` class wrapping Dio instance
  - [x] BaseOptions with timeouts from `ApiConstants`
  - [x] `AuthInterceptor` registered
  - [x] `ErrorInterceptor` registered
  - [x] `get<T>()` typed method
  - [x] `post<T>()` typed method
  - [x] `postStream()` method with `ResponseType.stream` for SSE
  - [x] `put<T>()` typed method
  - [x] `delete<T>()` typed method

## 2.5 Navigation

- [x] **T019 — App Router** (`lib/core/router/app_router.dart`)
  - [x] `AppRoutes` class with path constants (chat: `/`)
  - [x] `GoRouter` instance with initial location `/`
  - [x] Chat route mapped to `ChatScreen`
  - [x] `errorBuilder` with styled error page
  - [x] `ChatScreen` placeholder shell created (`lib/features/chat/presentation/screens/chat_screen.dart`)

## 2.6 App Entry Point

- [x] **T020 — main.dart** (`lib/main.dart`)
  - [x] `WidgetsFlutterBinding.ensureInitialized()`
  - [x] `ProviderScope` wrapping the app (Riverpod)
  - [x] `MaterialApp.router` with `GoRouter` integration
  - [x] `AppTheme.light` and `AppTheme.dark` applied
  - [x] App title from `AppConstants.appName`
  - [x] `AiChatbotApp` widget class exported

## 2.7 Code Generation Setup

- [x] **T021 — Build Runner Verification**
  - [x] `dart run build_runner build --delete-conflicting-outputs` executed
  - [x] `riverpod_generator` — 15 inputs, all no-op (no annotated classes yet)
  - [x] `freezed` — 15 inputs, all no-op (no annotated classes yet)
  - [x] `json_serializable` — processed successfully
  - [x] `mockito:mockBuilder` — 4 inputs processed
  - [x] No errors, pipeline ready for Phase 3 model generation

---

## Validation Summary

| Check                | Result      |
|----------------------|-------------|
| `flutter analyze`    | 0 issues    |
| `flutter build apk --debug` | ✓ Success |
| `build_runner build` | ✓ Success   |
| Widget test updated  | ✓ Passes    |

**Phase 2 Status: COMPLETE** — All 14 tasks (T008–T021) implemented and verified.
