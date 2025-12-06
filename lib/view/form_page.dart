import 'package:amba_new/bloc/edit_bloc.dart';
import 'package:amba_new/cubit/details/details_cubit.dart';
import 'package:amba_new/cubit/users/users_cubit.dart';
import 'package:amba_new/models/member.dart';
import 'package:amba_new/utils/date_input_formatter.dart';
import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
    editBloc = context.read<EditBloc>();

    if (widget.isEditing) {
      //Add Default Values
      if (widget.member!.name != null) {
        editBloc.add(NameChanged(name: widget.member!.name!));
      }

      if (widget.member!.memberNumber != null) {
        editBloc.add(
            MemberNumberChanged(memberNumber: widget.member!.memberNumber!));
      }

      if (widget.member!.phoneNumber != null) {
        editBloc.add(PhoneChanged(phone: widget.member!.phoneNumber!));
      }

      if (widget.member!.joiningDate != null) {
        editBloc
            .add(JoiningDateChanged(joiningDate: widget.member!.joiningDate!));
      }

      if (widget.member!.dateOfBirth != null) {
        editBloc
            .add(DateOfBirthChanged(dateOfBirth: widget.member!.dateOfBirth!));
      }

      if (widget.member!.notes != null) {
        editBloc.add(NotesChanged(notes: widget.member!.notes!));
      }

      if (widget.member!.email != null) {
        editBloc.add(EmailChanged(email: widget.member!.email!));
      }

      context.read<EditBloc>().add(
          IsActiveCheckBoxChanged(isActive: widget.member!.isActive ?? false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar sócio' : 'Novo Sócio'),
      ),
      body: BlocListener<EditBloc, EditState>(
        listener: (context, state) {
          if (state.status.isSuccess) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            if (!widget.isEditing) {
              context.read<UsersCubit>().fetchPerson();
              Navigator.pop(context);
            } else {
              context.read<UsersCubit>().fetchPerson();
              context.read<DetailsCubit>().detailsStarted(state.newMember!);
              Navigator.pop(context);
            }
          }
          if (state.status.isInProgress) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                      widget.isEditing ? 'A atualizar...' : 'A adicionar...'),
                ),
              );
          }
        },
        child: BlocBuilder<EditBloc, EditState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nome:',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          NameInput(name: widget.member?.name),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Número de Sócio:',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          MemberNumber(
                              memberNumber: widget.member?.memberNumber),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Data de Admissão:',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          JoiningDate(
                            joiningDate: widget.member?.joiningDate,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Está Activo?',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          IsActiveCheckbox(isActive: widget.member?.isActive),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Número de Telefone:',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          PhoneInput(
                            phone: widget.member?.phoneNumber,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email:',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          EmailInput(
                            email: widget.member?.email,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Data de Nascimento:',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          DateOfBirthInput(
                            dateOfBirth: widget.member?.dateOfBirth,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Observações:',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          NotesInput(
                            notes: widget.member?.notes,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 50.0, bottom: 30.0),
                          child: SubmitButton(
                              memberId: widget.member?.id,
                              isEditing: widget.isEditing),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class EmailInput extends StatelessWidget {
  final String? email;
  const EmailInput({super.key, this.email = ''});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditBloc, EditState>(
      builder: (context, state) {
        return TextFormField(
          initialValue: email,
          decoration: InputDecoration(
            icon: const Icon(Icons.email),
            errorText: state.email.displayError != null
                ? 'Inserir um email válido'
                : null,
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            context.read<EditBloc>().add(EmailChanged(email: value));
          },
          textInputAction: TextInputAction.next,
        );
      },
    );
  }
}

class NameInput extends StatelessWidget {
  final String? name;
  const NameInput({super.key, this.name = ''});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditBloc, EditState>(
      builder: (context, state) {
        return TextFormField(
          initialValue: name,
          decoration: const InputDecoration(
            icon: Icon(Icons.person),
            helperMaxLines: 2,
            errorMaxLines: 2,
          ),
          obscureText: false,
          onChanged: (value) {
            context.read<EditBloc>().add(NameChanged(name: value));
          },
          textInputAction: TextInputAction.next,
        );
      },
    );
  }
}

class DateOfBirthInput extends StatelessWidget {
  final String? dateOfBirth;
  const DateOfBirthInput({super.key, this.dateOfBirth = ''});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditBloc, EditState>(
      builder: (context, state) {
        return TextFormField(
          initialValue: dateOfBirth,
          decoration: const InputDecoration(
            icon: Icon(Icons.child_care),
            helperMaxLines: 2,
            errorMaxLines: 2,
          ),
          obscureText: false,
          onChanged: (value) {
            context
                .read<EditBloc>()
                .add(DateOfBirthChanged(dateOfBirth: value));
          },
          inputFormatters: [DateTextFormatter()],
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        );
      },
    );
  }
}

class JoiningDate extends StatelessWidget {
  final String? joiningDate;
  const JoiningDate({super.key, this.joiningDate = ''});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditBloc, EditState>(
      builder: (context, state) {
        return TextFormField(
          initialValue: joiningDate,
          decoration: const InputDecoration(
            icon: Icon(Icons.check_circle_outline),
            helperMaxLines: 2,
            errorMaxLines: 2,
          ),
          obscureText: false,
          onChanged: (value) {
            context
                .read<EditBloc>()
                .add(JoiningDateChanged(joiningDate: value));
          },
          inputFormatters: [DateTextFormatter()],
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        );
      },
    );
  }
}

class MemberNumber extends StatelessWidget {
  final String? memberNumber;
  const MemberNumber({super.key, this.memberNumber = ''});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditBloc, EditState>(
      builder: (context, state) {
        return TextFormField(
          initialValue: memberNumber,
          decoration: const InputDecoration(
            icon: Icon(Icons.numbers),
            helperMaxLines: 2,
            errorMaxLines: 2,
          ),
          obscureText: false,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            context
                .read<EditBloc>()
                .add(MemberNumberChanged(memberNumber: value));
          },
          textInputAction: TextInputAction.next,
        );
      },
    );
  }
}

class IsActiveCheckbox extends StatelessWidget {
  final bool? isActive;
  const IsActiveCheckbox({Key? key, this.isActive = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditBloc, EditState>(
      builder: (context, state) {
        return Checkbox(
          value: state.isActive,
          onChanged: (value) {
            context
                .read<EditBloc>()
                .add(IsActiveCheckBoxChanged(isActive: value!));
          },
        );
      },
    );
  }
}

class PhoneInput extends StatelessWidget {
  final String? phone;
  const PhoneInput({super.key, this.phone = ''});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditBloc, EditState>(
      builder: (context, state) {
        return TextFormField(
          initialValue: phone,
          decoration: const InputDecoration(
            icon: Icon(Icons.phone),
            helperMaxLines: 2,
            errorMaxLines: 2,
          ),
          obscureText: false,
          maxLength: 9,
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            context.read<EditBloc>().add(PhoneChanged(phone: value));
          },
          textInputAction: TextInputAction.next,
        );
      },
    );
  }
}

class NotesInput extends StatelessWidget {
  final String? notes;
  const NotesInput({super.key, this.notes = ''});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditBloc, EditState>(
      builder: (context, state) {
        return TextFormField(
          initialValue: notes,
          decoration: const InputDecoration(
            icon: Icon(Icons.event_note),
            helperMaxLines: 2,
            errorMaxLines: 2,
          ),
          obscureText: false,
          onChanged: (value) {
            context.read<EditBloc>().add(NotesChanged(notes: value));
          },
          textInputAction: TextInputAction.done,
        );
      },
    );
  }
}

class SubmitButton extends StatelessWidget {
  final String? memberId;
  final bool isEditing;
  const SubmitButton({super.key, this.memberId, this.isEditing = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditBloc, EditState>(
      builder: (context, state) {
        final isSubmitting = state.status.isInProgress;
        return ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  // Change your radius here
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            onPressed: () async {
              if (state.memberNumber.value.isEmpty) {
                _showNumberNeededDialog(context);
              } else {
                context.read<EditBloc>().add(isEditing
                    ? EditingPressed(memberId: memberId!)
                    : FormSubmitted());
              }
            },
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: isSubmitting
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: Colors.white,
                    ))
                  : Center(child: Text(isEditing ? 'Actualizar' : 'Adicionar')),
            ));
      },
    );
  }

  Future<void> _showNumberNeededDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: const Text('Aviso'),
          content: const Text(
              'Para adicionar ou editar um Sócio tem de preencher o campo "Número de Sócio"'),
          actions: <Widget>[
            TextButton(
              child: const Text('Compreendo'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
