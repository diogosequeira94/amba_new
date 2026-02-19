import 'package:amba_new/bloc/edit_bloc.dart';
import 'package:amba_new/cubit/details/details_cubit.dart';
import 'package:amba_new/cubit/users/users_cubit.dart';
import 'package:amba_new/models/member.dart';
import 'package:amba_new/utils/date_input_formatter.dart';
import 'package:amba_new/view/widgets/clickable_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

class FormPage extends StatefulWidget {
  final Member? member;
  final bool isEditing;
  const FormPage({Key? key, this.member, this.isEditing = false})
    : super(key: key);

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  late EditBloc editBloc;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _memberNumberCtrl;
  late final TextEditingController _joiningDateCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _dobCtrl;
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    editBloc = context.read<EditBloc>();

    // Controllers (garante que o "editar" aparece logo preenchido)
    _nameCtrl = TextEditingController(text: widget.member?.name ?? '');
    _memberNumberCtrl = TextEditingController(
      text: widget.member?.memberNumber ?? '',
    );
    _joiningDateCtrl = TextEditingController(
      text: widget.member?.joiningDate ?? '',
    );
    _phoneCtrl = TextEditingController(text: widget.member?.phoneNumber ?? '');
    _emailCtrl = TextEditingController(text: widget.member?.email ?? '');
    _dobCtrl = TextEditingController(text: widget.member?.dateOfBirth ?? '');
    _notesCtrl = TextEditingController(text: widget.member?.notes ?? '');

    // Mantém a tua lógica original: popula o BLoC com defaults ao editar
    if (widget.isEditing) {
      if (widget.member?.name != null) {
        editBloc.add(NameChanged(name: widget.member!.name!));
      }
      if (widget.member?.memberNumber != null) {
        editBloc.add(
          MemberNumberChanged(memberNumber: widget.member!.memberNumber!),
        );
      }
      if (widget.member?.phoneNumber != null) {
        editBloc.add(PhoneChanged(phone: widget.member!.phoneNumber!));
      }
      if (widget.member?.joiningDate != null) {
        editBloc.add(
          JoiningDateChanged(joiningDate: widget.member!.joiningDate!),
        );
      }
      if (widget.member?.dateOfBirth != null) {
        editBloc.add(
          DateOfBirthChanged(dateOfBirth: widget.member!.dateOfBirth!),
        );
      }
      if (widget.member?.notes != null) {
        editBloc.add(NotesChanged(notes: widget.member!.notes!));
      }
      if (widget.member?.email != null) {
        editBloc.add(EmailChanged(email: widget.member!.email!));
      }

      editBloc.add(
        IsActiveCheckBoxChanged(isActive: widget.member!.isActive ?? false),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _memberNumberCtrl.dispose();
    _joiningDateCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _dobCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<EditBloc, EditState>(
        listener: (context, state) {
          if (state.status.isSuccess) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            // comportamento igual ao antigo
            context.read<UsersCubit>().fetchPerson();

            if (widget.isEditing) {
              context.read<DetailsCubit>().detailsStarted(state.newMember!);
            }

            Navigator.pop(context);
          }

          if (state.status.isInProgress) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    widget.isEditing ? 'A atualizar...' : 'A adicionar...',
                  ),
                ),
              );
          }
        },
        child: BlocBuilder<EditBloc, EditState>(
          builder: (context, state) {
            final isSubmitting = state.status.isInProgress;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  surfaceTintColor: theme.colorScheme.surface,
                  title: Text(widget.isEditing ? 'Editar sócio' : 'Novo Sócio'),
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
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      ClickableAvatar(
                        member: widget.member,
                        localPhoto: state.localPhoto,
                        enabled: !isSubmitting,
                        onPhotoPicked: (file) => editBloc.add(PhotoPicked(file: file)),
                        onRemovePhoto: () => editBloc.add(PhotoCleared()),
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'INFORMAÇÃO PRINCIPAL',
                        children: [
                          _Field(
                            controller: _nameCtrl,
                            label: 'Nome',
                            hint: 'Nome completo',
                            icon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                            onChanged: (v) =>
                                editBloc.add(NameChanged(name: v)),
                          ),
                          const SizedBox(height: 12),
                          _Field(
                            controller: _memberNumberCtrl,
                            label: 'Número de Sócio',
                            hint: 'ex: 123',
                            icon: Icons.numbers_outlined,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onChanged: (v) => editBloc.add(
                              MemberNumberChanged(memberNumber: v),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _Field(
                            controller: _joiningDateCtrl,
                            label: 'Data de Admissão',
                            hint: 'DD/MM/AAAA',
                            icon: Icons.calendar_month_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [DateTextFormatter()],
                            textInputAction: TextInputAction.next,
                            onChanged: (v) => editBloc.add(
                              JoiningDateChanged(joiningDate: v),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _SectionCard(
                        title: 'ESTADO',
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: theme.dividerColor.withOpacity(0.35),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_outlined),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Está Activo?',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Switch(
                                  value: state.isActive,
                                  onChanged: (value) {
                                    editBloc.add(
                                      IsActiveCheckBoxChanged(isActive: value),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _SectionCard(
                        title: 'CONTACTO',
                        children: [
                          _Field(
                            controller: _phoneCtrl,
                            label: 'Número de Telefone',
                            hint: '9 dígitos',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            maxLength: 9,
                            textInputAction: TextInputAction.next,
                            onChanged: (v) =>
                                editBloc.add(PhoneChanged(phone: v)),
                          ),
                          const SizedBox(height: 12),
                          _Field(
                            controller: _emailCtrl,
                            label: 'Email',
                            hint: 'ex: nome@email.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            errorText: state.email.displayError != null
                                ? 'Inserir um email válido'
                                : null,
                            onChanged: (v) =>
                                editBloc.add(EmailChanged(email: v)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _SectionCard(
                        title: 'DADOS PESSOAIS',
                        children: [
                          _Field(
                            controller: _dobCtrl,
                            label: 'Data de Nascimento',
                            hint: 'DD/MM/AAAA',
                            icon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [DateTextFormatter()],
                            textInputAction: TextInputAction.next,
                            onChanged: (v) => editBloc.add(
                              DateOfBirthChanged(dateOfBirth: v),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _SectionCard(
                        title: 'OBSERVAÇÕES',
                        children: [
                          _Field(
                            controller: _notesCtrl,
                            label: 'Observações',
                            hint: 'Notas internas (opcional)',
                            icon: Icons.notes_outlined,
                            textInputAction: TextInputAction.done,
                            minLines: 3,
                            maxLines: 6,
                            onChanged: (v) =>
                                editBloc.add(NotesChanged(notes: v)),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),

                // bottom submit bar
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
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 18,
                            offset: const Offset(0, -6),
                            color: Colors.black.withOpacity(0.06),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (state.memberNumber.value.isEmpty) {
                                    _showNumberNeededDialog(context);
                                  } else {
                                    editBloc.add(
                                      widget.isEditing
                                          ? EditingPressed(
                                              memberId: widget.member!.id!,
                                            )
                                          : FormSubmitted(),
                                    );
                                  }
                                },
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  widget.isEditing
                                      ? Icons.save_outlined
                                      : Icons.add_circle_outline,
                                ),
                          label: Text(
                            widget.isEditing ? 'Actualizar' : 'Adicionar',
                          ),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showNumberNeededDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aviso'),
          content: const Text(
            'Para adicionar ou editar um Sócio tem de preencher o campo "Número de Sócio"',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Compreendo'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
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
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final int? minLines;
  final int? maxLines;
  final ValueChanged<String> onChanged;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.maxLength,
    this.inputFormatters,
    this.errorText,
    this.minLines,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        errorText: errorText,
      ),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      minLines: minLines,
      maxLines: maxLines ?? 1,
      onChanged: onChanged,
    );
  }
}
