import 'package:amba_new/view/widgets/transactions/tx_ui.dart';
import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  final TxUi tx;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionTile({
    super.key,
    required this.tx,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),

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
          tx.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        subtitle: Text(
          '${tx.subtitle}'
          '${tx.quotaCount > 1 ? ' • ${tx.quotaCount} meses' : ''}',
        ),

        trailing: Text(
          _fmtEuro(tx.total),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.primary,
          ),
        ),

        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  String _fmtEuro(double v) => '${v.toStringAsFixed(2)} €';
}
