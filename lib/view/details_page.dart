import 'package:amba_new/cubit/details/details_cubit.dart';
import 'package:amba_new/cubit/users/users_cubit.dart';
import 'package:amba_new/models/member.dart';
import 'package:amba_new/router/app_router.dart';
import 'package:amba_new/view/widgets/contact_buttons_widget.dart' show ContactButtonsWidget;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<DetailsCubit, DetailsState>(
      listener: (context, state) {
        if (state is DetailsDeleteSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          context.read<UsersCubit>().fetchPerson();
          Navigator.pop(context);
        } else if (state is DetailsDeleteInProgress) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('A eliminar...')));
        }
      },
      builder: (context, state) {
        if (state is DetailsDeleteInProgress) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is! DetailsSuccess) return const SizedBox();

        final member = state.member;

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/create',
                arguments: FormPageArguments(isEditing: true, member: member),
              );
            },
            child: const Icon(Icons.edit),
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 220,
                elevation: 0,
                surfaceTintColor: theme.colorScheme.surface,
                title: const Text('Perfil'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      final cubit = context.read<DetailsCubit>();
                      _showMyDialog(context, member, cubit);
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _ProfileHeader(member: member),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    children: [
                      _SectionCard(
                        title: 'INFORMAÇÃO DE CONTA',
                        children: [
                          _InfoTile(
                            icon: Icons.badge_outlined,
                            label: 'Número de Sócio',
                            value: _safe(member.memberNumber?.toString()),
                          ),
                          _InfoTile(
                            icon: Icons.calendar_month_outlined,
                            label: 'Desde',
                            value: _safe(member.joiningDate?.toString()),
                          ),
                          _InfoTile(
                            icon: member.isActive == true
                                ? Icons.verified_outlined
                                : Icons.do_not_disturb_alt_outlined,
                            label: 'Activo',
                            value: member.isActive == true ? 'Sim' : 'Não',
                            valueColor: member.isActive == true
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if ((member.email ?? '').isNotEmpty ||
                          (member.phoneNumber ?? '').isNotEmpty)
                        _SectionCard(
                          title: 'CONTACTO',
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: ContactButtonsWidget(
                                email: member.email ?? '',
                                phone: member.phoneNumber ?? '',
                              ),
                            ),
                            if ((member.phoneNumber ?? '').isNotEmpty)
                              _InfoTile(
                                icon: Icons.phone_outlined,
                                label: 'Telefone',
                                value: member.phoneNumber ?? '',
                              ),
                            if ((member.email ?? '').isNotEmpty)
                              _InfoTile(
                                icon: Icons.mail_outline,
                                label: 'Email',
                                value: member.email ?? '',
                              ),
                          ],
                        ),

                      const SizedBox(height: 12),

                      _SectionCard(
                        title: 'DADOS DE SÓCIO',
                        children: [
                          _InfoTile(
                            icon: Icons.cake_outlined,
                            label: 'Data de Nascimento',
                            value: _safe(member.dateOfBirth),
                          ),
                          _InfoTile(
                            icon: Icons.notes_outlined,
                            label: 'Observações',
                            value: (member.notes ?? '').trim().isEmpty
                                ? '—'
                                : member.notes!.trim(),
                            multiline: true,
                          ),
                        ],
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

  String _safe(String? v) => (v == null || v.trim().isEmpty) ? '—' : v.trim();

  Future<void> _showMyDialog(
      BuildContext context,
      Member member,
      DetailsCubit cubit,
      ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Sócio'),
          content: const Text('Quer eliminar este sócio da lista?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () {
                cubit.deleteMember(member);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Member member;
  const _ProfileHeader({required this.member});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final avatarUrl = (member.avatarUrl ?? '').trim(); // <-- cria este campo

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.18),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Avatar(
                  name: member.name ?? '',
                  avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
                  radius: 34,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (member.name ?? '—').trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _BadgeChip(
                            text: _memberClassText(member),
                            icon: Icons.workspace_premium_outlined,
                          ),
                          if ((member.memberNumber ?? 0) != 0)
                            _BadgeChip(
                              text: 'Nº ${member.memberNumber}',
                              icon: Icons.confirmation_number_outlined,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _memberClassText(Member m) {
    // se tiveres um campo "memberClass", usa-o aqui
    // por agora: Gold / Silver etc.
    // return (m.memberClass ?? 'Membro').toString();
    return 'Membro';
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? avatarUrl; // URL remota
  final double radius;

  const _Avatar({
    required this.name,
    required this.avatarUrl,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ImageProvider? provider;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      provider = NetworkImage(avatarUrl!);
    }

    final initials = _initials(name);

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
      backgroundImage: provider,
      child: provider == null
          ? Text(
        initials,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.primary,
        ),
      )
          : null,
    );
  }

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final first = parts.first.characters.take(1).toString();
    final last = parts.length > 1 ? parts.last.characters.take(1).toString() : '';
    return (first + last).toUpperCase();
  }
}

class _BadgeChip extends StatelessWidget {
  final String text;
  final IconData icon;

  const _BadgeChip({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.dividerColor.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool multiline;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: theme.textTheme.bodyMedium),
      subtitle: Text(
        value,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: valueColor,
        ),
        maxLines: multiline ? null : 1,
        overflow: multiline ? TextOverflow.visible : TextOverflow.ellipsis,
      ),
      dense: false,
      visualDensity: VisualDensity.standard,
    );
  }
}