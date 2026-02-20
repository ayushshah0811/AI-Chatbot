import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';

/// Modern typing indicator — circular gradient avatar + pulsing dots.
///
/// Matches the bot message layout with AI avatar on the left for consistency.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({this.label = 'Thinking', super.key});

  final String label;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing.md,
        vertical: DesignTokens.spacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI avatar (robot logo, matches bot bubble)
          SizedBox(
            width: 32,
            height: 32,
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

          // Label + animated dots
          Text(
            widget.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(width: DesignTokens.spacing.xxs),

          // Animated dots
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  final delay = index * 0.25;
                  final value = ((_controller.value + delay) % 1.0).clamp(
                    0.0,
                    1.0,
                  );
                  final bounce = _bounce(value);

                  return Transform.translate(
                    offset: Offset(0, -2.5 * bounce),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing.xxxs,
                      ),
                      child: Container(
                        width: 5.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.25 + 0.5 * bounce,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  double _bounce(double t) {
    if (t < 0.5) return t * 2;
    return 2 - t * 2;
  }
}
