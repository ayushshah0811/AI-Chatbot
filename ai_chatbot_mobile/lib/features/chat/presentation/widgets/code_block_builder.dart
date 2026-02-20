import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import 'code_block_widget.dart';

/// Custom [MarkdownElementBuilder] for fenced code blocks (`pre` tag).
///
/// Detects the language from the `<code class="language-xxx">` child
/// element and renders a [CodeBlockWidget] with syntax highlighting
/// and a copy-to-clipboard button.
class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => true;

  /// Return a zero-size placeholder so the internal [MarkdownBuilder]'s
  /// `_inlines` list gets a child entry.  Without this, the `<code>` inline
  /// inside `<pre>` creates a parent inline in `_inlines` whose children
  /// list stays empty.  `_addAnonymousBlockIfNeeded()` only clears
  /// `_inlines` when `inline.children.isNotEmpty`, so the empty inline
  /// survives until `assert(_inlines.isEmpty)` at builder.dart:267.
  ///
  /// The placeholder ends up in an anonymous block that is added to the
  /// `<pre>` [_BlockElement]'s children, but since [visitElementAfterWithContext]
  /// returns a non-null widget, `defaultChild()` (which would render those
  /// children) is never called — the placeholder is discarded.
  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) {
    return const SizedBox.shrink();
  }

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final code = element.textContent;

    // Extract the language from the code child element.
    // Fenced code blocks produce: <pre><code class="language-sql">...</code>
    String language = 'plaintext';
    if (element.children != null && element.children!.isNotEmpty) {
      final firstChild = element.children!.first;
      if (firstChild is md.Element) {
        final langClass = firstChild.attributes['class'];
        if (langClass != null && langClass.startsWith('language-')) {
          language = langClass.substring('language-'.length);
        }
      }
    }

    return CodeBlockWidget(code: code, language: language);
  }
}
