import 'package:amba_new/features/members/models/member.dart';
import 'package:equatable/equatable.dart';

abstract class MembersState extends Equatable {
  const MembersState();
}

class MembersInitial extends MembersState {
  @override
  List<Object> get props => [];

  @override
  bool get stringify => false;
}

class MembersInProgress extends MembersState {
  @override
  List<Object> get props => [];
}

class MembersSuccess extends MembersState {
  final List<Member> personList;
  final List<Member> birthdayMemberList;
  final int fetchCount;
  const MembersSuccess({
    required this.personList,
    required this.fetchCount,
    required this.birthdayMemberList,
  });
  @override
  List<Object> get props => [
        personList,
        fetchCount,
        birthdayMemberList,
      ];
}

class MembersFailure extends MembersState {
  final String errorMessage;
  const MembersFailure({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}

class SearchBoxChangedSuccess extends MembersSuccess {
  const SearchBoxChangedSuccess({
    required List<Member> personList,
    required int fetchCount,
    required List<Member> birthdayMemberList,
  }) : super(
          personList: personList,
          fetchCount: fetchCount,
          birthdayMemberList: birthdayMemberList,
        );
  @override
  List<Object> get props => [
        personList,
        fetchCount,
        birthdayMemberList,
      ];
}

class DetailsPageSuccess extends MembersSuccess {
  final Member member;
  const DetailsPageSuccess({
    required List<Member> personList,
    required int fetchCount,
    required List<Member> birthdayMemberList,
    required this.member,
  }) : super(
    personList: personList,
    fetchCount: fetchCount,
    birthdayMemberList: birthdayMemberList,
  );
  @override
  List<Object> get props => [
    personList,
    fetchCount,
    birthdayMemberList,
    member,
  ];
}
