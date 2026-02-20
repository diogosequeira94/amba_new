import 'package:amba_new/cubit/quota/add_quota_cubit.dart';
import 'package:amba_new/cubit/quota/add_quota_state.dart';
import 'package:amba_new/cubit/quota/quotas_cubit.dart';
import 'package:amba_new/cubit/users/users_cubit.dart';
import 'package:amba_new/models/member.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddQuotaPage extends StatefulWidget {
  const AddQuotaPage({super.key});

  @override
  State<AddQuotaPage> createState() => _AddQuotaPageState();
}

class _AddQuotaPageState extends State<AddQuotaPage> {
  Member? selectedMember;
  int selectedYear = DateTime.now().year;

  final TextEditingController amountCtrl = TextEditingController(text: '10.00');

  final List<String> months = const [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];

  final Set<int> selectedMonths = {};

  @override
  void dispose() {
    amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final double amountPerMonth =
        double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0;

    final double total = amountPerMonth * selectedMonths.length;

    return BlocListener<AddQuotaCubit, AddQuotaState>(
      listener: (context, state) {
        if (state is AddQuotaSubmitting) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('A guardar quota...')));
        }

        if (state is AddQuotaSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          context.read<QuotasCubit>().fetchQuotas(year: 2026);
          Navigator.pop(context);
        }

        if (state is AddQuotaFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              surfaceTintColor: theme.colorScheme.surface,
              title: const Text('Adicionar Quota'),
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

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    /// 👤 MEMBRO
                    _SectionCard(
                      title: 'MEMBRO',
                      child: BlocBuilder<UsersCubit, UsersState>(
                        builder: (context, state) {
                          if (state is UsersInProgress) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (state is UsersSuccess) {
                            final members = state.personList;

                            return DropdownButtonFormField<Member>(
                              isExpanded: true,
                              value: selectedMember,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person_outline),
                                labelText: 'Selecionar membro',
                              ),
                              items: members.map((m) {
                                return DropdownMenuItem<Member>(
                                  value: m,
                                  child: Text(
                                    '${m.memberNumber} - ${m.name}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) {
                                setState(() => selectedMember = v);
                              },
                            );
                          }

                          return const SizedBox();
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// 📆 ANO
                    _SectionCard(
                      title: 'ANO',
                      child: DropdownButtonFormField<int>(
                        value: selectedYear,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                          labelText: 'Selecionar ano',
                        ),
                        items: List.generate(7, (index) {
                          final year = DateTime.now().year - 5 + index;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }),
                        onChanged: (v) {
                          setState(() => selectedYear = v!);
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// 📅 MESES
                    _SectionCard(
                      title: 'MESES',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(months.length, (index) {
                          final isSelected = selectedMonths.contains(index);

                          return ChoiceChip(
                            label: Text(months[index]),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                if (isSelected) {
                                  selectedMonths.remove(index);
                                } else {
                                  selectedMonths.add(index);
                                }
                              });
                            },
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// 💰 VALOR
                    _SectionCard(
                      title: 'VALOR POR MÊS',
                      child: TextFormField(
                        controller: amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.euro),
                          labelText: 'Valor (€)',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🧮 TOTAL
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${total.toStringAsFixed(2)} €',
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
              ),
            ),

            /// BOTÃO FIXO
            SliverFillRemaining(
              hasScrollBody: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    16 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar quota'),
                      onPressed: _submit,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (selectedMember == null || selectedMonths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleciona um membro e pelo menos um mês'),
        ),
      );
      return;
    }

    final amount = double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0;

    context.read<AddQuotaCubit>().submitQuota(
      member: selectedMember!,
      months: selectedMonths.toList(),
      amountPerMonth: amount,
      year: selectedYear,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
