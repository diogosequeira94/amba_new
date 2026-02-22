import 'dart:typed_data';
import 'package:amba_new/features/finances/model/financial_movement.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class FinancePdfService {
  Future<Uint8List> buildFinanceReport({
    required List<FinancialMovement> items,
    required int year,
    required int month, // 0 = ano inteiro
    required double income,
    required double expense,
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
    final balance = income - expense;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            'Relatório de Finanças',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Período: $period'),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Receitas: ${income.toStringAsFixed(2)} €'),
              pw.Text('Despesas: ${expense.toStringAsFixed(2)} €'),
              pw.Text('Saldo: ${balance.toStringAsFixed(2)} €'),
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
              0: const pw.FlexColumnWidth(2), // Data
              1: const pw.FlexColumnWidth(2), // Tipo
              2: const pw.FlexColumnWidth(2), // Categoria
              3: const pw.FlexColumnWidth(4), // Título
              4: const pw.FlexColumnWidth(2), // Montante
            },
            headers: const ['Data', 'Tipo', 'Categoria', 'Título', 'Montante'],
            data: items.map((m) {
              final d = m.createdAt;
              final dateStr =
                  '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
              final isIncome = m.type == FinanceType.income;

              return [
                dateStr,
                isIncome ? 'Receita' : 'Despesa',
                m.category,
                m.title,
                '${isIncome ? '+' : '-'}${m.amount.toStringAsFixed(2)} €',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    return doc.save();
  }
}
