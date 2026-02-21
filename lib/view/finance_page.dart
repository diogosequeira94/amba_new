import 'package:amba_new/cubit/finances/financial_cubit.dart';
import 'package:amba_new/cubit/finances/financial_state.dart';
import 'package:amba_new/models/finances/financial_movement.dart';
import 'package:amba_new/view/add_movement_page.dart';
import 'package:amba_new/view/widgets/finance/finance_filters_card.dart';
import 'package:amba_new/view/widgets/transactions/filters_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  int year = DateTime.now().year;
  int month = DateTime.now().month;

  String type = 'all'; // ✅ 'all' | 'income' | 'expense'
  String category = 'all'; // ✅ 'all' | 'Eventos' | 'Renda' | ...

  @override
  void initState() {
    super.initState();
    context.read<FinanceCubit>().fetchMovements(
      year: year,
      month: month,
      type: type,
      category: category,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'AA',
        child: const Icon(Icons.add),
        onPressed: () async {
          final ok = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => AddMovementPage(
                year: year,
                month: month == 0 ? DateTime.now().month : month,
              ),
            ),
          );

          if (ok == true && mounted) {
            context.read<FinanceCubit>().fetchMovements(
              year: year,
              month: month,
            );
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<FinanceCubit>().fetchMovements(
            year: year,
            month: month,
            type: type,
            category: category,
          );
        },
        child: BlocBuilder<FinanceCubit, FinanceState>(
          builder: (context, state) {
            if (state is FinanceLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FinanceFailure) {
              return Center(child: Text(state.message));
            }

            final items = state is FinanceSuccess
                ? state.items
                : <FinancialMovement>[];
            final totals = _computeTotals(items);

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  surfaceTintColor: theme.colorScheme.surface,
                  title: const Text('Finanças'),
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      children: [
                        FinanceFiltersCard(
                          year: year,
                          month: month,
                          type: type,
                          category: category,
                          onYearChanged: (v) {
                            setState(() => year = v);
                            context.read<FinanceCubit>().fetchMovements(
                              year: v,
                              month: month,
                              type: type,
                              category: category,
                            );
                          },
                          onMonthChanged: (v) {
                            setState(() => month = v);
                            context.read<FinanceCubit>().fetchMovements(
                              year: year,
                              month: v,
                              type: type,
                              category: category,
                            );
                          },
                          onTypeChanged: (v) {
                            setState(() => type = v);
                            context.read<FinanceCubit>().fetchMovements(
                              year: year,
                              month: month,
                              type: v,
                              category: category,
                            );
                          },
                          onCategoryChanged: (v) {
                            setState(() => category = v);
                            context.read<FinanceCubit>().fetchMovements(
                              year: year,
                              month: month,
                              type: type,
                              category: v,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _FinanceSummaryCard(totals: totals),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                    child: Text(
                      'Movimentos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 120),
                  sliver: items.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(
                              child: Text(
                                'Sem movimentos para o filtro atual.',
                              ),
                            ),
                          ),
                        )
                      : SliverList.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final m = items[index];
                            final isIncome = m.type == FinanceType.income;

                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color:
                                        (isIncome
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.error)
                                            .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    isIncome
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    color: isIncome
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.error,
                                  ),
                                ),
                                title: Text(m.title),
                                subtitle: Text(
                                  m.notes.isEmpty
                                      ? m.category
                                      : '${m.category} • ${m.notes}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                  '${isIncome ? '+' : '-'}${m.amount.toStringAsFixed(2)} €',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: isIncome
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.error,
                                  ),
                                ),
                                onLongPress: () => _confirmDelete(m),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(FinancialMovement m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Apagar movimento'),
        content: const Text('Tens a certeza que queres apagar este movimento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await context.read<FinanceCubit>().deleteMovement(
      id: m.id,
      yearToRefresh: year,
      monthToRefresh: month,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Movimento apagado')));
  }
}

class _FinanceTotals {
  final double income;
  final double expense;
  double get balance => income - expense;
  _FinanceTotals({required this.income, required this.expense});
}

_FinanceTotals _computeTotals(List<FinancialMovement> list) {
  double income = 0;
  double expense = 0;

  for (final m in list) {
    if (m.type == FinanceType.income) {
      income += m.amount;
    } else {
      expense += m.amount;
    }
  }
  return _FinanceTotals(income: income, expense: expense);
}

class _FinanceSummaryCard extends StatelessWidget {
  final _FinanceTotals totals;
  const _FinanceSummaryCard({required this.totals});

  String _fmt(double v) => '${v.toStringAsFixed(2)} €';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balance = totals.balance;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _kpi(
                    context,
                    'Receitas',
                    _fmt(totals.income),
                    isGood: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _kpi(
                    context,
                    'Despesas',
                    _fmt(totals.expense),
                    isGood: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withOpacity(0.08),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saldo',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    _fmt(balance),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: balance >= 0
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpi(
    BuildContext context,
    String label,
    String value, {
    required bool isGood,
  }) {
    final theme = Theme.of(context);
    final color = isGood ? theme.colorScheme.primary : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
