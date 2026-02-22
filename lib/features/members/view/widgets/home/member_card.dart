import 'package:amba_new/features/members/view/widgets/home/home_avatar.dart';
import 'package:amba_new/features/members/view/widgets/home/status_chip.dart';
import 'package:flutter/material.dart';

class MemberCard extends StatelessWidget {
  final String name;
  final String memberNumber;
  final bool isActive;
  final String? avatarUrl;
  final VoidCallback onTap;

  const MemberCard({super.key,
    required this.name,
    required this.memberNumber,
    required this.isActive,
    required this.avatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              HomeAvatar(
                name: name,
                avatarUrl: avatarUrl,
                radius: 22,
                memberNumber: memberNumber,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Nº $memberNumber', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              StatusChip(isActive: isActive),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
