import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/design_tokens.dart';
import 'code_block_builder.dart';

/// Renders markdown content with custom support for code blocks and tables.
///
/// Uses [MarkdownBody] from `flutter_markdown` with:
/// - [CodeBlockBuilder] for syntax-highlighted, copyable code blocks
/// - Styled table rendering via [MarkdownStyleSheet] with horizontal scroll
/// - Tappable links via `url_launcher`
/// - Selectable text for easy copying
///
/// Usage:
/// ```dart
/// MarkdownRenderer(content: '# Hello\n\nSome **bold** text')
/// ```
class MarkdownRenderer extends StatelessWidget {
  const MarkdownRenderer({required this.content, this.textColor, super.key});

  /// The raw markdown string to render.
  final String content;

  /// Optional override for the base text color.
  /// If null, uses the current theme's [ColorScheme.onSurface].
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseTextColor = textColor ?? theme.colorScheme.onSurface;

    // Wrap MarkdownBody in a builder that catches rendering errors and
    // falls back to plain text. This guards against malformed markdown
    // or unexpected flutter_markdown exceptions.
    return _SafeMarkdown(
      content: content,
      textColor: baseTextColor,
      theme: theme,
      styleSheet: _buildStyleSheet(theme, baseTextColor),
    );
  }

  /// Builds a themed [MarkdownStyleSheet] that styles headings, paragraphs,
  /// inline code, tables, blockquotes, and horizontal rules.
  MarkdownStyleSheet _buildStyleSheet(ThemeData theme, Color textColor) {
    final codeInlineBg = theme.brightness == Brightness.light
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surfaceContainerHigh;

    return MarkdownStyleSheet(
      // ── Paragraphs ──
      p: theme.textTheme.bodyMedium?.copyWith(color: textColor, height: 1.5),
      pPadding: EdgeInsets.only(bottom: DesignTokens.spacing.xs),

      // ── Headings ──
      h1: theme.textTheme.titleLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
      h1Padding: EdgeInsets.only(
        top: DesignTokens.spacing.md,
        bottom: DesignTokens.spacing.xs,
      ),
      h2: theme.textTheme.titleMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      h2Padding: EdgeInsets.only(
        top: DesignTokens.spacing.sm,
        bottom: DesignTokens.spacing.xs,
      ),
      h3: theme.textTheme.titleSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      h3Padding: EdgeInsets.only(
        top: DesignTokens.spacing.xs,
        bottom: DesignTokens.spacing.xxs,
      ),

      // ── Inline code ──
      code: theme.textTheme.bodySmall?.copyWith(
        fontFamily: 'monospace',
        color: theme.colorScheme.primary,
        backgroundColor: codeInlineBg,
        fontSize: 13,
      ),
      codeblockPadding: EdgeInsets.zero,
      // Transparent decoration so custom CodeBlockBuilder is not double-wrapped
      codeblockDecoration: const BoxDecoration(),

      // ── Links ──
      a: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.primary,
        decoration: TextDecoration.underline,
        decorationColor: theme.colorScheme.primary,
      ),

      // ── Bold / Italic ──
      strong: theme.textTheme.bodyMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
      em: theme.textTheme.bodyMedium?.copyWith(
        color: textColor,
        fontStyle: FontStyle.italic,
      ),

      // ── Lists ──
      listBullet: theme.textTheme.bodyMedium?.copyWith(color: textColor),
      listBulletPadding: EdgeInsets.only(right: DesignTokens.spacing.xs),
      listIndent: DesignTokens.spacing.lg,

      // ── Blockquotes ──
      blockquote: theme.textTheme.bodyMedium?.copyWith(
        color: textColor.withValues(alpha: 0.6),
        fontStyle: FontStyle.italic,
        height: 1.5,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            width: 2.5,
          ),
        ),
      ),
      blockquotePadding: EdgeInsets.only(
        left: DesignTokens.spacing.sm,
        top: DesignTokens.spacing.xs,
        bottom: DesignTokens.spacing.xs,
      ),

      // ── Tables ──
      tableHead: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: textColor,
        fontSize: 12,
      ),
      tableBody: theme.textTheme.bodySmall?.copyWith(
        color: textColor.withValues(alpha: 0.85),
        fontSize: 12,
      ),
      tableHeadAlign: TextAlign.left,
      tableBorder: TableBorder.all(
        color: theme.colorScheme.outlineVariant,
        width: 0.5,
      ),
      // IntrinsicColumnWidth enables horizontal scroll in flutter_markdown
      tableColumnWidth: const IntrinsicColumnWidth(),
      tableCellsPadding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing.sm,
        vertical: DesignTokens.spacing.xs,
      ),
      tableCellsDecoration: const BoxDecoration(),

      // ── Horizontal rules ──
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.0),
        ),
      ),
    );
  }

  /// Opens a URL in the default browser when a link is tapped.
  static void _handleLinkTap(String text, String? href, String title) {
    if (href == null || href.isEmpty) return;

    final uri = Uri.tryParse(href);
    if (uri == null) return;

    launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Renders [MarkdownBody] inside an [ErrorWidget]-style fallback.
///
/// If `flutter_markdown` throws during build (e.g. malformed markup or an
/// internal assertion), this widget catches the error and renders the raw
/// content as plain selectable text so the user never sees a red-screen.
class _SafeMarkdown extends StatelessWidget {
  const _SafeMarkdown({
    required this.content,
    required this.textColor,
    required this.theme,
    required this.styleSheet,
  });

  final String content;
  final Color textColor;
  final ThemeData theme;
  final MarkdownStyleSheet styleSheet;

  @override
  Widget build(BuildContext context) {
    try {
      return MarkdownBody(
        data: content,
        selectable: true,
        fitContent: false,
        styleSheet: styleSheet,
        builders: <String, MarkdownElementBuilder>{'pre': CodeBlockBuilder()},
        onTapLink: MarkdownRenderer._handleLinkTap,
      );
    } catch (e) {
      // Fallback to plain text if markdown rendering fails
      debugPrint(
        'MarkdownRenderer: Rendering failed, falling back to '
        'plain text. Error: $e',
      );
      return SelectableText(
        content,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: textColor,
          height: 1.5,
        ),
      );
    }
  }
}
