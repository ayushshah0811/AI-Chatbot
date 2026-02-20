import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/chat_provider.dart';

/// Circular new-chat button — placed in AppBar actions.
class NewChatButton extends ConsumerWidget {
  const NewChatButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStreaming = ref.watch(chatProvider.select((s) => s.isStreaming));
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isStreaming
          ? null
          : () => ref.read(chatProvider.notifier).startNewSession(),
      child: Tooltip(
        message: 'New chat',
        child: Container(
          width: 38,
          height: 38,
          decoration: AppTheme.iconContainerDecoration(context),
          child: Icon(
            Icons.edit_square,
            size: 18,
            color: isStreaming
                ? theme.colorScheme.onSurface.withValues(alpha: 0.25)
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
