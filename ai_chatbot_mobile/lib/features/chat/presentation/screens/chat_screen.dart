import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_tokens.dart';
import '../providers/chat_provider.dart';
import '../providers/chat_state.dart';
import '../widgets/error_display.dart';
import '../widgets/message_input.dart';
import '../widgets/message_list.dart';
import '../widgets/new_chat_button.dart';
import '../widgets/pause_button.dart';
import '../widgets/target_app_selector.dart';

/// Main chat screen — the app's primary interface.
///
/// Uses a soft vertical gradient background with a transparent scaffold
/// and AppBar. Layout: AI icon (left) → Target App (center) → New Chat (right).
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final chatNotifier = ref.read(chatProvider.notifier);
    final theme = Theme.of(context);

    // Clear rephraseText after the UI has consumed it (next frame)
    ref.listen<ChatState>(chatProvider, (prev, next) {
      if (next.rephraseText != null &&
          prev?.rephraseText != next.rephraseText) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          chatNotifier.clearRephraseText();
        });
      }
    });

    final messages = chatState.activeConversation?.messages ?? [];

    return Container(
      decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(context)),
      child: Scaffold(
        // Transparent — gradient shows through.
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          // ── Leading: Robot logo icon ──
          leading: Padding(
            padding: EdgeInsets.only(left: DesignTokens.spacing.sm),
            child: Center(
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/Image.jpg',
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // ── Center: Target App selector ──
          title: const TargetAppSelector(),
          centerTitle: true,

          // ── Trailing: New Chat button in circular container ──
          actions: [
            Padding(
              padding: EdgeInsets.only(right: DesignTokens.spacing.sm),
              child: const NewChatButton(),
            ),
          ],
        ),
        body: Column(
          children: [
            // ── Message list ──
            Expanded(
              child: MessageList(
                messages: messages,
                onRephrase: (text) => chatNotifier.rephrase(text),
              ),
            ),

            // ── Stop generating ──
            if (chatState.isStreaming)
              PauseButton(onPressed: chatNotifier.stopGenerating),

            // ── Error display ──
            if (chatState.errorMessage != null)
              ErrorDisplay(
                message: chatState.errorMessage!,
                onRetry: chatState.lastFailedMessage != null
                    ? () => chatNotifier.retryLastMessage()
                    : null,
                onDismiss: chatNotifier.clearError,
              ),

            // ── Message input ──
            MessageInput(
              enabled: chatState.isSendEnabled,
              initialText: chatState.rephraseText,
              onSend: (text) => chatNotifier.sendMessage(text),
            ),
          ],
        ),
      ),
    );
  }
}
