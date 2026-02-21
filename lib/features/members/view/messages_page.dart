import 'package:amba_new/features/members/cubit/message_cubit.dart';
import 'package:amba_new/utils/phone_numbers_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageCubit, MessageState>(builder: (context, state) {
      if (state is PhoneMemberSetupSuccess) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('Contactar Sócios'),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.check,
                  ),
                  onPressed: () async {
                    if (textEditingController.text.trim().isNotEmpty) {
                      final selectedMembersList = state.phoneMessageMemberList
                          .where((member) => member.isSelected)
                          .toList();
                      final getPhoneNumberList =
                          PhoneNumbersUtils.getPhoneNumbersList(
                              selectedMembersList);
                      Uri sms = Uri.parse(
                          'sms:$getPhoneNumberList;?body=${textEditingController.text}');
                      if (await launchUrl(sms)) {}
                    }
                  },
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Conteúdo da mensagem:',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                      child: TextFormField(
                        controller: textEditingController,
                        minLines: 3,
                        maxLines: 8,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          hintStyle: TextStyle(color: Colors.grey[800]),
                          fillColor: Colors.white70,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selecionar a quem enviar:',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                '(${state.selectedMembers} pessoas)',
                                style: const TextStyle(fontSize: 14.0),
                              ),
                            ),
                          ],
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            icon: const Icon(Icons.filter_list),
                            items: <String>[
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
                              final messageCubit = context.read<MessageCubit>();
                              if (newValue == 'Por número') {
                                messageCubit.reOrderList(
                                    state.phoneMessageMemberList,
                                    OrderType.numerical);
                              } else if (newValue == 'Por nome') {
                                messageCubit.reOrderList(
                                    state.phoneMessageMemberList,
                                    OrderType.alphabetical);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: state.phoneMessageMemberList.length,
                      itemBuilder: (context, index) {
                        final person = state.phoneMessageMemberList[index];
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 0.0),
                              child: Card(
                                child: CheckboxListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 10.0),
                                  title: Text(
                                    '${person.memberNumber} - ${person.name}',
                                    style: const TextStyle(fontSize: 20.0),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      person.phoneNumber,
                                    ),
                                  ),
                                  value: person.isSelected,
                                  onChanged: (value) {
                                    context
                                        .read<MessageCubit>()
                                        .phoneMemberChanged(
                                          state.phoneMessageMemberList,
                                          person.phoneNumber,
                                        );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ));
      }
      return const SizedBox.shrink();
    });
  }
}
