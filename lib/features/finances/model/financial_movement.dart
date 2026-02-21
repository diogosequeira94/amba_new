import 'package:cloud_firestore/cloud_firestore.dart';

enum FinanceType { income, expense }

FinanceType financeTypeFromString(String? v) =>
    (v == 'income') ? FinanceType.income : FinanceType.expense;

String financeTypeToString(FinanceType t) =>
    (t == FinanceType.income) ? 'income' : 'expense';

class FinancialMovement {
  final String id;
  final String title;
  final double amount;
  final String notes;
  final FinanceType type;
  final String category;
  final DateTime createdAt;
  final int year;
  final int month;

  FinancialMovement({
    required this.id,
    required this.title,
    required this.amount,
    required this.notes,
    required this.type,
    required this.category,
    required this.createdAt,
    required this.year,
    required this.month,
  });

  factory FinancialMovement.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'];

    final createdAt = (ts is Timestamp) ? ts.toDate() : DateTime.now();

    return FinancialMovement(
      id: doc.id,
      title: (data['title'] ?? '').toString().trim(),
      amount: (data['amount'] as num? ?? 0).toDouble(),
      notes: (data['notes'] ?? '').toString().trim(),
      type: financeTypeFromString(data['type']?.toString()),
      category: (data['category'] ?? 'Outros').toString(),
      createdAt: createdAt,
      year: (data['year'] as num? ?? createdAt.year).toInt(),
      month: (data['month'] as num? ?? createdAt.month).toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'amount': amount,
    'notes': notes,
    'type': financeTypeToString(type),
    'category': category,
    'createdAt': FieldValue.serverTimestamp(),
    'year': year,
    'month': month,
  };

  String get typeStr => financeTypeToString(type);
}
