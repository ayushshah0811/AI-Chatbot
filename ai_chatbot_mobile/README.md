# AI Chatbot Mobile

A production-ready Flutter chat client that connects to backend APIs, featuring real-time SSE streaming responses, markdown rendering (including tables, code blocks with syntax highlighting), session management with isolated conversations, and multi-app targeting (STS_LP, TMS, QMS).

## Features

- **Real-time Streaming** — SSE-based streaming responses with typing indicator and pause control
- **Rich Content Rendering** — Markdown with headings, bold/italic, lists, blockquotes, code blocks (SQL, JSON, Dart), and tables
- **Code Blocks** — Syntax-highlighted with one-tap copy
- **Table Support** — Horizontally scrollable with Excel export
- **Target App Switching** — Isolated conversations per app (STS_LP, TMS, QMS)
- **Session Management** — New chat, conversation history, persistent user identity
- **Copy & Rephrase** — Copy bot responses, rephrase user messages
- **Error Resilience** — Graceful network failure handling, retry mechanism, no-crash guarantee
- **Material 3 Theming** — Light/dark mode with FlexColorScheme

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.41.0 / Dart 3.11.0 |
| State Management | Riverpod 3.x (code-gen) |
| Networking | Dio 5.x with SSE streaming |
| Code Generation | Freezed, json_serializable, riverpod_generator |
| Theming | FlexColorScheme 8.x, Material 3 |
| Storage | flutter_secure_storage |
| Markdown | flutter_markdown + flutter_highlight |
| Export | excel 4.x + share_plus |
| Routing | GoRouter 17.x |

## Prerequisites

- Flutter SDK 3.41.0+ (stable)
- Dart SDK 3.11.0+
- Android SDK 21–35 / Xcode 15+ (iOS)

## Getting Started

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Run code generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run (mock mode — no backend needed)

```bash
flutter run
```

By default, `USE_MOCK_DATA=true` so the app uses simulated responses. To connect to a real backend:

```bash
flutter run --dart-define=USE_MOCK_DATA=false --dart-define=API_BASE_URL=https://your-api.example.com
```

### 4. Run tests

```bash
flutter test
```

### 5. Build APK

```bash
flutter build apk --debug
flutter build apk --release
```

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/     # API & app constants
│   ├── network/       # Dio client, interceptors, SSE handler
│   ├── router/        # GoRouter configuration
│   ├── storage/       # Secure storage wrapper
│   ├── theme/         # Material 3 theme & design tokens
│   └── utils/         # UUID, clipboard, Excel export
└── features/
    └── chat/
        ├── data/          # DTOs, datasources, repository impl
        ├── domain/        # Entities, repository interface
        └── presentation/  # Providers, screens, widgets
```

## Architecture

Clean Architecture with feature-based modules:

- **Domain** — Entities (`Message`, `Conversation`, `TargetApp`) and repository interfaces
- **Data** — DTOs, mappers, remote/mock data sources, repository implementation
- **Presentation** — Riverpod providers (ChatNotifier, SessionNotifier), widgets, screens

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `USE_MOCK_DATA` | `true` | Use mock data source instead of real API |
| `API_BASE_URL` | `http://10.0.2.2:8080` | Backend API base URL |

## License

Proprietary — internal use only.
