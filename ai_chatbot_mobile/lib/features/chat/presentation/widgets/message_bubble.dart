import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_sender.dart';
import '../../domain/entities/message_status.dart';
import 'copy_button.dart';
import 'inline_thinking_dots.dart';
import 'markdown_renderer.dart';
import 'rephrase_button.dart';

/// Modern 2026 chat bubble with 26px rounded corners, 16px internal padding,
/// and proper Material 3 surface hierarchy.
///
/// User: right-aligned, primaryContainer fill.
/// Bot: left-aligned, surfaceContainerHigh fill with AI avatar.
class MessageBubble extends StatelessWidget {
  const MessageBubble({required this.message, this.onRephrase, super.key});

  final Message message;
  final VoidCallback? onRephrase;

  bool get _isUser => message.sender == MessageSender.user;

  @override
  Widget build(BuildContext context) {
    return _isUser ? _buildUserBubble(context) : _buildBotBubble(context);
  }

  /// User message: right-aligned, primaryContainer bubble.
  Widget _buildUserBubble(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.sizeOf(context).width *
              DesignTokens.chat.maxBubbleWidthFraction,
        ),
        child: Container(
          margin: EdgeInsets.only(
            left: DesignTokens.spacing.xxl,
            right: DesignTokens.spacing.md,
          ),
          padding: DesignTokens.chat.bubblePadding,
          decoration: BoxDecoration(
            color: AppTheme.userBubbleColor(context),
            borderRadius: DesignTokens.chat.userBubbleRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.userBubbleTextColor(context),
                  height: 1.5,
                ),
              ),
              SizedBox(height: DesignTokens.spacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onRephrase != null &&
                      message.status == MessageStatus.complete)
                    Padding(
                      padding: EdgeInsets.only(right: DesignTokens.spacing.xs),
                      child: RephraseButton(onRephrase: onRephrase!),
                    ),
                  _StatusChip(message: message),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bot message: left-aligned, surfaceContainerHigh bubble with avatar.
  Widget _buildBotBubble(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.sizeOf(context).width *
              DesignTokens.chat.maxBubbleWidthFraction,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: DesignTokens.spacing.md,
            right: DesignTokens.spacing.xxl,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── AI avatar ──
              Container(
                width: 32,
                height: 32,
                margin: EdgeInsets.only(top: DesignTokens.spacing.xxs),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/Image.jpg',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: DesignTokens.spacing.sm),

              // ── Bubble ──
              Flexible(
                child: Container(
                  padding: DesignTokens.chat.bubblePadding,
                  decoration: BoxDecoration(
                    color: AppTheme.botBubbleColor(context),
                    borderRadius: DesignTokens.chat.botBubbleRadius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Show inline thinking dots when waiting for response
                      if (message.content.isEmpty &&
                          (message.status == MessageStatus.sending ||
                              message.status == MessageStatus.streaming))
                        const InlineThinkingDots(),
                      if (message.content.isNotEmpty)
                        MarkdownRenderer(
                          content: message.content,
                          textColor: AppTheme.botBubbleTextColor(context),
                        ),
                      if (message.content.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(
                            top: DesignTokens.spacing.xs,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (message.status == MessageStatus.complete)
                                CopyButton(text: message.content),
                              const Spacer(),
                              _StatusChip(message: message),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact metadata chip — timestamp + status icon.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.55);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(message.timestamp),
          style: theme.textTheme.labelSmall?.copyWith(
            color: muted,
            fontSize: DesignTokens.typography.caption,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(width: DesignTokens.spacing.xxs),
        _statusIcon(muted, theme),
      ],
    );
  }

  Widget _statusIcon(Color muted, ThemeData theme) {
    const size = 12.0;
    switch (message.status) {
      case MessageStatus.sending:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 1.2,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
        );
      case MessageStatus.streaming:
        return Icon(
          Icons.more_horiz_rounded,
          size: size,
          color: theme.colorScheme.primary,
        );
      case MessageStatus.complete:
        return Icon(Icons.check_rounded, size: size, color: muted);
      case MessageStatus.stopped:
        return Icon(
          Icons.stop_circle_outlined,
          size: size,
          color: theme.colorScheme.tertiary.withValues(alpha: 0.7),
        );
      case MessageStatus.error:
        return Icon(
          Icons.error_outline_rounded,
          size: size,
          color: theme.colorScheme.error,
        );
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
