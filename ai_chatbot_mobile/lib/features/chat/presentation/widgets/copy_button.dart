import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/utils/clipboard_utils.dart';

/// Modern copy button — subtle, minimal with animated feedback.
class CopyButton extends StatefulWidget {
  const CopyButton({required this.text, super.key});

  final String text;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _copied = false;

  Future<void> _handleCopy() async {
    final ok = await ClipboardUtils.copyToClipboard(widget.text);
    if (!ok || !mounted) return;

    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.55);
    final successColor = theme.colorScheme.primary;

    return InkWell(
      onTap: _copied ? null : _handleCopy,
      borderRadius: DesignTokens.borderRadius.sm,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing.xs,
          vertical: DesignTokens.spacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _copied ? Icons.check_rounded : Icons.content_copy_rounded,
              size: DesignTokens.iconSize.sm,
              color: _copied ? successColor : muted,
            ),
            SizedBox(width: DesignTokens.spacing.xxs),
            Text(
              _copied ? 'Copied!' : 'Copy',
              style: theme.textTheme.labelSmall?.copyWith(
                color: _copied ? successColor : muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
