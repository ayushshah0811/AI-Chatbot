import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';

/// Modern error display — subtle inline banner with soft error styling.
class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({
    this.message = 'Something went wrong. Please try again.',
    this.onRetry,
    this.onDismiss,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing.md,
        vertical: DesignTokens.spacing.xs,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing.md,
        vertical: DesignTokens.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: DesignTokens.borderRadius.md,
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: DesignTokens.iconSize.md,
            color: theme.colorScheme.error.withValues(alpha: 0.8),
          ),
          SizedBox(width: DesignTokens.spacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(width: DesignTokens.spacing.xs),
            TextButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded, size: DesignTokens.iconSize.sm),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                padding: EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing.sm,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
          if (onDismiss != null) ...[
            SizedBox(width: DesignTokens.spacing.xxs),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close_rounded),
              iconSize: DesignTokens.iconSize.sm,
              color: theme.colorScheme.onErrorContainer.withValues(alpha: 0.6),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Dismiss',
            ),
          ],
        ],
      ),
    );
  }
}
