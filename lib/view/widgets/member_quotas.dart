import 'package:amba_new/models/member.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MemberQuotasSection extends StatefulWidget {
  final Member member;
  const MemberQuotasSection({super.key, required this.member});

  @override
  State<MemberQuotasSection> createState() => _MemberQuotasSectionState();
}

class _MemberQuotasSectionState extends State<MemberQuotasSection> {
  int _reload = 0;

  Member get member => widget.member;

  Future<QuerySnapshot<Map<String, dynamic>>> _fetch() {
    // _reload só serve para “invalidar” o Future e forçar refresh
    final _ = _reload;

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('type', isEqualTo: 'membership_fee')
        .where('memberId', isEqualTo: member.id)
        .get();
  }

  void _refresh() => setState(() => _reload++);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if ((member.id ?? '').isEmpty) return const SizedBox();

    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: _fetch(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Erro a carregar quotas: ${snap.error}',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          );
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const SectionCard(
            title: 'QUOTAS',
            children: [
              ListTile(
                leading: Icon(Icons.workspace_premium_outlined),
                title: Text('Sem quotas registadas'),
              ),
            ],
          );
        }

        final items = docs.map((d) {
          final data = d.data();

          final ts = data['createdAt'];
          final DateTime createdAt = (ts is Timestamp)
              ? ts.toDate()
              : DateTime(2000, 1, 1);

          final periods = (data['periods'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList();

          final total = (data['total'] as num? ?? 0).toDouble();
          final amountPerMonth = (data['amountPerMonth'] as num? ?? 0)
              .toDouble();
          final memberName = (data['memberName'] ?? '').toString();
          final memberNumber = (data['memberNumber'] ?? '').toString();
          final year = (data['year'] as num?)?.toInt();

          return _QuotaUi(
            id: d.id,
            createdAt: createdAt,
            periods: periods,
            total: total,
            amountPerMonth: amountPerMonth,
            memberName: memberName,
            memberNumber: memberNumber,
            year: year,
          );
        }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final quotasCount = items.fold<int>(
          0,
          (acc, e) => acc + e.periods.length,
        );
        final totalPaid = items.fold<double>(0, (acc, e) => acc + e.total);

        return SectionCard(
          title: 'QUOTAS',
          children: [
            ListTile(
              leading: Icon(
                Icons.insights_outlined,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'Resumo',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                'Meses pagos: $quotasCount • Total: ${totalPaid.toStringAsFixed(2)} €',
              ),
            ),
            const Divider(height: 1),
            ...items.map(
              (q) => ListTile(
                leading: Container(
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
                title: Text(
                  q.periods.isEmpty ? '—' : q.periods.join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text('Registado em ${_fmtDate(q.createdAt)}'),
                trailing: Text(
                  '${q.total.toStringAsFixed(2)} €',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
                onTap: () => _openQuotaDetails(context, q),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openQuotaDetails(BuildContext context, _QuotaUi q) async {
    final theme = Theme.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        final periodsLabel = q.periods.isEmpty ? '—' : q.periods.join(', ');
        final monthsCount = q.periods.length;

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

              const SizedBox(height: 14),

              _DetailRow(
                label: 'Sócio',
                value: '${q.memberNumber} — ${q.memberName}'.trim(),
              ),
              _DetailRow(label: 'Registado em', value: _fmtDate(q.createdAt)),
              if (q.year != null)
                _DetailRow(label: 'Ano', value: q.year.toString()),
              _DetailRow(label: 'Meses', value: monthsCount.toString()),
              _DetailRow(
                label: 'Períodos',
                value: periodsLabel,
                multiline: true,
              ),

              const SizedBox(height: 10),
              const Divider(),

              Row(
                children: [
                  Expanded(
                    child: _TotalCard(
                      label: 'Valor/mês',
                      value: '${q.amountPerMonth.toStringAsFixed(2)} €',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TotalCard(
                      label: 'Total',
                      value: '${q.total.toStringAsFixed(2)} €',
                      emphasize: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Apagar esta quota'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(
                      color: theme.colorScheme.error.withOpacity(0.6),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final ok = await _confirmDelete(context);
                    if (ok != true) return;

                    await FirebaseFirestore.instance
                        .collection('transactions')
                        .doc(q.id)
                        .delete();

                    if (context.mounted) Navigator.pop(context); // fecha sheet
                    _refresh();

                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Quota apagada.')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
  }

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}

class _QuotaUi {
  final String id;
  final DateTime createdAt;
  final List<String> periods;
  final double total;
  final double amountPerMonth;
  final String memberName;
  final String memberNumber;
  final int? year;

  _QuotaUi({
    required this.id,
    required this.createdAt,
    required this.periods,
    required this.total,
    required this.amountPerMonth,
    required this.memberName,
    required this.memberNumber,
    required this.year,
  });
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool multiline;

  const _DetailRow({
    required this.label,
    required this.value,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: multiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
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
}

class _TotalCard extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _TotalCard({
    required this.label,
    required this.value,
    this.emphasize = false,
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
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: emphasize ? theme.colorScheme.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ⚠️ Mantém isto igual ao teu SectionCard (está aqui só para contexto)
class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SectionCard({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            ...children,
          ],
        ),
      ),
    );
  }
}
