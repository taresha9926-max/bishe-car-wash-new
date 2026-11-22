import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import 'print_export_stub.dart'
    if (dart.library.html) 'print_export_web.dart' as platform;

class PrintExportHelper {
  PrintExportHelper._();

  /// Converts tabular data into RFC 4180 CSV format and triggers browser download.
  static void exportCsv({
    required String fileName,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) {
    final buffer = StringBuffer();

    // Headers
    buffer.writeln(headers.map(_escapeCsvCell).join(','));

    // Rows
    for (final row in rows) {
      buffer.writeln(row.map(_escapeCsvCell).join(','));
    }

    final safeFileName = fileName.endsWith('.csv') ? fileName : '$fileName.csv';
    platform.downloadFile(safeFileName, buffer.toString(), 'text/csv;charset=utf-8');
  }

  static String _escapeCsvCell(dynamic value) {
    if (value == null) return '""';
    final str = value.toString().replaceAll('"', '""');
    return '"$str"';
  }

  /// Triggers document printing via browser window.print with custom styling.
  static void printHtml({
    required String title,
    required String htmlContent,
  }) {
    platform.printDocument(title, htmlContent);
  }

  /// Generates a standardized HTML report with BISHE Car Wash letterhead and tabular data.
  static void printTableReport({
    required String title,
    required String subtitle,
    required List<String> headers,
    required List<List<dynamic>> rows,
    Map<String, dynamic>? summaryTotals,
  }) {
    final tableBuffer = StringBuffer();
    tableBuffer.write('''
<div class="header">
  <div class="station-name">${AppConstants.appName}</div>
  <div class="station-sub">${AppConstants.appLocation} • Phone: ${AppConstants.stationPhoneNumber} / ${AppConstants.stationPhoneNumberSecondary}</div>
  <div class="doc-title">$title</div>
  <div class="station-sub">$subtitle • Printed: ${DateTime.now().toLocal().toString().split('.')[0]}</div>
</div>
<table>
  <thead>
    <tr>
''');
    for (final h in headers) {
      tableBuffer.write('<th>$h</th>');
    }
    tableBuffer.write('</tr></thead><tbody>');

    for (final r in rows) {
      tableBuffer.write('<tr>');
      for (final cell in r) {
        tableBuffer.write('<td>${cell ?? ''}</td>');
      }
      tableBuffer.write('</tr>');
    }

    if (summaryTotals != null && summaryTotals.isNotEmpty) {
      tableBuffer.write('<tr class="total-row">');
      int idx = 0;
      for (final h in headers) {
        if (idx == 0) {
          tableBuffer.write('<td>TOTAL SUMMARY</td>');
        } else if (summaryTotals.containsKey(h)) {
          tableBuffer.write('<td>${summaryTotals[h]}</td>');
        } else {
          tableBuffer.write('<td></td>');
        }
        idx++;
      }
      tableBuffer.write('</tr>');
    }

    tableBuffer.write('''
  </tbody>
</table>
<div class="footer">
  Authorized by BISHE Auto Care Station Operations System • Bishoftu, Ethiopia
</div>
''');

    printHtml(title: title, htmlContent: tableBuffer.toString());
  }

  /// Generates a thermal-styled (80mm width) receipt HTML and triggers printing.
  static void printReceipt({
    required String receiptNo,
    required String customerName,
    required String customerPhone,
    required String licensePlate,
    required String serviceName,
    required String carType,
    required double servicePrice,
    double vatAmount = 0.0,
    double tipAmount = 0.0,
    required double totalAmount,
    required String paymentMethod,
    String? transactionRef,
    required String cashierName,
    required DateTime timestamp,
  }) {
    final html = '''
<div style="max-width: 320px; margin: 0 auto; font-family: monospace; font-size: 11px;">
  <div style="text-align: center; border-bottom: 1px dashed #000; padding-bottom: 8px; margin-bottom: 8px;">
    <div style="font-size: 15px; font-weight: bold;">${AppConstants.appName}</div>
    <div style="font-size: 10px;">${AppConstants.appTagline}</div>
    <div style="font-size: 9px;">${AppConstants.appLocation}</div>
    <div style="font-size: 9px;">Tel: ${AppConstants.stationPhoneNumber}</div>
    <div style="margin-top: 5px; font-weight: bold; font-size: 12px;">OFFICIAL RECEIPT</div>
  </div>

  <div style="margin-bottom: 6px;">
    <div><strong>Receipt #:</strong> $receiptNo</div>
    <div><strong>Date:</strong> ${timestamp.toLocal().toString().split('.')[0]}</div>
    <div><strong>Cashier:</strong> $cashierName</div>
    <div><strong>Customer:</strong> $customerName ($customerPhone)</div>
    <div><strong>Plate:</strong> $licensePlate ($carType)</div>
  </div>

  <table style="width: 100%; border-collapse: collapse; border-top: 1px dashed #000; border-bottom: 1px dashed #000; margin: 6px 0; font-size: 11px;">
    <tr><td style="padding: 3px 0;"><strong>Service:</strong></td><td style="text-align: right; padding: 3px 0;">$serviceName</td></tr>
    <tr><td style="padding: 2px 0;">Base Price:</td><td style="text-align: right; padding: 2px 0;">${servicePrice.toStringAsFixed(2)} ETB</td></tr>
    ${vatAmount > 0 ? '<tr><td style="padding: 2px 0;">15% VAT:</td><td style="text-align: right; padding: 2px 0;">${vatAmount.toStringAsFixed(2)} ETB</td></tr>' : ''}
    ${tipAmount > 0 ? '<tr><td style="padding: 2px 0;">Washer Tip:</td><td style="text-align: right; padding: 2px 0;">${tipAmount.toStringAsFixed(2)} ETB</td></tr>' : ''}
    <tr style="font-weight: bold; font-size: 12px; border-top: 1px solid #000;">
      <td style="padding: 4px 0;">TOTAL PAID:</td>
      <td style="text-align: right; padding: 4px 0;">${totalAmount.toStringAsFixed(2)} ETB</td>
    </tr>
  </table>

  <div style="margin-top: 4px;">
    <div><strong>Method:</strong> $paymentMethod</div>
    ${transactionRef != null && transactionRef.trim().isNotEmpty ? '<div><strong>Tx Ref:</strong> $transactionRef</div>' : ''}
  </div>

  <div style="text-align: center; margin-top: 12px; border-top: 1px dashed #000; padding-top: 6px; font-size: 10px;">
    <div>Galatoomaa! • አመሰግናለሁ! • Thank you!</div>
    <div style="font-size: 8.5px; margin-top: 3px; color: #555;">Bishoftu Premier Auto Care Station</div>
  </div>
</div>
''';

    printHtml(title: 'Receipt_$receiptNo', htmlContent: html);
  }

  /// Displays an in-app interactive preview dialog with Print, Export CSV, and Copy actions.
  static void showPreviewDialog({
    required BuildContext context,
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
    required String csvFileName,
    String? subtitle,
    Map<String, dynamic>? summaryTotals,
  }) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.print_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 750,
            height: 480,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null) ...[
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                ],
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 38,
                          dataRowMinHeight: 32,
                          dataRowMaxHeight: 38,
                          columns: headers
                              .map(
                                (h) => DataColumn(
                                  label: Text(
                                    h,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.5,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          rows: rows
                              .map(
                                (r) => DataRow(
                                  cells: r
                                      .map(
                                        (cell) => DataCell(
                                          Text(
                                            cell?.toString() ?? '',
                                            style: const TextStyle(fontSize: 11, color: Colors.white),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.download_rounded, size: 16, color: Color(0xFF38BDF8)),
              label: const Text('Export CSV', style: TextStyle(color: Color(0xFF38BDF8))),
              onPressed: () {
                exportCsv(fileName: csvFileName, headers: headers, rows: rows);
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Exported: $csvFileName'), duration: const Duration(seconds: 2)),
                );
              },
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.print_rounded, size: 16),
              label: const Text('Print Now'),
              onPressed: () {
                printTableReport(
                  title: title,
                  subtitle: subtitle ?? '',
                  headers: headers,
                  rows: rows,
                  summaryTotals: summaryTotals,
                );
                Navigator.of(dialogCtx).pop();
              },
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        );
      },
    );
  }
}
