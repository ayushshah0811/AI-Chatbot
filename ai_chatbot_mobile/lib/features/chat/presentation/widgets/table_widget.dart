import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/utils/excel_exporter.dart';

/// A horizontally-scrollable table widget for rendering markdown tables.
///
/// Accepts pre-parsed [headers] and [rows] and lays them out as a
/// Material [DataTable] inside a horizontal [SingleChildScrollView]
/// so that wide tables never overflow. Includes a Download Excel button
/// that exports the table data as an `.xlsx` file via [ExcelExporter].
class TableWidget extends StatefulWidget {
  const TableWidget({required this.headers, required this.rows, super.key});

  /// Column header labels (from the first row / `<th>` elements).
  final List<String> headers;

  /// Body rows, each being a list of cell strings.
  final List<List<String>> rows;

  @override
  State<TableWidget> createState() => _TableWidgetState();
}

class _TableWidgetState extends State<TableWidget> {
  bool _exporting = false;

  Future<void> _handleExport() async {
    if (_exporting) return;
    setState(() => _exporting = true);

    try {
      await ExcelExporter.exportAndShare(
        headers: widget.headers,
        rows: widget.rows,
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.headers.isEmpty && widget.rows.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: DesignTokens.spacing.xs),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 0.5,
        ),
        borderRadius: DesignTokens.borderRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Table content ──
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: DesignTokens.borderRadius.md.topLeft,
              topRight: DesignTokens.borderRadius.md.topRight,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStatePropertyAll(
                  theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                ),
                headingTextStyle: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                dataTextStyle: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                columnSpacing: DesignTokens.spacing.lg,
                horizontalMargin: DesignTokens.spacing.md,
                columns: _buildColumns(theme),
                rows: _buildRows(),
              ),
            ),
          ),

          // ── Download Excel button ──
          _ExcelExportButton(exporting: _exporting, onPressed: _handleExport),
        ],
      ),
    );
  }

  List<DataColumn> _buildColumns(ThemeData theme) {
    if (widget.headers.isEmpty) {
      final colCount = widget.rows.isNotEmpty ? widget.rows.first.length : 0;
      return List.generate(
        colCount,
        (i) => DataColumn(label: Text('Column ${i + 1}')),
      );
    }

    return widget.headers
        .map((h) => DataColumn(label: Text(h.trim())))
        .toList();
  }

  List<DataRow> _buildRows() {
    return widget.rows.map((row) {
      final expectedLength = widget.headers.isNotEmpty
          ? widget.headers.length
          : row.length;

      return DataRow(
        cells: List.generate(expectedLength, (i) {
          final text = i < row.length ? row[i].trim() : '';
          return DataCell(Text(text));
        }),
      );
    }).toList();
  }
}

/// Compact export button row at table bottom.
class _ExcelExportButton extends StatelessWidget {
  const _ExcelExportButton({required this.exporting, required this.onPressed});

  final bool exporting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.45);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing.sm,
        vertical: DesignTokens.spacing.xxs,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: exporting ? null : onPressed,
          icon: exporting
              ? SizedBox(
                  width: DesignTokens.iconSize.xs,
                  height: DesignTokens.iconSize.xs,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: muted,
                  ),
                )
              : Icon(Icons.download_rounded, size: DesignTokens.iconSize.xs),
          label: Text(
            exporting ? 'Exporting…' : 'Export',
            style: theme.textTheme.labelSmall?.copyWith(
              color: muted,
              fontSize: 11,
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: muted,
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacing.sm),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }
}
