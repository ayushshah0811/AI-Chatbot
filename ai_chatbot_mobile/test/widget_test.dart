import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chatbot_mobile/main.dart';

void main() {
  testWidgets('App renders chat screen shell', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AiChatbotApp());
    await tester.pumpAndSettle();

    // Verify the app bar shows the app name.
    expect(find.text('AI Chatbot'), findsOneWidget);

    // Verify the placeholder body text is shown.
    expect(find.text('Chat messages will appear here'), findsOneWidget);
  });
}
