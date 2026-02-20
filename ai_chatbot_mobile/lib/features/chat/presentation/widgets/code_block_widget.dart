import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/utils/clipboard_utils.dart';

/// Premium code block widget — Catppuccin-inspired dark with rounded corners.
///
/// Features a subtle header with language chip, copy button, and
/// syntax-highlighted code with comfortable padding.
class CodeBlockWidget extends StatefulWidget {
  const CodeBlockWidget({
    required this.code,
    required this.language,
    super.key,
  });

  final String code;
  final String language;

  @override
  State<CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<CodeBlockWidget> {
  bool _copied = false;

  Future<void> _handleCopy() async {
    final ok = await ClipboardUtils.copyToClipboard(widget.code);
    if (!ok || !mounted) return;

    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = AppTheme.codeBlockColor(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: DesignTokens.spacing.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: DesignTokens.borderRadius.md,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──
          _CodeHeader(
            language: widget.language,
            copied: _copied,
            onCopy: _handleCopy,
          ),

          // ── Code ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(
              left: DesignTokens.spacing.md,
              right: DesignTokens.spacing.md,
              bottom: DesignTokens.spacing.md,
              top: DesignTokens.spacing.xs,
            ),
            child: HighlightView(
              widget.code.trimRight(),
              language: widget.language,
              theme: vs2015Theme,
              textStyle: TextStyle(
                fontFamily: 'monospace',
                fontSize: DesignTokens.typography.bodySmall,
                height: 1.6,
                color: AppTheme.codeBlockTextColor(context),
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sleek header with language chip and copy button.
class _CodeHeader extends StatelessWidget {
  const _CodeHeader({
    required this.language,
    required this.copied,
    required this.onCopy,
  });

  final String language;
  final bool copied;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing.md,
        vertical: DesignTokens.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.only(
          topLeft: DesignTokens.borderRadius.md.topLeft,
          topRight: DesignTokens.borderRadius.md.topRight,
        ),
      ),
      child: Row(
        children: [
          // Language chip
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing.xs,
                vertical: DesignTokens.spacing.xxxs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: DesignTokens.borderRadius.xs,
              ),
              child: Text(
                language.toLowerCase(),
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF89B4FA), // Catppuccin blue
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          SizedBox(width: DesignTokens.spacing.xs),

          // Copy button
          InkWell(
            onTap: copied ? null : onCopy,
            borderRadius: DesignTokens.borderRadius.xs,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing.xs,
                vertical: DesignTokens.spacing.xxs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    copied ? Icons.check_rounded : Icons.copy_rounded,
                    size: DesignTokens.iconSize.xs,
                    color: copied
                        ? const Color(0xFFA6E3A1) // Catppuccin green
                        : Colors.white54,
                  ),
                  SizedBox(width: DesignTokens.spacing.xxs),
                  Text(
                    copied ? 'Copied!' : 'Copy',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: copied ? const Color(0xFFA6E3A1) : Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
