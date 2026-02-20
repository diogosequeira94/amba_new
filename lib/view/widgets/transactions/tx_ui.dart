class TxUi {
  final String id; // 👈 doc id do Firestore
  final String title;
  final String subtitle;
  final DateTime date;
  final double total;
  final int quotaCount;

  TxUi({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.total,
    required this.quotaCount,
  });
}