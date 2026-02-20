import 'package:amba_new/cubit/quota/quotas_cubit.dart';
import 'package:amba_new/cubit/quota/quotas_state.dart';
import 'package:amba_new/view/widgets/transactions/tx_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:amba_new/view/widgets/transactions/filters_card.dart';
import 'package:amba_new/view/widgets/transactions/summary_row.dart';
import 'package:amba_new/view/widgets/transactions/transaction_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuotasPage extends StatefulWidget {
  const QuotasPage({Key? key}) : super(key: key);

  @override
  State<QuotasPage> createState() => _QuotasPageState();
}

class _QuotasPageState extends State<QuotasPage> {
  int year = DateTime.now().year;
  int month = 0; // 0 = ano inteiro

  @override
  void initState() {
    super.initState();
    // carrega logo o ano atual
    context.read<QuotasCubit>().fetchQuotas(year: year);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<QuotasCubit>().fetchQuotas(year: year);
          return;
        },
        child: BlocBuilder<QuotasCubit, QuotasState>(
          builder: (context, state) {
            if (state is QuotasLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is QuotasFailure) {
              return Center(child: Text(state.message));
            }

            final List<TxUi> all = state is QuotasSuccess
                ? state.items
                : const [];

            final filtered = all.where((t) {
              final sameYear = t.date.year == year;
              final sameMonth = month == 0 ? true : t.date.month == month;
              return sameYear && sameMonth;
            }).toList();

            final totals = _computeTotals(filtered);

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
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

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      children: [
                        FiltersCard(
                          year: year,
                          month: month,
                          onYearChanged: (v) {
                            setState(() => year = v);
                            context.read<QuotasCubit>().fetchQuotas(year: v);
                          },
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
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final tx = filtered[index];

                            return TransactionTile(
                              tx: filtered[index],
                              onTap: () {
                                _openQuotaDetails(context, filtered[index]);
                              },
                              onLongPress: () {
                                _confirmDelete(filtered[index]);
                              },
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

  void _openQuotaDetails(BuildContext context, TxUi tx) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.workspace_premium_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Detalhe da quota',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _detailRow('Sócio', tx.title),
              _detailRow('Períodos', tx.subtitle, multiline: true),
              _detailRow('Data', _fmtDate(tx.date)),
              _detailRow('Meses pagos', tx.quotaCount.toString()),

              const SizedBox(height: 16),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        _fmtEuro(tx.total),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, {bool multiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: multiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              maxLines: multiline ? null : 1,
              overflow: multiline
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  String _fmtEuro(double v) => '${v.toStringAsFixed(2)} €';

  Future<void> _confirmDelete(TxUi tx) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Apagar quota'),
        content: const Text('Tens a certeza que queres apagar esta quota?'),
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

    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(tx.id)
        .delete();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Quota apagada')));

    // 🔥 Atualiza lista
    context.read<QuotasCubit>().fetchQuotas(year: year);
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
