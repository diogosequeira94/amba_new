import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactButtonsWidget extends StatelessWidget {
  final String phone, email;
  const ContactButtonsWidget({
    Key? key,
    required this.phone,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          if (phone.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: IconButton(
                onPressed: () async {
                  AwesomeDialog(
                    context: context,
                    animType: AnimType.leftSlide,
                    headerAnimationLoop: false,
                    dialogType: DialogType.success,
                    showCloseIcon: true,
                    title: 'Contactar',
                    btnOkText: "Mensagem",
                    btnOkColor: Colors.blue,
                    btnOkOnPress: () async {
                      Uri sms = Uri.parse('sms:$phone?body=');
                      if (await launchUrl(sms)) {}
                    },
                    btnOkIcon: Icons.message_rounded,
                    btnCancelIcon: Icons.phone,
                    btnCancelText: 'Ligar',
                    btnCancelColor: Colors.green,
                    btnCancelOnPress: () async {
                      Uri call = Uri.parse('tel://$phone');
                      if (await launchUrl(call)) {}
                    },
                  ).show();
                },
                icon: const Icon(
                  Icons.call,
                  color: Colors.white,
                ),
              ),
            ),
          if (email.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: phone.isEmpty ? 0 : 12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: IconButton(
                  onPressed: () async {
                    Uri mail = Uri.parse('mailto:$email');
                    if (await launchUrl(mail)) {}
                  },
                  icon: const Icon(
                    Icons.alternate_email,
                    color: Colors.white,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
