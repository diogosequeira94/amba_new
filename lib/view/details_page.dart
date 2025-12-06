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
    return BlocConsumer<DetailsCubit, DetailsState>(
      listener: (context, state) {
        if (state is DetailsDeleteSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          context.read<UsersCubit>().fetchPerson();
          Navigator.pop(context);
        } else if (state is DetailsDeleteInProgress) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('A eliminar...'),
              ),
            );
        }
      },
      builder: (context, state) {
        if (state is DetailsSuccess) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pushNamed(context, '/create',
                    arguments: FormPageArguments(
                        isEditing: true, member: state.member));
              },
            ),
            appBar: AppBar(
              title: const Text('Detalhes'),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                  ),
                  onPressed: () {
                    final cubit = context.read<DetailsCubit>();
                    _showMyDialog(context, state.member, cubit);
                  },
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      state.member.name!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 28.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: [
                        const Text(
                          'Número de Sócio:',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        const SizedBox(
                          width: 8.0,
                        ),
                        Text(
                          state.member.memberNumber.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const Text(
                          'Desde: ',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        const SizedBox(
                          width: 8.0,
                        ),
                        Text(
                          state.member.joiningDate.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const Text(
                          'Activo: ',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        const SizedBox(
                          width: 8.0,
                        ),
                        Text(
                          state.member.isActive! ? 'Sim' : 'Não',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                      ],
                    ),
                  ),
                  if (state.member.email!.isNotEmpty ||
                      state.member.phoneNumber!.isNotEmpty)
                    ContactButtonsWidget(
                      email: state.member.email!,
                      phone: state.member.phoneNumber!,
                    ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text(
                      'DADOS DE SÓCIO',
                      style: TextStyle(color: Colors.blue, fontSize: 19.0),
                    ),
                  ),
                  const Divider(
                    color: Colors.blue,
                    thickness: 2.0,
                  ),
                  DataRow(
                    field: 'Data de Nascimento',
                    value: state.member.dateOfBirth!,
                  ),
                  DataRow(
                    field: 'Telefone',
                    value: state.member.phoneNumber!,
                  ),
                  DataRow(
                    field: 'Email',
                    value: state.member.email!,
                  ),
                  DataRow(
                    field: 'Observações',
                    value: state.member.notes!,
                  ),
                ],
              ),
            ),
          );
        } else if (state is DetailsDeleteInProgress) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Detalhes'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Future<void> _showMyDialog(
      BuildContext context, Member member, DetailsCubit cubit) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Sócio'),
          content: const Text('Quer eliminar este sócio da lista?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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

class DataRow extends StatelessWidget {
  final String field, value;
  const DataRow({Key? key, required this.field, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$field:',
            style: const TextStyle(fontSize: 18.0),
          ),
          const SizedBox(
            width: 8.0,
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
