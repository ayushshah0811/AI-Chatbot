# Quickstart: Mobile Chat Client

**Feature Branch**: `001-chat-client`  
**Date**: 2026-02-16

## Prerequisites

- Flutter SDK 3.41.0 (stable)
- Dart SDK 3.11.0
- Android Studio / Xcode
- Backend API running at configurable URL (default: `http://localhost:3978`)

## Project Setup

### 1. Create Flutter Project

```bash
flutter create ai_chatbot_mobile --org com.yourcompany --platforms android,ios
cd ai_chatbot_mobile
```

### 2. Replace pubspec.yaml

```yaml
name: ai_chatbot_mobile
description: AI Chatbot Mobile Client
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.11.0
  flutter: ^3.41.0

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^3.2.1
  riverpod_annotation: ^4.0.2
  
  # Networking
  dio: ^5.9.1
  
  # Storage
  flutter_secure_storage: ^10.0.0
  
  # Navigation
  go_router: ^17.1.0
  
  # Theming
  flex_color_scheme: ^8.4.0
  
  # Animations
  flutter_animate: ^4.5.2
  
  # Markdown
  flutter_markdown: ^0.7.4
  
  # Code Highlighting
  flutter_highlight: ^0.8.0
  highlight: ^0.7.0
  
  # Utilities
  uuid: ^4.5.1
  excel: ^4.0.6
  share_plus: ^10.1.4
  path_provider: ^2.1.5
  url_launcher: ^6.3.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  
  # Code Generation
  build_runner: ^2.4.14
  riverpod_generator: ^4.0.3
  freezed: ^3.2.5
  freezed_annotation: ^3.0.0
  json_serializable: ^6.12.0
  mockito: ^5.4.5
  build_verify: ^3.1.0

flutter:
  uses-material-design: true
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Create Directory Structure

```bash
# Create core directories
mkdir -p lib/core/{constants,network,router,theme,utils,storage}

# Create chat feature directories  
mkdir -p lib/features/chat/{data/{datasources,models,repositories},domain/{entities,repositories},presentation/{providers,screens,widgets}}

# Create test directories
mkdir -p test/{unit/{providers,repositories},widget/widgets,integration}
```

### 5. Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Quick Verification

### Check Flutter Version

```bash
flutter --version
# Should show: Flutter 3.41.0 • Dart 3.11.0
```

### Verify Dependencies

```bash
flutter pub deps
# Check for any version conflicts
```

### Run App

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios
```

## Configuration

### Backend URL

Create `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3978',
  );
  
  static const String chatEndpoint = '/api/chat';
  static String historyEndpoint(String userId) => '/api/chat/history/$userId';
  
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

### Run with Custom Backend URL

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:3978
```

## Key Implementation Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point with ProviderScope |
| `lib/core/network/api_client.dart` | Dio configuration |
| `lib/core/network/sse_handler.dart` | SSE streaming parser |
| `lib/core/router/app_router.dart` | GoRouter setup |
| `lib/core/theme/app_theme.dart` | Material 3 theme |
| `lib/features/chat/presentation/screens/chat_screen.dart` | Main chat UI |
| `lib/features/chat/presentation/providers/chat_provider.dart` | Chat state management |

## Build Commands

### Development

```bash
# Run with hot reload
flutter run

# Run code generation (after model changes)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
dart run build_runner watch --delete-conflicting-outputs
```

### Production

```bash
# Android APK
flutter build apk --release --dart-define=API_BASE_URL=https://api.production.com

# Android App Bundle
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.production.com

# iOS
flutter build ios --release --dart-define=API_BASE_URL=https://api.production.com
```

## Testing

```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# Integration tests
flutter test integration_test/

# All tests with coverage
flutter test --coverage
```

## Troubleshooting

### Code Generation Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### iOS Build Issues

```bash
cd ios
pod install --repo-update
cd ..
flutter build ios
```

### Android minSdk Issues

Ensure `android/app/build.gradle` has:
```gradle
defaultConfig {
    minSdk = 21
    targetSdk = 35
}
```
