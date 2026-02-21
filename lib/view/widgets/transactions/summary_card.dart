import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final bool isNumberOnly;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    this.isNumberOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isNumberOnly
                  ? value.toInt().toString()
                  : '${value.toStringAsFixed(2)} €',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
