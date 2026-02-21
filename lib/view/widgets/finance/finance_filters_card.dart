import 'package:amba_new/view/widgets/transactions/chip_menu.dart';
import 'package:flutter/material.dart';

class FinanceFiltersCard extends StatelessWidget {
  final int year;
  final int month; // 0 = ano inteiro

  final String type; // 'all' | 'income' | 'expense'
  final String category; // 'all' | ...

  final ValueChanged<int> onYearChanged;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onCategoryChanged;

  const FinanceFiltersCard({
    super.key,
    required this.year,
    required this.month,
    required this.type,
    required this.category,
    required this.onYearChanged,
    required this.onMonthChanged,
    required this.onTypeChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const categories = [
      'all',
      'Eventos',
      'Renda',
      'Água',
      'Material',
      'Donativos',
      'Outros',
    ];

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

            // Reusa exatamente o teu FiltersCard "base" (ano/mês),
            // mas sem duplicar UI: aqui fazemos o mesmo layout com chips.
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

                ChipMenu<String>(
                  icon: Icons.swap_vert,
                  label: _typeLabel(type),
                  items: const ['all', 'income', 'expense'],
                  itemLabel: _typeLabel,
                  onSelected: onTypeChanged,
                ),

                ChipMenu<String>(
                  icon: Icons.category_outlined,
                  label: category == 'all' ? 'Todas' : category,
                  items: categories,
                  itemLabel: (v) => v == 'all' ? 'Todas' : v,
                  onSelected: onCategoryChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _typeLabel(String v) {
    switch (v) {
      case 'income':
        return 'Receitas';
      case 'expense':
        return 'Despesas';
      default:
        return 'Tudo';
    }
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
