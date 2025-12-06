part of 'users_cubit.dart';

abstract class UsersState extends Equatable {
  const UsersState();
}

class UsersInitial extends UsersState {
  @override
  List<Object> get props => [];

  @override
  bool get stringify => false;
}

class UsersInProgress extends UsersState {
  @override
  List<Object> get props => [];
}

class UsersSuccess extends UsersState {
  final List<Member> personList;
  final List<Member> birthdayMemberList;
  final int fetchCount;
  const UsersSuccess({
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

class UserFailure extends UsersState {
  final String errorMessage;
  const UserFailure({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}

class SearchBoxChangedSuccess extends UsersSuccess {
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

class DetailsPageSuccess extends UsersSuccess {
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
