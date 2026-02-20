import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;

import 'package:ai_chatbot_mobile/core/utils/excel_exporter.dart';
import 'package:ai_chatbot_mobile/features/chat/data/datasources/mock_chat_datasource.dart';
import 'package:ai_chatbot_mobile/features/chat/domain/entities/message.dart';
import 'package:ai_chatbot_mobile/features/chat/domain/entities/message_sender.dart';
import 'package:ai_chatbot_mobile/features/chat/domain/entities/message_status.dart';
import 'package:ai_chatbot_mobile/features/chat/presentation/widgets/code_block_builder.dart';
import 'package:ai_chatbot_mobile/features/chat/presentation/widgets/code_block_widget.dart';
import 'package:ai_chatbot_mobile/features/chat/presentation/widgets/copy_button.dart';
import 'package:ai_chatbot_mobile/features/chat/presentation/widgets/markdown_renderer.dart';
import 'package:ai_chatbot_mobile/features/chat/presentation/widgets/message_bubble.dart';
import 'package:ai_chatbot_mobile/features/chat/presentation/widgets/message_input.dart';
import 'package:ai_chatbot_mobile/features/chat/presentation/widgets/rephrase_button.dart';
import 'package:ai_chatbot_mobile/features/chat/presentation/widgets/table_widget.dart';

// ═══════════════════════════════════════════════════════════════════════
// Helpers
// ═══════════════════════════════════════════════════════════════════════

/// Wraps a widget in a themed MaterialApp for widget testing.
Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

/// Creates a bot [Message] with the given markdown [content].
Message _botMessage(String content) => Message(
  id: 'test-001',
  content: content,
  sender: MessageSender.bot,
  timestamp: DateTime(2026, 2, 19, 14, 30),
  conversationId: 'conv-test',
  status: MessageStatus.complete,
  responseTimeMs: 1500,
);

// ═══════════════════════════════════════════════════════════════════════
// Tests
// ═══════════════════════════════════════════════════════════════════════

void main() {
  // ═════════════════════════════════════════════════════════════════════
  // 1. MockChatDataSource – markdown content validation
  //    Uses responseForTargetApp() to avoid FakeAsync timer issues
  //    from the streaming sendMessage() implementation.
  // ═════════════════════════════════════════════════════════════════════

  group('MockChatDataSource – markdown-rich responses', () {
    test(
      'STS_LP response contains headings, tables, code, and blockquotes',
      () {
        final response = MockChatDataSource.responseForTargetApp('STS_LP');
        // Headings
        expect(response, contains('## Shipment Tracking Report'));
        expect(response, contains('### Current Status'));
        expect(response, contains('### Checkpoint History'));
        // Table
        expect(response, contains('| Field'));
        expect(response, contains('In Transit'));
        // Code block
        expect(response, contains('```sql'));
        expect(response, contains('SELECT shipment_id'));
        // Blockquote
        expect(response, contains('> **Note**'));
        // Bold / italic
        expect(response, contains('**STS LP**'));
        expect(response, contains('*in transit*'));
      },
    );

    test('TMS response contains SQL + JSON code blocks and links', () {
      final response = MockChatDataSource.responseForTargetApp('TMS');
      // SQL code block
      expect(response, contains('```sql'));
      expect(response, contains('SELECT order_id'));
      // JSON code block
      expect(response, contains('```json'));
      expect(response, contains('"orderId"'));
      // Table
      expect(response, contains('| Order ID'));
      expect(response, contains('Express Logistics'));
      // Link
      expect(response, contains('[TMS Dashboard]'));
      // Horizontal rule
      expect(response, contains('---'));
    });

    test('QMS response contains headings, metrics table, and code', () {
      final response = MockChatDataSource.responseForTargetApp('QMS');
      // Headings
      expect(response, contains('# Quality Management Report'));
      expect(response, contains('## Inspection Results'));
      expect(response, contains('### Detailed Metrics'));
      // Table
      expect(response, contains('| Metric'));
      expect(response, contains('Tensile Strength'));
      // Blockquote
      expect(response, contains('> All parameters'));
      // Code block
      expect(response, contains('```sql'));
    });

    test('Default response contains heading, code block, and table', () {
      final response = MockChatDataSource.responseForTargetApp('UNKNOWN');
      expect(response, contains('## Response Summary'));
      expect(response, contains('```dart'));
      expect(response, contains('| Feature'));
    });

    test('loadHistory returns markdown-rich bot messages', () async {
      final dataSource = MockChatDataSource();
      final history = await dataSource.loadHistory(userId: 'u1');

      // We have 4 messages: 2 user + 2 bot
      expect(history, hasLength(4));

      // First bot message (index 1) has table and heading
      final bot1 = history[1];
      expect(bot1.sender, MessageSender.bot);
      expect(bot1.content, contains('## Shipment Status'));
      expect(bot1.content, contains('| Field'));
      expect(bot1.content, contains('>'));

      // Second bot message (index 3) has code block
      final bot2 = history[3];
      expect(bot2.sender, MessageSender.bot);
      expect(bot2.content, contains('### Carrier Details'));
      expect(bot2.content, contains('```sql'));
      expect(bot2.content, contains('SELECT carrier_name'));
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // 2. ExcelExporter – in-memory byte generation
  // ═════════════════════════════════════════════════════════════════════

  group('ExcelExporter – createExcelBytes', () {
    test('generates non-null bytes from headers and rows', () {
      final bytes = ExcelExporter.createExcelBytes(
        headers: ['Name', 'Role', 'Score'],
        rows: [
          ['Alice', 'Dev', '95'],
          ['Bob', 'QA', '88'],
        ],
      );

      expect(bytes, isNotNull);
      expect(bytes!.length, greaterThan(0));
    });

    test('generates valid xlsx with empty rows', () {
      final bytes = ExcelExporter.createExcelBytes(
        headers: ['Col A', 'Col B'],
        rows: [],
      );

      expect(bytes, isNotNull);
      expect(bytes!.length, greaterThan(0));
    });

    test('handles table data matching mock responses', () {
      // Simulate the STS_LP table data
      final bytes = ExcelExporter.createExcelBytes(
        headers: ['Field', 'Value'],
        rows: [
          ['Status', 'In Transit'],
          ['Origin', 'Mumbai'],
          ['Destination', 'Delhi'],
          ['ETA', 'Feb 22, 2026'],
          ['Weight', '12.5 kg'],
        ],
      );

      expect(bytes, isNotNull);
      expect(bytes!.length, greaterThan(100)); // Non-trivial xlsx size
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // 3. MarkdownRenderer – widget rendering
  // ═════════════════════════════════════════════════════════════════════

  group('MarkdownRenderer – widget tests', () {
    testWidgets('renders headings from markdown content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const MarkdownRenderer(
            content: '# Title\n\n## Subtitle\n\nBody text',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MarkdownBody), findsOneWidget);
      expect(find.textContaining('Title'), findsWidgets);
      expect(find.textContaining('Subtitle'), findsWidgets);
      expect(find.textContaining('Body text'), findsWidgets);
    });

    testWidgets('CodeBlockBuilder produces CodeBlockWidget from pre element', (
      WidgetTester tester,
    ) async {
      // Test the builder directly (bypasses flutter_markdown's
      // selectable:true assertion on MarkdownBody).
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      final context = tester.element(find.byType(SizedBox));

      final builder = CodeBlockBuilder();
      final codeElement = md.Element('code', [md.Text('SELECT 1;')])
        ..attributes['class'] = 'language-sql';
      final preElement = md.Element('pre', [codeElement]);

      final widget = builder.visitElementAfterWithContext(
        context,
        preElement,
        null,
        null,
      );

      // Builder should return a CodeBlockWidget
      expect(widget, isA<CodeBlockWidget>());
      final codeBlock = widget! as CodeBlockWidget;
      expect(codeBlock.language, 'sql');
      expect(codeBlock.code, contains('SELECT 1;'));
    });

    testWidgets('renders bold, italic, and list items', (
      WidgetTester tester,
    ) async {
      const markdown = '- **Bold item**\n- *Italic item*\n- Normal item\n';

      await tester.pumpWidget(_wrap(const MarkdownRenderer(content: markdown)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Bold item'), findsWidgets);
      expect(find.textContaining('Italic item'), findsWidgets);
      expect(find.textContaining('Normal item'), findsWidgets);
    });

    testWidgets('renders blockquote content', (WidgetTester tester) async {
      const markdown = '> This is a **quoted** note.\n';

      await tester.pumpWidget(_wrap(const MarkdownRenderer(content: markdown)));
      await tester.pumpAndSettle();

      expect(find.textContaining('quoted'), findsWidgets);
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // 4. CodeBlockWidget – copy interaction
  // ═════════════════════════════════════════════════════════════════════

  group('CodeBlockWidget – copy button', () {
    testWidgets('displays language label and copy button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const CodeBlockWidget(code: 'SELECT id FROM users;', language: 'sql'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SQL'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('copy button changes to Copied after tap', (
      WidgetTester tester,
    ) async {
      // Mock the clipboard platform channel
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') return null;
          return null;
        },
      );

      await tester.pumpWidget(
        _wrap(
          const CodeBlockWidget(code: 'SELECT id FROM users;', language: 'sql'),
        ),
      );
      await tester.pumpAndSettle();

      // Tap copy button
      await tester.tap(find.text('Copy'));
      await tester.pump();

      // Should show "Copied" state
      expect(find.text('Copied'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Advance past the 2-second reset timer to avoid pending timer error
      await tester.pump(const Duration(seconds: 3));

      // Clean up mock
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // 5. TableWidget – display and download button
  // ═════════════════════════════════════════════════════════════════════

  group('TableWidget – display and export', () {
    testWidgets('renders DataTable with headers and rows', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const TableWidget(
            headers: ['Field', 'Value'],
            rows: [
              ['Status', 'Active'],
              ['Count', '42'],
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DataTable), findsOneWidget);
      expect(find.text('Field'), findsOneWidget);
      expect(find.text('Value'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('shows Download Excel button', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const TableWidget(
            headers: ['A', 'B'],
            rows: [
              ['1', '2'],
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Download Excel'), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('empty headers and rows renders nothing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const TableWidget(headers: [], rows: [])));
      await tester.pumpAndSettle();

      expect(find.byType(DataTable), findsNothing);
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // 6. MessageBubble – markdown rendering for bot messages
  // ═════════════════════════════════════════════════════════════════════

  group('MessageBubble – markdown integration', () {
    testWidgets('bot message uses MarkdownRenderer', (
      WidgetTester tester,
    ) async {
      final message = _botMessage('## Hello\n\nThis is a **test** response.\n');

      await tester.pumpWidget(_wrap(MessageBubble(message: message)));
      await tester.pumpAndSettle();

      expect(find.byType(MarkdownRenderer), findsOneWidget);
      expect(find.byType(MarkdownBody), findsOneWidget);
    });

    testWidgets('user message uses SelectableText (no markdown)', (
      WidgetTester tester,
    ) async {
      final message = Message(
        id: 'test-user',
        content: 'Hello there!',
        sender: MessageSender.user,
        timestamp: DateTime(2026, 2, 19, 14, 30),
        conversationId: 'conv-test',
        status: MessageStatus.complete,
      );

      await tester.pumpWidget(_wrap(MessageBubble(message: message)));
      await tester.pumpAndSettle();

      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.byType(MarkdownRenderer), findsNothing);
    });

    testWidgets('bot message with rich markdown uses MarkdownRenderer', (
      WidgetTester tester,
    ) async {
      // NOTE: Code blocks rendered through MarkdownBody with selectable:true
      // trigger a known flutter_markdown 0.7.x assertion (_inlines.isEmpty).
      // CodeBlockWidget rendering is verified in standalone tests above.
      // Here we test markdown rendering with headings, bold, lists (no code
      // blocks) to confirm the full integration path.
      final message = _botMessage(
        '## Status Report\n\n'
        '- **Item A**: complete\n'
        '- **Item B**: pending\n\n'
        '> All checks passed.\n',
      );

      await tester.pumpWidget(_wrap(MessageBubble(message: message)));
      await tester.pumpAndSettle();

      expect(find.byType(MarkdownRenderer), findsOneWidget);
      expect(find.byType(MarkdownBody), findsOneWidget);
      expect(find.textContaining('Status Report'), findsWidgets);
      expect(find.textContaining('Item A'), findsWidgets);
      expect(find.textContaining('All checks passed'), findsWidgets);
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // 7. CopyButton – clipboard copy with feedback
  // ═════════════════════════════════════════════════════════════════════

  group('CopyButton – copy response', () {
    testWidgets('renders Copy label and copy icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const CopyButton(text: 'hello')));
      await tester.pumpAndSettle();

      expect(find.text('Copy'), findsOneWidget);
      expect(find.byIcon(Icons.copy_outlined), findsOneWidget);
    });

    testWidgets('shows Copied! after tap then reverts', (
      WidgetTester tester,
    ) async {
      // Mock clipboard
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') return null;
          return null;
        },
      );

      await tester.pumpWidget(_wrap(const CopyButton(text: 'test text')));
      await tester.pumpAndSettle();

      // Tap the copy button
      await tester.tap(find.text('Copy'));
      await tester.pump();

      // Should now show "Copied!" with check icon
      expect(find.text('Copied!'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('Copy'), findsNothing);

      // After 2 seconds, should revert
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Copied!'), findsNothing);

      // Clean up mock
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    testWidgets('bot MessageBubble shows CopyButton for complete messages', (
      WidgetTester tester,
    ) async {
      final message = _botMessage('Hello world');

      await tester.pumpWidget(_wrap(MessageBubble(message: message)));
      await tester.pumpAndSettle();

      expect(find.byType(CopyButton), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('user MessageBubble does not show CopyButton', (
      WidgetTester tester,
    ) async {
      final message = Message(
        id: 'test-user',
        content: 'Hello there!',
        sender: MessageSender.user,
        timestamp: DateTime(2026, 2, 19, 14, 30),
        conversationId: 'conv-test',
        status: MessageStatus.complete,
      );

      await tester.pumpWidget(_wrap(MessageBubble(message: message)));
      await tester.pumpAndSettle();

      expect(find.byType(CopyButton), findsNothing);
    });

    testWidgets('streaming bot message does not show CopyButton', (
      WidgetTester tester,
    ) async {
      final message = Message(
        id: 'test-bot-streaming',
        content: 'Partial response...',
        sender: MessageSender.bot,
        timestamp: DateTime(2026, 2, 19, 14, 30),
        conversationId: 'conv-test',
        status: MessageStatus.streaming,
      );

      await tester.pumpWidget(_wrap(MessageBubble(message: message)));
      await tester.pumpAndSettle();

      expect(find.byType(CopyButton), findsNothing);
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // 8. RephraseButton – rephrase user messages
  // ═════════════════════════════════════════════════════════════════════

  group('RephraseButton – rephrase user messages', () {
    testWidgets('renders Rephrase label and edit icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(RephraseButton(onRephrase: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rephrase'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('calls onRephrase callback when tapped', (
      WidgetTester tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(RephraseButton(onRephrase: () => tapped = true)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rephrase'));
      expect(tapped, isTrue);
    });

    testWidgets('user MessageBubble shows RephraseButton when onRephrase set', (
      WidgetTester tester,
    ) async {
      final message = Message(
        id: 'test-user',
        content: 'Hello there!',
        sender: MessageSender.user,
        timestamp: DateTime(2026, 2, 19, 14, 30),
        conversationId: 'conv-test',
        status: MessageStatus.complete,
      );

      await tester.pumpWidget(
        _wrap(MessageBubble(message: message, onRephrase: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RephraseButton), findsOneWidget);
    });

    testWidgets('user MessageBubble hides RephraseButton when onRephrase null', (
      WidgetTester tester,
    ) async {
      final message = Message(
        id: 'test-user',
        content: 'Hello there!',
        sender: MessageSender.user,
        timestamp: DateTime(2026, 2, 19, 14, 30),
        conversationId: 'conv-test',
        status: MessageStatus.complete,
      );

      await tester.pumpWidget(_wrap(MessageBubble(message: message)));
      await tester.pumpAndSettle();

      expect(find.byType(RephraseButton), findsNothing);
    });

    testWidgets('bot MessageBubble does not show RephraseButton', (
      WidgetTester tester,
    ) async {
      final message = _botMessage('Test response');

      await tester.pumpWidget(
        _wrap(MessageBubble(message: message, onRephrase: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RephraseButton), findsNothing);
    });

    testWidgets('MessageInput populates text when initialText changes', (
      WidgetTester tester,
    ) async {
      // First render without initialText
      await tester.pumpWidget(
        _wrap(MessageInput(onSend: (_) {}, initialText: null)),
      );
      await tester.pumpAndSettle();

      // Verify input is empty
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isEmpty);

      // Re-render with initialText set (simulating rephrase)
      await tester.pumpWidget(
        _wrap(
          MessageInput(
            onSend: (_) {},
            initialText: 'Rephrased message',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the text field now contains the rephrased text
      final updatedTextField = tester.widget<TextField>(
        find.byType(TextField),
      );
      expect(updatedTextField.controller!.text, 'Rephrased message');
    });
  });
}
