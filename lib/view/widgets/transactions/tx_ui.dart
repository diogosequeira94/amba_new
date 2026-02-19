class TxUi {
  final String title;
  final String subtitle;
  final DateTime date;
  final double total;
  final int quotaCount; // 👈 número de meses pagos

  TxUi({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.total,
    required this.quotaCount,
  });
}