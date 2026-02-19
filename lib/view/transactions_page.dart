import 'package:amba_new/view/widgets/transactions/tx_ui.dart';
import 'package:flutter/material.dart';

import 'package:amba_new/view/widgets/transactions/filters_card.dart';
import 'package:amba_new/view/widgets/transactions/summary_row.dart';
import 'package:amba_new/view/widgets/transactions/transaction_tile.dart';
import 'package:amba_new/view/widgets/transactions/tx_ui.dart';
import 'package:flutter/material.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  int year = DateTime.now().year;
  int? month; // null = ano inteiro

  // 🔥 MOCK (depois vem do Firestore)
  final List<TxUi> all = [
    TxUi(
      title: 'Quota — João Silva',
      subtitle: '2026-02, 2026-03',
      date: DateTime(2026, 2, 3),
      total: 20.0,
      quotaCount: 2,
    ),
    TxUi(
      title: 'Quota — Maria Costa',
      subtitle: '2026-02',
      date: DateTime(2026, 2, 12),
      total: 10.0,
      quotaCount: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filtered = all.where((t) {
      final sameYear = t.date.year == year;
      final sameMonth = month == null ? true : t.date.month == month;
      return sameYear && sameMonth;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));

    final totals = _computeTotals(filtered);

    return Scaffold(
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          /// APP BAR
          SliverAppBar(
            pinned: true,
            elevation: 0,
            surfaceTintColor: theme.colorScheme.surface,
            title: const Text('Quotas'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(12),
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
              ),
            ),
          ),

          /// FILTROS + RESUMO
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  FiltersCard(
                    year: year,
                    month: month,
                    onYearChanged: (v) => setState(() => year = v),
                    onMonthChanged: (v) => setState(() => month = v),
                  ),
                  const SizedBox(height: 12),
                  SummaryRow(
                    quotaCount: totals.quotaCount,
                    totalAmount: totals.totalAmount,
                  ),
                ],
              ),
            ),
          ),

          /// HEADER LISTA
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Text(
                'Últimas quotas',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          /// LISTA
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            sliver: filtered.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text('Sem quotas para o filtro atual.'),
                      ),
                    ),
                  )
                : SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return TransactionTile(tx: filtered[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _Totals {
  final double totalAmount;
  final int quotaCount;

  _Totals(this.totalAmount, this.quotaCount);
}

_Totals _computeTotals(List<TxUi> list) {
  double totalAmount = 0;
  int quotaCount = 0;

  for (final t in list) {
    totalAmount += t.total;
    quotaCount += t.quotaCount;
  }

  return _Totals(totalAmount, quotaCount);
}
