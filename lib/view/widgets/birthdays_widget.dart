import 'package:amba_new/models/member.dart';
import 'package:amba_new/utils/date_extensions.dart';
import 'package:amba_new/utils/name_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/details/details_cubit.dart' show DetailsCubit;

class BirthdaysWidget extends StatelessWidget {
  final List<Member> birthdayMembers;
  const BirthdaysWidget({Key? key, required this.birthdayMembers})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (birthdayMembers.isEmpty)
            const Text('Não há aniversários este mês.'),
          if (birthdayMembers.isNotEmpty)
            birthdayMembers.length > 3
                ? _BiggerBirthdaysWidget(birthdayMembers: birthdayMembers)
                : _ShortBirthdayList(birthdayMembers: birthdayMembers),
        ],
      ),
    );
  }
}

class _ShortBirthdayList extends StatelessWidget {
  final List<Member> birthdayMembers;
  const _ShortBirthdayList({Key? key, required this.birthdayMembers})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final member in birthdayMembers)
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/details',
              );
              context.read<DetailsCubit>().detailsStarted(member);
            },
            child: Wrap(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${member.name?.getFirstAndLastName()} - ',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    const SizedBox(width: 4.0),
                    Flexible(
                        child: Text(
                            '${member.dateOfBirth!.getDayAndMonth()} (${member.age.toString()} anos)',
                            style: const TextStyle(fontSize: 16.0))),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BiggerBirthdaysWidget extends StatefulWidget {
  final List<Member> birthdayMembers;
  const _BiggerBirthdaysWidget({Key? key, required this.birthdayMembers})
      : super(key: key);

  @override
  State<_BiggerBirthdaysWidget> createState() => _BiggerBirthdaysWidgetState();
}

class _BiggerBirthdaysWidgetState extends State<_BiggerBirthdaysWidget> {
  var isExpanded = false;
  @override
  Widget build(BuildContext context) {
    print(widget.birthdayMembers.length);
    final firstList = widget.birthdayMembers.sublist(0, 3);
    final secondList =
        widget.birthdayMembers.sublist(3, widget.birthdayMembers.length);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final member in firstList)
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/details',
              );
              context.read<DetailsCubit>().detailsStarted(member);
            },
            child: Wrap(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 8.0),
                    Text(
                      '${member.name?.getFirstAndLastName()} - ',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    const SizedBox(width: 4.0),
                    Flexible(
                        child: Text(
                            '${member.dateOfBirth!.getDayAndMonth()} (${member.age.toString()} anos)',
                            style: const TextStyle(fontSize: 16.0))),
                  ],
                ),
              ],
            ),
          ),
        Visibility(
          visible: !isExpanded,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
            child: GestureDetector(
              child: Text(
                'Ver mais (${secondList.length})',
                style:
                    const TextStyle(color: Colors.blueAccent, fontSize: 16.0),
              ),
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ),
        ),
        Visibility(
          visible: isExpanded,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final member in secondList)
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/details',
                    );
                    context.read<DetailsCubit>().detailsStarted(member);
                  },
                  child: Wrap(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 8.0),
                          Text(
                            '${member.name?.getFirstAndLastName()} - ',
                            style: const TextStyle(fontSize: 18.0),
                          ),
                          const SizedBox(width: 4.0),
                          Flexible(
                              child: Text(
                                  '${member.dateOfBirth!.getDayAndMonth()} (${member.age.toString()} anos)',
                                  style: const TextStyle(fontSize: 16.0))),
                        ],
                      ),
                    ],
                  ),
                ),
              Visibility(
                visible: isExpanded,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: GestureDetector(
                    child: const Text(
                      'Ver menos',
                      style:
                          TextStyle(color: Colors.blueAccent, fontSize: 16.0),
                    ),
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
