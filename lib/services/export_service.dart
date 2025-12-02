import 'dart:convert';
import 'package:intl/intl.dart';

// Universal export service that works on all platforms
class ExportService {
  /// Generate CSV content from data
  static String generateCSV({
    required List<String> headers,
    required List<List<String>> rows,
    bool includeBOM = true,
  }) {
    final StringBuffer csvBuffer = StringBuffer();
    
    // Add UTF-8 BOM for proper Excel encoding
    if (includeBOM) {
      csvBuffer.write('\uFEFF');
    }
    
    // Add header row
    csvBuffer.writeln(headers.join(','));
    
    // Add data rows
    for (final row in rows) {
      final escapedRow = row.map((cell) => '"${_escapeCSV(cell)}"').join(',');
      csvBuffer.writeln(escapedRow);
    }
    
    return csvBuffer.toString();
  }

  /// Escape special characters for CSV format
  static String _escapeCSV(String value) {
    // Replace double quotes with two double quotes (CSV standard)
    return value.replaceAll('"', '""');
  }

  /// Generate filename with timestamp
  static String generateFilename(String prefix) {
    final now = DateTime.now();
    return '${prefix}_${DateFormat('yyyyMMdd_HHmmss').format(now)}.csv';
  }

  /// Calculate file size in KB
  static String calculateFileSize(String content) {
    final bytes = utf8.encode(content).length;
    return '${(bytes / 1024).toStringAsFixed(2)} KB';
  }
}

