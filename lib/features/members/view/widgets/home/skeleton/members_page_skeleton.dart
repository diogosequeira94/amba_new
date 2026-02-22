import 'package:flutter/material.dart';
import 'package:amba_new/features/members/view/widgets/home/section_card.dart';
import 'skeleton_box.dart';

class MembersPageSkeleton extends StatelessWidget {
  const MembersPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ANIVERSÁRIOS
            const SectionCard(
              title: 'ANIVERSÁRIOS',
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    SkeletonBox(height: 50, width: 50),
                    SizedBox(width: 10),
                    Expanded(child: SkeletonBox(height: 16)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // PESQUISA
            const SectionCard(
              title: 'PESQUISA',
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: SkeletonBox(height: 48),
              ),
            ),

            const SizedBox(height: 20),

            // HEADER "Sócios"
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sócios',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const SkeletonBox(height: 12, width: 80),
                    ],
                  ),
                ),
                const SkeletonBox(height: 36, width: 36),
              ],
            ),

            const SizedBox(height: 16),

            // Lista de membros
            ...List.generate(
              6,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                  child: const Row(
                    children: [
                      SkeletonBox(height: 48, width: 48),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(height: 14),
                            SizedBox(height: 8),
                            SkeletonBox(height: 12, width: 80),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
