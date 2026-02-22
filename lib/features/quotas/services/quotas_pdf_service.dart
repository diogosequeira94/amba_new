import 'dart:typed_data';
import 'package:amba_new/features/quotas/view/widgets/tx_ui.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class QuotaPdfService {
  Future<Uint8List> buildQuotasReport({
    required List<TxUi> items,
    required int year,
    required int month, // 0 = ano inteiro
    required double totalAmount,
    required int totalMonths,
  }) async {
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
    );

    String monthLabel(int m) {
      const months = [
        'Jan',
        'Fev',
        'Mar',
        'Abr',
        'Mai',
        'Jun',
        'Jul',
        'Ago',
        'Set',
        'Out',
        'Nov',
        'Dez',
      ];
      return months[m - 1];
    }

    final period = month == 0
        ? 'Ano inteiro $year'
        : '${monthLabel(month)} $year';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            'Relatório de Quotas',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Período: $period'),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total (€): ${totalAmount.toStringAsFixed(2)}'),
              pw.Text('Meses pagos: $totalMonths'),
              pw.Text('Registos: ${items.length}'),
            ],
          ),
          pw.SizedBox(height: 16),

          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 6,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(3), // Sócio
              1: const pw.FlexColumnWidth(4), // Períodos
              2: const pw.FlexColumnWidth(2), // Data
              3: const pw.FlexColumnWidth(2), // Total
            },
            headers: const ['Sócio', 'Períodos', 'Data', 'Total'],
            data: items.map((t) {
              final d = t.date;
              final dateStr =
                  '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
              return [
                t.title,
                t.subtitle,
                dateStr,
                '${t.total.toStringAsFixed(2)} €',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    return doc.save();
  }
}
