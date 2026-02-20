import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';

/// Modern stop-generating button — pill shape with surfaceContainerHigh fill.
///
/// Sits cleanly on the gradient background without harsh outlines.
class PauseButton extends StatelessWidget {
  const PauseButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing.xxs),
        child: TextButton.icon(
          onPressed: onPressed,
          icon: Icon(Icons.stop_rounded, size: DesignTokens.iconSize.sm),
          label: const Text('Stop generating'),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            backgroundColor: theme.colorScheme.surfaceContainerHigh.withValues(
              alpha: 0.8,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing.mdLg,
              vertical: DesignTokens.spacing.xs,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: DesignTokens.borderRadius.full,
            ),
            textStyle: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
