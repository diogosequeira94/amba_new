import 'package:amba_new/view/widgets/transactions/summary_card.dart'
    show SummaryCard;
import 'package:flutter/material.dart';

class SummaryRow extends StatelessWidget {
  final int quotaCount;
  final double totalAmount;

  const SummaryRow({
    super.key,
    required this.quotaCount,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SummaryCard(
            label: 'Nº de quotas',
            value: quotaCount.toDouble(),
            isNumberOnly: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SummaryCard(
            label: 'Total em quotas',
            value: totalAmount,
          ),
        ),
      ],
    );
  }
}