import 'package:amba_new/features/members/models/phone_message_member.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'message_state.dart';

enum OrderType {
  alphabetical,
  numerical,
}

class MessageCubit extends Cubit<MessageState> {
  MessageCubit() : super(MessageInitial());

  var selectedOrderType = OrderType.alphabetical;

  void setupMembers(List<PhoneMessageMember> phoneMessageMembersList) {
    phoneMessageMembersList.sort((a, b) {
      return a.name.compareTo(b.name);
    });
    emit(PhoneMemberSetupSuccess(
      phoneMessageMemberList: phoneMessageMembersList,
      selectedMembers: phoneMessageMembersList.length,
    ));
  }

  void phoneMemberChanged(List<PhoneMessageMember> phoneMessageMembersList,
      String memberPhoneNumber) {
    final updateMembersList = phoneMessageMembersList
        .map((member) => member.phoneNumber == memberPhoneNumber
            ? member.copyWith(isSelected: !member.isSelected)
            : member)
        .toList();

    selectedOrderType == OrderType.alphabetical
        ? updateMembersList.sort((a, b) {
            return a.name.compareTo(b.name);
          })
        : updateMembersList.sort((a, b) {
            return int.parse(a.memberNumber)
                .compareTo(int.parse(b.memberNumber));
          });

    final selectedMembersList =
        updateMembersList.where((member) => member.isSelected);

    emit(PhoneMemberSelectionChanged(
      phoneMessageMemberList: updateMembersList,
      selectedMembers: selectedMembersList.length,
    ));
  }

  void reOrderList(
      List<PhoneMessageMember> phoneMessageMembersList, OrderType orderType) {
    List<PhoneMessageMember> tempList = List.from(phoneMessageMembersList);
    if (orderType == OrderType.alphabetical) {
      tempList.sort((a, b) {
        return a.name.compareTo(b.name);
      });
      selectedOrderType = OrderType.alphabetical;
    } else if (orderType == OrderType.numerical) {
      tempList.sort((a, b) {
        return int.parse(a.memberNumber).compareTo(int.parse(b.memberNumber));
      });
      selectedOrderType = OrderType.numerical;
    }

    final selectedMembersList = tempList.where((member) => member.isSelected);

    emit(
      PhoneMemberSelectionChanged(
        phoneMessageMemberList: tempList,
        selectedMembers: selectedMembersList.length,
      ),
    );
  }
}
