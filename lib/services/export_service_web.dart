import 'dart:convert';
import 'dart:html' as html;

/// Web-specific export functionality
class ExportServiceWeb {
  /// Download CSV file in browser
  static void downloadCSV(String csvContent, String filename) {
    try {
      // Create blob
      final bytes = utf8.encode(csvContent);
      final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Create download link and trigger download
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..style.display = 'none';
      
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      
      // Cleanup
      html.Url.revokeObjectUrl(url);
      
      print('✅ CSV Downloaded: $filename');
    } catch (e) {
      print('❌ Error downloading CSV: $e');
      rethrow;
    }
  }
}

