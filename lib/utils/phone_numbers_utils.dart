import 'package:amba_new/models/phone_message_member.dart';

class PhoneNumbersUtils {
  static String getPhoneNumbersList(
      List<PhoneMessageMember> phoneMessageMemberList) {
    var phonesList = [];
    for (var i = 0; i < phoneMessageMemberList.length; i++) {
      phonesList.add(phoneMessageMemberList[i].phoneNumber);
    }
    final phonesString = phonesList.join(';').trim();
    return phonesString;
  }
}
