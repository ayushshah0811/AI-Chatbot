import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/chat_provider.dart';

/// Circular restart button — placed in AppBar actions beside the new-chat
/// button. Shows a confirmation dialog before deleting all messages.
class RestartButton extends ConsumerWidget {
  const RestartButton({super.key});

  Future<void> _confirmRestart(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restart Session'),
        content: const Text(
          'Do you want to restart this session? All your queries will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref.read(chatProvider.notifier).restartSession();
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to restart session')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStreaming = ref.watch(chatProvider.select((s) => s.isStreaming));
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isStreaming ? null : () => _confirmRestart(context, ref),
      child: Tooltip(
        message: 'Restart session',
        child: Container(
          width: 38,
          height: 38,
          decoration: AppTheme.iconContainerDecoration(context),
          child: Icon(
            Icons.refresh_rounded,
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
