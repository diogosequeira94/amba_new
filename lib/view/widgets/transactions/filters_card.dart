import 'package:amba_new/view/widgets/transactions/chip_menu.dart';
import 'package:flutter/material.dart';

class FiltersCard extends StatelessWidget {
  final int year;
  final int month; // 0 = ano inteiro
  final ValueChanged<int> onYearChanged;
  final ValueChanged<int> onMonthChanged;

  const FiltersCard({
    super.key,
    required this.year,
    required this.month,
    required this.onYearChanged,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FILTROS',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ChipMenu<int>(
                  icon: Icons.calendar_today_outlined,
                  label: '$year',
                  items: List.generate(4, (i) {
                    final base = DateTime.now().year;
                    return base - 2 + i;
                  }),
                  itemLabel: (v) => v.toString(),
                  onSelected: onYearChanged,
                ),

                ChipMenu<int>(
                  icon: Icons.date_range_outlined,
                  label: month == 0 ? 'Ano inteiro' : _monthName(month),
                  items: const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
                  itemLabel: (v) => v == 0 ? 'Ano inteiro' : _monthName(v),
                  onSelected: onMonthChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _monthName(int m) {
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
}
