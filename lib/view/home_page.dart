import 'package:amba_new/cubit/details/details_cubit.dart';
import 'package:amba_new/cubit/users/users_cubit.dart';
import 'package:amba_new/router/app_router.dart';
import 'package:amba_new/view/widgets/searchbox.dart';
import 'package:amba_new/view/widgets/birthdays_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/create',
            arguments: const FormPageArguments(isEditing: false),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<UsersCubit, UsersState>(
        builder: (context, state) {
          final isLoading = state is UsersInProgress;
          final success = state is UsersSuccess ? state : null;

          return RefreshIndicator(
            onRefresh: () => context.read<UsersCubit>().fetchPerson(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  surfaceTintColor: theme.colorScheme.surface,
                  title: const Text('Sócios da AMBA'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.message_rounded),
                      onPressed: () {
                        Navigator.pushNamed(context, '/message');
                      },
                    ),
                  ],
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

                if (isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (success != null) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _SectionCard(
                            title: 'ANIVERSÁRIOS',
                            child: BirthdaysWidget(
                              birthdayMembers: success.birthdayMemberList,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const _SectionCard(
                            title: 'PESQUISA',
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(12, 10, 12, 12),
                              child: SearchBox(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
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
                                Text(
                                  'Total: ${success.personList.length}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          _FilterButton(
                            onSelected: (value) {
                              final usersCubit = context.read<UsersCubit>();
                              switch (value) {
                                case _HomeFilter.onlyActives:
                                  usersCubit.reOrderList(OrderType.onlyActives);
                                  break;
                                case _HomeFilter.notActives:
                                  usersCubit.reOrderList(OrderType.notActives);
                                  break;
                                case _HomeFilter.alphabetical:
                                  usersCubit.reOrderList(
                                    OrderType.alphabetical,
                                  );
                                  break;
                                case _HomeFilter.numerical:
                                  usersCubit.reOrderList(OrderType.numerical);
                                  break;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    sliver: SliverList.separated(
                      itemCount: success.personList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final person = success.personList[index];

                        return _MemberCard(
                          name: person.name ?? '—',
                          memberNumber: person.memberNumber?.toString() ?? '—',
                          isActive: person.isActive == true,
                          avatarUrl: (person.avatarUrl ?? '').trim().isEmpty
                              ? null
                              : person.avatarUrl!.trim(),
                          onTap: () {
                            Navigator.pushNamed(context, '/details');
                            context.read<DetailsCubit>().detailsStarted(person);
                          },
                        );
                      },
                    ),
                  ),
                ] else
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: SizedBox.shrink(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum _HomeFilter { onlyActives, notActives, alphabetical, numerical }

class _FilterButton extends StatelessWidget {
  final void Function(_HomeFilter value) onSelected;
  const _FilterButton({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_HomeFilter>(
      onSelected: onSelected,
      itemBuilder: (context) => const [
        PopupMenuItem(value: _HomeFilter.onlyActives, child: Text('Activos')),
        PopupMenuItem(value: _HomeFilter.notActives, child: Text('Inactivos')),
        PopupMenuItem(value: _HomeFilter.alphabetical, child: Text('Por nome')),
        PopupMenuItem(value: _HomeFilter.numerical, child: Text('Por número')),
      ],
      child: const _ChipButton(icon: Icons.filter_list, label: 'Filtrar'),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ChipButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final String name;
  final String memberNumber;
  final bool isActive;
  final String? avatarUrl;
  final VoidCallback onTap;

  const _MemberCard({
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
              _Avatar(
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
              _StatusChip(isActive: isActive),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;
  const _StatusChip({required this.isActive});

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

class _Avatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final String? memberNumber;
  final double radius;

  const _Avatar({
    required this.name,
    required this.avatarUrl,
    required this.memberNumber,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    print('######## MEMBER NUMBER $memberNumber');
    final initials = _initials(name);
    final assetPath = memberNumber != null
        ? 'assets/${memberNumber!}.jpg'
        : null;

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
      child: ClipOval(child: _buildImageOrFallback(initials, assetPath)),
    );
  }

  Widget _buildImageOrFallback(String initials, String? assetPath) {
    // 1️⃣ prioridade: imagem remota
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return Image.network(
        avatarUrl!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _assetOrInitials(initials, assetPath);
        },
      );
    }

    // 2️⃣ asset local
    return _assetOrInitials(initials, assetPath);
  }

  Widget _assetOrInitials(String initials, String? assetPath) {
    if (assetPath == null) {
      return _Initials(initials: initials);
    }

    return Image.asset(
      assetPath,
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return _Initials(initials: initials);
      },
    );
  }

  String _initials(String s) {
    final parts = s
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';

    final first = parts.first.characters.take(1).toString();
    final last = parts.length > 1
        ? parts.last.characters.take(1).toString()
        : '';

    return (first + last).toUpperCase();
  }
}

class _Initials extends StatelessWidget {
  final String initials;
  const _Initials({required this.initials});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Text(
        initials,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
