# Research: Mobile Chat Client

**Feature Branch**: `001-chat-client`  
**Date**: 2026-02-16  
**Status**: Complete

## Technology Decisions

### 1. SSE Streaming with Dio

**Decision**: Use Dio with `ResponseType.stream` and custom SSE parser

**Rationale**:
- Dio 5.9.1 supports streaming responses natively via `ResponseType.stream`
- SSE (Server-Sent Events) format: `data: {chunk}\n\n`
- Custom interceptor not needed; use stream transformer on response

**Implementation Pattern**:
```dart
final response = await dio.post<ResponseBody>(
  '/api/chat',
  data: requestBody,
  options: Options(responseType: ResponseType.stream),
);

final stream = response.data!.stream
    .transform(utf8.decoder)
    .transform(const LineSplitter());

await for (final line in stream) {
  if (line.startsWith('data: ')) {
    final chunk = line.substring(6);
    // Append to message
  }
}
```

**Alternatives Considered**:
- `http` package with streaming: Less feature-rich, no interceptors
- WebSocket: Backend uses SSE, not WebSocket
- `eventsource` package: Adds dependency; Dio handles it natively

---

### 2. Markdown Rendering

**Decision**: flutter_markdown 0.7.4+ with custom builders

**Rationale**:
- Official Flutter package, stable and maintained
- Supports all required elements: headings, bold/italic, lists, links, code blocks, tables
- Extensible via `MarkdownStyleSheet` and custom element builders

**Implementation Pattern**:
```dart
MarkdownBody(
  data: markdownContent,
  selectable: true,
  styleSheet: MarkdownStyleSheet.fromTheme(theme),
  builders: {
    'code': CodeBlockBuilder(), // Custom with copy button
  },
  onTapLink: (text, href, title) => launchUrl(Uri.parse(href!)),
)
```

**Alternatives Considered**:
- `flutter_html`: Heavier, designed for HTML not Markdown
- `markdown_widget`: Less maintained
- Custom parser: Unnecessary complexity

---

### 3. SQL Syntax Highlighting

**Decision**: Use `highlight` or `flutter_highlight` for SQL code blocks

**Rationale**:
- Code blocks with `sql` language tag need syntax highlighting
- `flutter_highlight` wraps `highlight.js` themes
- Can detect language from markdown fence (```sql)

**Implementation Pattern**:
```dart
class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final language = element.attributes['class']?.replaceFirst('language-', '');
    final code = element.textContent;
    
    return CodeBlockWidget(
      code: code,
      language: language ?? 'plaintext',
      onCopy: () => Clipboard.setData(ClipboardData(text: code)),
    );
  }
}
```

**Alternatives Considered**:
- Plain monospace text: No highlighting, poor UX
- `string_scanner` manual parsing: Too complex

---

### 4. Table Rendering with Excel Export

**Decision**: Custom table widget with horizontal scroll + `excel` package for export

**Rationale**:
- flutter_markdown renders tables, but needs custom styling for horizontal scroll
- `excel` package (^4.0.6) creates .xlsx files natively in Dart
- Save via `path_provider` + `share_plus` for export

**Implementation Pattern**:
```dart
// Render table with scroll
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Table(
    children: rows.map((row) => TableRow(
      children: row.cells.map((cell) => TableCell(child: Text(cell))).toList(),
    )).toList(),
  ),
)

// Export to Excel
final excel = Excel.createExcel();
final sheet = excel['Sheet1'];
for (var i = 0; i < rows.length; i++) {
  for (var j = 0; j < rows[i].cells.length; j++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i)).value = 
      TextCellValue(rows[i].cells[j]);
  }
}
final bytes = excel.encode()!;
// Save and share
```

**Alternatives Considered**:
- CSV export: Less professional, Excel preferred
- `syncfusion_flutter_xlsio`: Commercial license required
- Server-side export: Adds backend dependency

---

### 5. UUID Generation

**Decision**: `uuid` package (^4.5.1)

**Rationale**:
- Standard Dart package for UUID v4 generation
- Lightweight, no external dependencies
- Used for `conversationId` generation

**Implementation Pattern**:
```dart
import 'package:uuid/uuid.dart';

final conversationId = const Uuid().v4();
```

**Alternatives Considered**:
- Manual UUID generation: Error-prone
- Timestamp-based IDs: Not universally unique

---

### 6. Secure Storage

**Decision**: flutter_secure_storage 10.0.0

**Rationale**:
- Stores JWT tokens and conversationId securely
- Uses Keychain (iOS) and EncryptedSharedPreferences (Android)
- Already in specified stack

**Implementation Pattern**:
```dart
final storage = FlutterSecureStorage();
await storage.write(key: 'conversationId', value: uuid);
final saved = await storage.read(key: 'conversationId');
```

**Alternatives Considered**:
- SharedPreferences: Not encrypted, unsuitable for tokens
- Hive with encryption: Adds database complexity
- SQLite: Overkill for key-value storage

---

### 7. State Management with Riverpod 3.x

**Decision**: Riverpod 3.2.1 with `@riverpod` annotation-based providers

**Rationale**:
- Compile-time safety with code generation
- `AsyncValue` for handling loading/error/data states
- `Ref.mounted` check for async operations
- No experimental features (offline persistence, mutations)

**Implementation Pattern**:
```dart
@riverpod
class ChatNotifier extends _$ChatNotifier {
  @override
  FutureOr<List<Message>> build() async {
    return ref.watch(chatRepositoryProvider).loadHistory();
  }

  Future<void> sendMessage(String text) async {
    state = const AsyncLoading();
    // Stream handling
  }
}
```

**Alternatives Considered**:
- BLoC: Verbose, not specified in stack
- Provider: Deprecated in favor of Riverpod
- GetX: Not type-safe, not in stack

---

### 8. Cancellation for Pause Feature

**Decision**: Dio `CancelToken` for request cancellation

**Rationale**:
- Dio natively supports request cancellation
- `CancelToken.cancel()` stops the stream immediately
- Partial response preserved before cancellation

**Implementation Pattern**:
```dart
final cancelToken = CancelToken();

final response = await dio.post(
  '/api/chat',
  cancelToken: cancelToken,
  options: Options(responseType: ResponseType.stream),
);

// On pause button tap:
cancelToken.cancel('User paused generation');
```

**Alternatives Considered**:
- Close HTTP client: Affects all requests
- Ignore remaining chunks: Wastes bandwidth

---

### 9. Auto-Scroll Behavior

**Decision**: `ScrollController` with `jumpTo` or `animateTo` on new messages

**Rationale**:
- Detect if user is at bottom before auto-scroll
- Use `WidgetsBinding.instance.addPostFrameCallback` for scroll after build

**Implementation Pattern**:
```dart
final scrollController = ScrollController();

void scrollToBottom() {
  if (scrollController.hasClients) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}
```

**Alternatives Considered**:
- `ListView.reverse`: Changes message order, confusing UX
- Third-party scroll packages: Unnecessary

---

### 10. Response Time Tracking

**Decision**: `Stopwatch` class for timing

**Rationale**:
- Built-in Dart class, no dependencies
- Start on send, stop on stream complete
- Display as "Answered in X.X seconds"

**Implementation Pattern**:
```dart
final stopwatch = Stopwatch()..start();
// ... streaming ...
stopwatch.stop();
final elapsed = stopwatch.elapsedMilliseconds / 1000;
// Display: "Answered in ${elapsed.toStringAsFixed(1)} seconds"
```

---

## Package Versions (Confirmed)

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | 3.2.1 | State management |
| riverpod_annotation | 4.0.2 | Code generation annotations |
| riverpod_generator | 4.0.3 | Provider code generation |
| dio | 5.9.1 | HTTP client with streaming |
| freezed | 3.2.5 | Immutable models |
| freezed_annotation | 3.0.0 | Freezed annotations |
| json_serializable | 6.12.0 | JSON parsing |
| go_router | 17.1.0 | Navigation |
| flex_color_scheme | 8.4.0 | Material 3 theming |
| flutter_secure_storage | 10.0.0 | Secure key-value storage |
| flutter_animate | 4.5.2 | Animations |
| flutter_markdown | ^0.7.4 | Markdown rendering |
| uuid | ^4.5.1 | UUID generation |
| excel | ^4.0.6 | Excel file creation |
| share_plus | ^10.1.4 | File sharing |
| path_provider | ^2.1.5 | File system paths |

## Open Questions Resolved

| Question | Resolution |
|----------|------------|
| How to handle SSE in Dio? | Use `ResponseType.stream` with line-by-line parsing |
| Which markdown package? | flutter_markdown (official, stable) |
| Excel export approach? | `excel` package, pure Dart implementation |
| Request cancellation? | Dio `CancelToken` |
| Secure storage for tokens? | flutter_secure_storage (specified in stack) |
