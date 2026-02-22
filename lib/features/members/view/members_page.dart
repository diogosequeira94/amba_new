import 'package:amba_new/features/members/cubit/members_cubit.dart';
import 'package:amba_new/features/members/cubit/details_cubit.dart';
import 'package:amba_new/features/members/cubit/members_state.dart';
import 'package:amba_new/features/members/view/widgets/home/skeleton/members_page_skeleton.dart';
import 'package:amba_new/features/members/view/widgets/home/widgets.dart';
import 'package:amba_new/features/members/view/widgets/searchbox.dart';
import 'package:amba_new/features/members/view/widgets/birthdays_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MembersPage extends StatelessWidget {
  const MembersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocBuilder<MembersCubit, MembersState>(
        builder: (context, state) {
          final isLoading = state is MembersInProgress;
          final success = state is MembersSuccess ? state : null;

          return RefreshIndicator(
            onRefresh: () => context.read<MembersCubit>().fetchPerson(),
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
                      icon: const Icon(Icons.message_outlined),
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
                  const MembersPageSkeleton()
                else if (success != null) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          SectionCard(
                            title: 'ANIVERSÁRIOS',
                            child: BirthdaysWidget(
                              birthdayMembers: success.birthdayMemberList,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const SectionCard(
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
                          HomeFilterButton(
                            onSelected: (value) {
                              final usersCubit = context.read<MembersCubit>();
                              switch (value) {
                                case HomeFilter.onlyActives:
                                  usersCubit.reOrderList(OrderType.onlyActives);
                                  break;
                                case HomeFilter.notActives:
                                  usersCubit.reOrderList(OrderType.notActives);
                                  break;
                                case HomeFilter.alphabetical:
                                  usersCubit.reOrderList(
                                    OrderType.alphabetical,
                                  );
                                  break;
                                case HomeFilter.numerical:
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

                        return MemberCard(
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
