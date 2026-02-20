import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';

/// Subtle response time chip — minimal and elegant.
class ResponseTimeIndicator extends StatelessWidget {
  const ResponseTimeIndicator({required this.responseTimeMs, super.key});

  final int responseTimeMs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seconds = responseTimeMs / 1000.0;
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.3);

    return Padding(
      padding: EdgeInsets.only(
        left: DesignTokens.spacing.md,
        bottom: DesignTokens.spacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bolt_rounded,
            size: DesignTokens.iconSize.xs,
            color: muted,
          ),
          SizedBox(width: DesignTokens.spacing.xxxs),
          Text(
            'Answered in ${seconds.toStringAsFixed(1)}s',
            style: theme.textTheme.labelSmall?.copyWith(
              color: muted,
              fontSize: 11,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
