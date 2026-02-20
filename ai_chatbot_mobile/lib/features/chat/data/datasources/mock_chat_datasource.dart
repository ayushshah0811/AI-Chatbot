import 'package:flutter/foundation.dart' show visibleForTesting;

import '../../domain/entities/message.dart';
import '../../domain/entities/message_sender.dart';
import '../../domain/entities/message_status.dart';
import '../models/message_dto.dart';

/// Mock data source that simulates the backend API for offline development
/// and testing.
///
/// Activated when `USE_MOCK_DATA=true` is set via `--dart-define`.
/// Simulates streaming with delayed chunks mimicking real SSE behaviour.
class MockChatDataSource {
  MockChatDataSource();

  static const _mockResponses = <String, String>{
    // ── STS LP: exercises headings, tables, bold/italic, lists ──
    'STS_LP':
        '## Shipment Tracking Report\n\n'
        'Based on the **STS LP** system, here is your shipment summary for '
        'tracking number **TRK-2026-0219-4521**.\n\n'
        '### Current Status\n\n'
        'The shipment is currently *in transit* and expected to arrive within '
        '**2-3 business days**.\n\n'
        '| Field | Value |\n'
        '|-------|-------|\n'
        '| Status | In Transit |\n'
        '| Origin | Mumbai |\n'
        '| Destination | Delhi |\n'
        '| ETA | Feb 22, 2026 |\n'
        '| Weight | 12.5 kg |\n\n'
        '### Checkpoint History\n\n'
        '1. **Mumbai Hub** – Dispatched at 06:00 AM\n'
        '2. **Pune Relay** – Cleared at 10:30 AM\n'
        '3. **Nagpur Transit** – In progress\n\n'
        '> **Note**: Delivery times are estimates and may vary due to '
        'weather or traffic conditions.\n\n'
        'Need the raw tracking query? Here it is:\n\n'
        '```sql\n'
        'SELECT shipment_id, status, checkpoint, timestamp\n'
        'FROM shipment_tracking\n'
        'WHERE tracking_no = \'TRK-2026-0219-4521\'\n'
        'ORDER BY timestamp DESC;\n'
        '```\n\n'
        'Is there anything else you would like to know?',

    // ── TMS: exercises code blocks (SQL + JSON), tables, links ──
    'TMS':
        '## Transport Order Details\n\n'
        'The TMS records show the following for customer **CUST-001**:\n\n'
        '```sql\n'
        'SELECT order_id, status, carrier, pickup_date, delivery_date\n'
        'FROM transport_orders\n'
        'WHERE customer_id = \'CUST-001\'\n'
        '  AND status IN (\'confirmed\', \'in_transit\')\n'
        'ORDER BY pickup_date DESC\n'
        'LIMIT 10;\n'
        '```\n\n'
        '### Results\n\n'
        '| Order ID | Status | Carrier | Pickup | Delivery |\n'
        '|----------|--------|---------|--------|----------|\n'
        '| ORD-4401 | Confirmed | Express Logistics | Feb 20 | Feb 23 |\n'
        '| ORD-4398 | In Transit | BlueDart | Feb 18 | Feb 21 |\n'
        '| ORD-4392 | Delivered | DTDC | Feb 15 | Feb 17 |\n\n'
        'The API response payload looks like this:\n\n'
        '```json\n'
        '{\n'
        '  "orderId": "ORD-4401",\n'
        '  "status": "confirmed",\n'
        '  "carrier": {\n'
        '    "name": "Express Logistics",\n'
        '    "code": "EXLOG"\n'
        '  },\n'
        '  "estimatedDelivery": "2026-02-23T18:00:00Z"\n'
        '}\n'
        '```\n\n'
        '---\n\n'
        'For more details, visit the '
        '[TMS Dashboard](https://tms.example.com/orders). '
        'Would you like me to check the delivery schedule?',

    // ── QMS: exercises headings, bullet lists, blockquotes, code ──
    'QMS':
        '# Quality Management Report\n\n'
        'Analysis complete for the latest production batch.\n\n'
        '## Inspection Results\n\n'
        '- **Batch**: QC-2026-0452\n'
        '- **Status**: Passed ✓\n'
        '- **Defect Rate**: 0.02%\n'
        '- **Inspector**: Auto-QC Module v3.1\n'
        '- **Inspection Date**: Feb 19, 2026\n\n'
        '### Detailed Metrics\n\n'
        '| Metric | Value | Threshold | Result |\n'
        '|--------|-------|-----------|--------|\n'
        '| Tensile Strength | 485 MPa | ≥ 450 MPa | PASS |\n'
        '| Surface Finish | 0.8 µm | ≤ 1.2 µm | PASS |\n'
        '| Dimensional Accuracy | 99.97% | ≥ 99.90% | PASS |\n'
        '| Contamination Level | 0.001% | ≤ 0.01% | PASS |\n\n'
        '> All parameters are within acceptable limits. '
        'No corrective actions required.\n\n'
        'The inspection was performed using this configuration:\n\n'
        '```sql\n'
        'SELECT batch_id, metric_name, measured_value, threshold\n'
        'FROM quality_inspections\n'
        'WHERE batch_id = \'QC-2026-0452\'\n'
        '  AND result = \'PASS\';\n'
        '```\n\n'
        '---\n\n'
        'For historical trends, review the '
        '[QMS Analytics Portal](https://qms.example.com/analytics).',
  };

  static const _defaultResponse =
      '## Response Summary\n\n'
      'I received your message and am processing it. '
      'This is a **mock response** for testing purposes.\n\n'
      '### Features Demonstrated\n\n'
      '- **Streaming simulation** – chunked delivery\n'
      '- **Markdown rendering** – headings, lists, emphasis\n'
      '- **Code blocks** – syntax-highlighted with copy\n'
      '- **Tables** – scrollable with Excel export\n\n'
      '> This response showcases all *rich content* capabilities.\n\n'
      'Here is a sample code block:\n\n'
      '```dart\n'
      'void main() {\n'
      '  final greeting = \'Hello from mock!\';\n'
      '  print(greeting);\n'
      '}\n'
      '```\n\n'
      '| Feature | Status |\n'
      '|---------|--------|\n'
      '| Markdown | Active |\n'
      '| Code Blocks | Active |\n'
      '| Tables | Active |\n';

  /// Returns the full mock response for a given [targetApp].
  ///
  /// Exposed for unit tests that need to validate response content
  /// without going through the streaming interface (which uses timers
  /// incompatible with Flutter's FakeAsync test zone).
  @visibleForTesting
  static String responseForTargetApp(String targetApp) =>
      _mockResponses[targetApp] ?? _defaultResponse;

  /// Sends a message and returns the complete response.
  ///
  /// Returns the full mock response after a simulated processing delay.
  /// The response content varies based on [messageDto.targetApp].
  // NOTE: SSE streaming variant commented out — kept for future reference.
  // Stream<String> sendMessageStream({required MessageDto messageDto}) async* { ... }
  Future<String> sendMessage({required MessageDto messageDto}) async {
    // Simulate server processing delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return _mockResponses[messageDto.targetApp] ?? _defaultResponse;
  }

  /// Returns mock chat history.
  ///
  /// Returns a realistic conversation with user + bot message pairs
  /// in chronological order, simulating a previously persisted session.
  Future<List<Message>> loadHistory({required String userId}) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    const convId = 'mock-conv-001';

    return [
      Message(
        id: 'hist-001',
        content: 'What is the status of my shipment?',
        sender: MessageSender.user,
        timestamp: now.subtract(const Duration(minutes: 10)),
        conversationId: convId,
        status: MessageStatus.complete,
      ),
      Message(
        id: 'hist-002',
        content:
            '## Shipment Status\n\n'
            'Your shipment **TRK-2026-0218-3312** is currently *in transit* '
            'from Mumbai to Delhi.\n\n'
            '| Field | Value |\n'
            '|-------|-------|\n'
            '| Status | In Transit |\n'
            '| Origin | Mumbai |\n'
            '| Destination | Delhi |\n'
            '| ETA | Feb 21, 2026 |\n'
            '| Weight | 8.2 kg |\n\n'
            '> Estimated delivery is subject to weather conditions.\n\n'
            'Would you like more details?',
        sender: MessageSender.bot,
        timestamp: now.subtract(const Duration(minutes: 9, seconds: 45)),
        conversationId: convId,
        status: MessageStatus.complete,
        responseTimeMs: 2350,
      ),
      Message(
        id: 'hist-003',
        content: 'Show me the carrier details.',
        sender: MessageSender.user,
        timestamp: now.subtract(const Duration(minutes: 7)),
        conversationId: convId,
        status: MessageStatus.complete,
      ),
      Message(
        id: 'hist-004',
        content:
            '### Carrier Details\n\n'
            'Here are the carrier details for your shipment:\n\n'
            '- **Carrier**: Express Logistics\n'
            '- **Vehicle**: MH-12-AB-1234\n'
            '- **Driver**: Rajesh Kumar\n'
            '- **Contact**: +91-98765-43210\n\n'
            'The shipment passed the Pune checkpoint at 08:30 AM today.\n\n'
            '```sql\n'
            'SELECT carrier_name, vehicle_no, driver_name\n'
            'FROM carrier_assignments\n'
            'WHERE shipment_id = \'TRK-2026-0218-3312\';\n'
            '```',
        sender: MessageSender.bot,
        timestamp: now.subtract(const Duration(minutes: 6, seconds: 30)),
        conversationId: convId,
        status: MessageStatus.complete,
        responseTimeMs: 1820,
      ),
    ];
  }
}
