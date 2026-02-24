import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
// import '../providers/chat_provider.dart'; // Disabled — new chat functionality removed

/// Circular new-chat button — placed in AppBar actions.
/// Currently disabled with no tap handler.
class NewChatButton extends ConsumerWidget {
  const NewChatButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final isStreaming = ref.watch(chatProvider.select((s) => s.isStreaming));
    final theme = Theme.of(context);

    return GestureDetector(
      // onTap disabled — new chat functionality removed
      onTap: null,
      child: Tooltip(
        message: 'New chat',
        child: Container(
          width: 38,
          height: 38,
          decoration: AppTheme.iconContainerDecoration(context),
          child: Icon(
            Icons.add_comment_rounded,
            size: 18,
            // Always show disabled appearance
            color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }
}
