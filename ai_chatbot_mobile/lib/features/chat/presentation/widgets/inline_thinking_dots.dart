import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';

/// Compact animated thinking dots displayed inside a bot bubble
/// while waiting for the response.
class InlineThinkingDots extends StatefulWidget {
  const InlineThinkingDots({super.key});

  @override
  State<InlineThinkingDots> createState() => _InlineThinkingDotsState();
}

class _InlineThinkingDotsState extends State<InlineThinkingDots>
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
      padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing.xxs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 13,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          SizedBox(width: DesignTokens.spacing.xxs),
          Text(
            'Thinking',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: DesignTokens.spacing.xs),
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
                            alpha: 0.3 + 0.5 * bounce,
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
