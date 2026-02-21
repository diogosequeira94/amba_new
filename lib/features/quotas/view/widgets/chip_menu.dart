import 'package:flutter/material.dart';

class ChipMenu<T> extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T> onSelected;

  const ChipMenu({
    super.key,
    required this.icon,
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<T>(
      onSelected: (value) {
        onSelected(value); // ✅ NÃO bloquear null
      },
      itemBuilder: (context) {
        return items.map((item) {
          return PopupMenuItem<T>(value: item, child: Text(itemLabel(item)));
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: theme.dividerColor.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.expand_more, size: 18),
          ],
        ),
      ),
    );
  }
}
