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
  final DateTime occurredAt;
  final int year;
  final int month;

  FinancialMovement({
    required this.id,
    required this.title,
    required this.amount,
    required this.notes,
    required this.type,
    required this.category,
    required this.occurredAt,
    required this.createdAt,
    required this.year,
    required this.month,
  });

  factory FinancialMovement.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    final createdTs = data['createdAt'];
    final occurredTs = data['occurredAt'];

    final createdAt = (createdTs is Timestamp)
        ? createdTs.toDate()
        : ((occurredTs is Timestamp) ? occurredTs.toDate() : DateTime(1970));

    final occurredAt = (occurredTs is Timestamp)
        ? occurredTs.toDate()
        : createdAt; // fallback p/ docs antigos

    return FinancialMovement(
      id: doc.id,
      title: (data['title'] ?? '').toString().trim(),
      amount: (data['amount'] as num? ?? 0).toDouble(),
      notes: (data['notes'] ?? '').toString().trim(),
      type: financeTypeFromString(data['type']?.toString()),
      category: (data['category'] ?? 'Outros').toString().trim(),
      createdAt: createdAt,
      occurredAt: occurredAt,
      year: (data['year'] as num? ?? occurredAt.year).toInt(),
      month: (data['month'] as num? ?? occurredAt.month).toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'amount': amount,
    'notes': notes,
    'type': financeTypeToString(type),
    'category': category.trim(),
    'createdAt': FieldValue.serverTimestamp(),
    'occurredAt': Timestamp.fromDate(
      DateTime(occurredAt.year, occurredAt.month, occurredAt.day),
    ),
    'year': occurredAt.year,
    'month': occurredAt.month,
  };

  /// Mapa usado no update (edição) de um movimento já existente.
  /// Não mexe no `createdAt`, para preservar a data de criação original.
  Map<String, dynamic> toUpdateMap() => {
    'title': title.trim(),
    'amount': amount,
    'notes': notes.trim(),
    'type': financeTypeToString(type),
    'category': category.trim(),
    'occurredAt': Timestamp.fromDate(
      DateTime(occurredAt.year, occurredAt.month, occurredAt.day),
    ),
    'year': occurredAt.year,
    'month': occurredAt.month,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  FinancialMovement copyWith({
    String? id,
    String? title,
    double? amount,
    String? notes,
    FinanceType? type,
    String? category,
    DateTime? occurredAt,
    DateTime? createdAt,
    int? year,
    int? month,
  }) {
    return FinancialMovement(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      category: category ?? this.category,
      occurredAt: occurredAt ?? this.occurredAt,
      createdAt: createdAt ?? this.createdAt,
      year: year ?? this.year,
      month: month ?? this.month,
    );
  }

  String get typeStr => financeTypeToString(type);
}
