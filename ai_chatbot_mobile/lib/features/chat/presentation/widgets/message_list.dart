import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_sender.dart';
import '../../domain/entities/message_status.dart';
import 'message_bubble.dart';
import 'response_time_indicator.dart';

/// Scrollable list of chat messages with auto-scroll and entrance animations.
class MessageList extends StatefulWidget {
  const MessageList({required this.messages, this.onRephrase, super.key});

  final List<Message> messages;
  final ValueChanged<String>? onRephrase;

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();
  static const _autoScrollThreshold = 150.0;
  bool _isFirstLoad = true;

  /// Track IDs of messages that have already been animated in.
  final Set<String> _animatedMessageIds = {};

  @override
  void didUpdateWidget(covariant MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_isFirstLoad &&
        oldWidget.messages.isEmpty &&
        widget.messages.isNotEmpty) {
      _isFirstLoad = false;
      for (final m in widget.messages) {
        _animatedMessageIds.add(m.id);
      }
      _jumpToBottom();
      return;
    }

    if (_shouldAutoScroll(oldWidget)) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _shouldAutoScroll(MessageList oldWidget) {
    if (widget.messages.length != oldWidget.messages.length) {
      return _isNearBottom;
    }
    if (widget.messages.isNotEmpty && oldWidget.messages.isNotEmpty) {
      final last = widget.messages.last;
      final oldLast = oldWidget.messages.last;
      if (last.id == oldLast.id && last.content != oldLast.content) {
        return _isNearBottom;
      }
    }
    return false;
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return true;
    final position = _scrollController.position;
    return position.maxScrollExtent - position.pixels < _autoScrollThreshold;
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: DesignTokens.animation.normal,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing.md),
      itemCount: widget.messages.length,
        separatorBuilder: (context, index) =>
          SizedBox(height: DesignTokens.chat.messageSpacing),
      findItemIndexCallback: (key) {
        if (key is ValueKey<String>) {
          final index = widget.messages.indexWhere((m) => m.id == key.value);
          return index >= 0 ? index : null;
        }
        return null;
      },
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        final isNew = !_animatedMessageIds.contains(message.id);

        _animatedMessageIds.add(message.id);

        Widget child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MessageBubble(
              key: ValueKey(message.id),
              message: message,
              onRephrase:
                  message.sender == MessageSender.user &&
                      message.status == MessageStatus.complete &&
                      widget.onRephrase != null
                  ? () => widget.onRephrase!(message.content)
                  : null,
            ),
            if (message.sender == MessageSender.bot &&
                message.status == MessageStatus.complete &&
                message.responseTimeMs != null)
              ResponseTimeIndicator(responseTimeMs: message.responseTimeMs!),
          ],
        );

        // Animate only new messages.
        if (isNew) {
          final isUser = message.sender == MessageSender.user;
          child = child
              .animate()
              .fadeIn(
                duration: DesignTokens.animation.normal,
                curve: DesignTokens.animation.entranceCurve,
              )
              .slideY(
                begin: 0.12,
                end: 0,
                duration: DesignTokens.animation.normal,
                curve: DesignTokens.animation.entranceCurve,
              )
              .slideX(
                begin: isUser ? 0.04 : -0.04,
                end: 0,
                duration: DesignTokens.animation.normal,
                curve: DesignTokens.animation.entranceCurve,
              );
        }

        return child;
      },
    );
  }
}

/// Premium empty state — AI-branded welcome screen with gradient accent.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(DesignTokens.spacing.xxl),
        child:
            Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Robot logo with gradient ring.
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.accentGradient,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(2.5),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/Image.jpg',
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: DesignTokens.spacing.lg),
                    Text(
                      'How can I help you?',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: DesignTokens.spacing.xs),
                    Text(
                      'Ask me anything — I can help with code,\nanalysis, writing, and more.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.45,
                        ),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: DesignTokens.spacing.lg),
                    // Subtle sparkle icon
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 20,
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .slideY(
                  begin: 0.08,
                  end: 0,
                  duration: 600.ms,
                  curve: Curves.easeOut,
                ),
      ),
    );
  }
}
