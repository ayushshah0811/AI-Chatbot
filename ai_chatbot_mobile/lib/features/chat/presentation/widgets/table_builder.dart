import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import 'table_widget.dart';

/// Custom [MarkdownElementBuilder] for markdown tables.
///
/// Parses table [md.Element] structures into header/row data and
/// renders a [TableWidget] with horizontal scroll and proper column
/// alignment.
///
/// **Note**: In flutter_markdown 0.7.x the internal builder overrides
/// custom builder results for the `'table'` block tag. Therefore the
/// [MarkdownRenderer] configures table styling via [MarkdownStyleSheet]
/// (using [IntrinsicColumnWidth] for horizontal scroll). This builder
/// is provided for semantic completeness and can be used for standalone
/// table rendering outside flutter_markdown.
class TableBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final (headers, rows) = parseTableElement(element);
    if (headers.isEmpty && rows.isEmpty) return null;

    return TableWidget(headers: headers, rows: rows);
  }

  /// Parses an [md.Element] (with tag `'table'`) into a tuple of
  /// header strings and body row data.
  ///
  /// Can be called independently to extract table data from markdown
  /// elements for custom rendering or export.
  static (List<String>, List<List<String>>) parseTableElement(
    md.Element element,
  ) {
    final headers = <String>[];
    final rows = <List<String>>[];

    for (final child in element.children ?? <md.Node>[]) {
      if (child is! md.Element) continue;

      if (child.tag == 'thead') {
        _parseHeaderRows(child, headers);
      } else if (child.tag == 'tbody') {
        _parseBodyRows(child, rows);
      } else if (child.tag == 'tr') {
        // Flat table structure (no thead/tbody)
        final cells = _extractCells(child);
        if (headers.isEmpty) {
          headers.addAll(cells);
        } else {
          rows.add(cells);
        }
      }
    }

    return (headers, rows);
  }

  static void _parseHeaderRows(md.Element thead, List<String> headers) {
    for (final child in thead.children ?? <md.Node>[]) {
      if (child is md.Element && child.tag == 'tr') {
        headers.addAll(_extractCells(child));
      }
    }
  }

  static void _parseBodyRows(md.Element tbody, List<List<String>> rows) {
    for (final child in tbody.children ?? <md.Node>[]) {
      if (child is md.Element && child.tag == 'tr') {
        rows.add(_extractCells(child));
      }
    }
  }

  static List<String> _extractCells(md.Element tr) {
    return (tr.children ?? <md.Node>[])
        .whereType<md.Element>()
        .where((el) => el.tag == 'th' || el.tag == 'td')
        .map((el) => el.textContent.trim())
        .toList();
  }
}
