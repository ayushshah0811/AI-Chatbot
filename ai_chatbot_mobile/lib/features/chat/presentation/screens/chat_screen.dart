import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_tokens.dart';
import '../providers/chat_provider.dart';
import '../providers/chat_state.dart';
import '../providers/session_provider.dart';
import '../widgets/error_display.dart';
import '../widgets/message_input.dart';
import '../widgets/message_list.dart';
import '../widgets/new_chat_button.dart';
import '../widgets/pause_button.dart';
import '../widgets/restart_button.dart';
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
          // ── Leading: Robot logo icon (tap for logout menu) ──
          leading: Padding(
            padding: EdgeInsets.only(left: DesignTokens.spacing.sm),
            child: Center(
              child: PopupMenuButton<String>(
                tooltip: 'Account menu',
                position: PopupMenuPosition.under,
                offset: const Offset(0, 8),
                shape: RoundedRectangleBorder(
                  borderRadius: DesignTokens.borderRadius.lg,
                ),
                onSelected: (value) async {
                  if (value == 'logout') {
                    // Invalidate chat provider and clear session, navigate to login
                    ref.invalidate(chatProvider);
                    await ref.read(sessionProvider.notifier).logout();
                    if (context.mounted) context.go(AppRoutes.login);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: theme.colorScheme.error,
                        ),
                        SizedBox(width: DesignTokens.spacing.sm),
                        Text(
                          'Logout',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.accentGradient,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(1.5),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/Image.jpg',
                      width: 35,
                      height: 35,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Center: Target App selector ──
          title: const TargetAppSelector(),
          centerTitle: true,

          // ── Trailing: Restart + New Chat buttons ──
          actions: [
            const RestartButton(),
            SizedBox(width: DesignTokens.spacing.xs),
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
