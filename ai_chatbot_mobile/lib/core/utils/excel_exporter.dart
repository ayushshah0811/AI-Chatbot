import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Utility for exporting tabular data to `.xlsx` Excel files.
///
/// Creates an Excel workbook from header/row data using the `excel`
/// package, saves it to a temporary file, and shares it via the
/// platform share sheet using `share_plus`.
class ExcelExporter {
  ExcelExporter._();

  /// Exports table data as an `.xlsx` file and opens the share sheet.
  ///
  /// [headers] – Column header labels (written as the first row with bold).
  /// [rows] – Body data rows, each being a list of cell strings.
  /// [fileName] – Name for the exported file (without extension).
  ///
  /// Returns `true` if the file was created and shared successfully.
  static Future<bool> exportAndShare({
    required List<String> headers,
    required List<List<String>> rows,
    String fileName = 'table_export',
  }) async {
    try {
      final bytes = createExcelBytes(headers: headers, rows: rows);
      if (bytes == null) return false;

      final file = await _saveTempFile(bytes, '$fileName.xlsx');

      await Share.shareXFiles([
        XFile(file.path, mimeType: _xlsxMimeType),
      ], subject: fileName);

      return true;
    } catch (e) {
      debugPrint('ExcelExporter: Failed to export: $e');
      return false;
    }
  }

  /// Creates an in-memory Excel workbook and returns encoded bytes.
  ///
  /// Returns `null` if encoding fails.
  static List<int>? createExcelBytes({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    final excel = Excel.createExcel();
    const sheetName = 'Sheet1';
    final sheet = excel[sheetName];

    // Remove default "Sheet1" if a different default was created
    if (excel.getDefaultSheet() != sheetName) {
      final defaultSheet = excel.getDefaultSheet();
      if (defaultSheet != null) {
        excel.delete(defaultSheet);
      }
    }

    // ── Write header row ──
    final headerStyle = CellStyle(
      bold: true,
      fontFamily: getFontFamily(FontFamily.Calibri),
    );

    for (var col = 0; col < headers.length; col++) {
      final cellIndex = CellIndex.indexByColumnRow(
        columnIndex: col,
        rowIndex: 0,
      );
      sheet.updateCell(
        cellIndex,
        TextCellValue(headers[col]),
        cellStyle: headerStyle,
      );
    }

    // ── Write body rows ──
    for (var row = 0; row < rows.length; row++) {
      final rowData = rows[row];
      for (var col = 0; col < rowData.length; col++) {
        final cellIndex = CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: row + 1, // offset by 1 for header
        );
        sheet.updateCell(cellIndex, TextCellValue(rowData[col]));
      }
    }

    return excel.encode();
  }

  /// Saves [bytes] to a temporary file and returns the [File].
  static Future<File> _saveTempFile(List<int> bytes, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    return file.writeAsBytes(bytes, flush: true);
  }

  static const _xlsxMimeType =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
}
