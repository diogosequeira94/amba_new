class TxUi {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final double total;
  final int quotaCount;

  final List<String> periodKeys;

  TxUi({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.total,
    required this.quotaCount,
    required this.periodKeys,
  });
}
