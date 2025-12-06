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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/create',
              arguments: const FormPageArguments(isEditing: false));
        },
      ),
      appBar: AppBar(
        title: const Text('Sócios da AMBA'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.message_rounded,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/message');
            },
          )
        ],
      ),
      body: BlocBuilder<UsersCubit, UsersState>(builder: (context, state) {
        if (state is UsersInProgress) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is UsersSuccess) {
          return RefreshIndicator(
            onRefresh: () => context.read<UsersCubit>().fetchPerson(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  BirthdaysWidget(
                    birthdayMembers: state.birthdayMemberList,
                  ),
                  const SearchBox(),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 30.0, left: 15.0, right: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              'Sócios',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 22.0),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                'Total: ${state.personList.length.toString()}',
                                style: const TextStyle(fontSize: 17.0),
                              ),
                            ),
                          ],
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            icon: const Icon(Icons.filter_list),
                            items: <String>[
                              'Activos',
                              'Inactivos',
                              'Por nome',
                              'Por número',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              final usersCubit = context.read<UsersCubit>();
                              if (newValue == 'Activos') {
                                usersCubit.reOrderList(OrderType.onlyActives);
                              } else if (newValue == 'Inactivos') {
                                usersCubit.reOrderList(OrderType.notActives);
                              } else if (newValue == 'Por nome') {
                                usersCubit.reOrderList(OrderType.alphabetical);
                              } else {
                                usersCubit.reOrderList(OrderType.numerical);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10.0, left: 5.0, right: 5.0),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: state.personList.length,
                      itemBuilder: (context, index) {
                        final person = state.personList[index];
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 0.0),
                              child: Card(
                                child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 10.0),
                                    title: Text(
                                      '${person.memberNumber} - ${person.name}',
                                      style: const TextStyle(fontSize: 20.0),
                                    ),
                                    trailing: const Icon(
                                        Icons.keyboard_arrow_right_sharp),
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/details',
                                      );
                                      context
                                          .read<DetailsCubit>()
                                          .detailsStarted(person);
                                    }),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }
}
