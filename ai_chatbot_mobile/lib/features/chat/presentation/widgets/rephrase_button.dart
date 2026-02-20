import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';

/// Minimal rephrase button — pencil icon only, no text label.
class RephraseButton extends StatelessWidget {
  const RephraseButton({required this.onRephrase, super.key});

  final VoidCallback onRephrase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return InkWell(
      onTap: onRephrase,
      borderRadius: DesignTokens.borderRadius.sm,
      child: Padding(
        padding: EdgeInsets.all(DesignTokens.spacing.xxs),
        child: Icon(
          Icons.edit_rounded,
          size: DesignTokens.iconSize.sm,
          color: color,
        ),
      ),
    );
  }
}
