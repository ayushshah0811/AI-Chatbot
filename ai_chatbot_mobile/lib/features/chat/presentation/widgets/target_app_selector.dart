import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/target_app.dart';
import '../providers/chat_provider.dart';

/// Centered target app selector — displayed as AppBar title.
///
/// Shows the selected app name with a dropdown chevron. Tapping opens
/// a popup menu to switch the target application.
class TargetAppSelector extends ConsumerWidget {
  const TargetAppSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final selectedApp = chatState.selectedTargetApp;
    final isStreaming = chatState.isStreaming;

    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      tooltip: 'Switch target application',
      enabled: !isStreaming,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: DesignTokens.borderRadius.lg),
      offset: const Offset(0, 8),
      onSelected: (appId) {
        if (appId == selectedApp.id) return;

        final config = AppConstants.targetApps.firstWhere((a) => a.id == appId);

        ref
            .read(chatProvider.notifier)
            .setTargetApp(
              TargetApp(id: config.id, displayName: config.displayName),
            );
      },
      itemBuilder: (context) {
        return AppConstants.targetApps.map((app) {
          final isSelected = app.id == selectedApp.id;

          return PopupMenuItem<String>(
            value: app.id,
            child: Row(
              children: [
                AnimatedContainer(
                  duration: DesignTokens.animation.fast,
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
                SizedBox(width: DesignTokens.spacing.sm),
                Text(
                  app.displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing.md,
          vertical: DesignTokens.spacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          borderRadius: DesignTokens.borderRadius.full,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                selectedApp.displayName,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: isStreaming
                      ? theme.colorScheme.primary.withValues(alpha: 0.35)
                      : theme.colorScheme.primary,
                ),
              ),
            ),
            SizedBox(width: DesignTokens.spacing.xxs),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: isStreaming
                  ? theme.colorScheme.primary.withValues(alpha: 0.25)
                  : theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
