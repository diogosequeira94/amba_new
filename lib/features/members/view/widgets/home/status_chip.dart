import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final bool isActive;
  const StatusChip({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
    final label = isActive ? 'Activo' : 'Inactivo';
    final icon = isActive ? Icons.verified_outlined : Icons.block_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
