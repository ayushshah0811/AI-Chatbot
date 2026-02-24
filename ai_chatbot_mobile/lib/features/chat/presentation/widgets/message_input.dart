import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_tokens.dart';

/// Premium floating input bar with gradient send button.
///
/// Uses surfaceContainer color with subtle border. The send button
/// transitions from muted to a vibrant gradient glow when text is entered.
class MessageInput extends StatefulWidget {
  const MessageInput({
    required this.onSend,
    this.enabled = true,
    this.initialText,
    super.key,
  });

  final ValueChanged<String> onSend;
  final bool enabled;
  final String? initialText;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _sendButtonAnim;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() => setState(() {}));
    _controller.addListener(_onTextChanged);
    _sendButtonAnim = AnimationController(
      vsync: this,
      duration: DesignTokens.animation.fast,
    );
  }

  @override
  void didUpdateWidget(covariant MessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != null &&
        widget.initialText != oldWidget.initialText) {
      _controller.text = widget.initialText!;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(() {});
    _controller.dispose();
    _focusNode.dispose();
    _sendButtonAnim.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
      if (hasText) {
        _sendButtonAnim.forward();
      } else {
        _sendButtonAnim.reverse();
      }
    }
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;

    widget.onSend(text);
    _controller.clear();
    // Re-request focus after a frame to avoid the Flutter web DOM
    // assertion ("The DOM element of this text editing strategy is
    // not currently active.") that occurs when the widget tree
    // rebuilds while the field still holds focus.
    _focusNode.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  bool get _canSend => widget.enabled && _hasText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing.md,
        vertical: DesignTokens.spacing.sm,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── Text field with 30px radius, surfaceContainer fill ──
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? theme.colorScheme.primary.withValues(alpha: 0.3)
                        : theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                    width: _focusNode.hasFocus ? 1.0 : 0.5,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  decoration: InputDecoration(
                    hintText: widget.enabled
                        ? 'Type a message...'
                        : 'Waiting for response...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacing.lg,
                      vertical: DesignTokens.spacing.md,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                  onSubmitted: (_) => _submit(),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'^\s+$')),
                  ],
                ),
              ),
            ),

            SizedBox(width: DesignTokens.spacing.sm),

            // ── Floating gradient send button ──
            AnimatedBuilder(
              animation: _sendButtonAnim,
              builder: (context, child) {
                final progress = _sendButtonAnim.value;

                return Padding(
                  padding: EdgeInsets.only(bottom: DesignTokens.spacing.xxs),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _canSend ? AppTheme.accentGradient : null,
                      color: _canSend
                          ? null
                          : theme.colorScheme.surfaceContainerHigh,
                      boxShadow: _canSend
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.35 * progress,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _canSend ? _submit : null,
                        customBorder: const CircleBorder(),
                        child: Center(
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            color: _canSend
                                ? Colors.white
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.3,
                                  ),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
