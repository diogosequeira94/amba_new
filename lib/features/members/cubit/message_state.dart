part of 'message_cubit.dart';

abstract class MessageState extends Equatable {
  const MessageState();
}

class MessageInitial extends MessageState {
  @override
  List<Object> get props => [];
}

class PhoneMemberSetupSuccess extends MessageState {
  final List<PhoneMessageMember> phoneMessageMemberList;
  final int selectedMembers;
  const PhoneMemberSetupSuccess({
    required this.phoneMessageMemberList,
    required this.selectedMembers,
  });
  @override
  List<Object> get props => [phoneMessageMemberList, selectedMembers];
}

class PhoneMemberSelectionChanged extends PhoneMemberSetupSuccess {
  const PhoneMemberSelectionChanged({required phoneMessageMemberList, required selectedMembers})
      : super(phoneMessageMemberList: phoneMessageMemberList, selectedMembers: selectedMembers);
  @override
  List<Object> get props => [phoneMessageMemberList, selectedMembers];
}
