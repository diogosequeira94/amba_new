import 'package:amba_new/models/member.dart';
import 'package:amba_new/utils/date_extensions.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part 'users_state.dart';

enum OrderType {
  alphabetical,
  numerical,
  onlyActives,
  notActives,
}

class UsersCubit extends Cubit<UsersState> {
  UsersCubit() : super(UsersInitial());

  @visibleForTesting
  final List<Member> allMemberList = [];
  final List<Member> birthdayMemberList = [];
  int fetchCount = 0;

  /// Used to route birthdays to Details page
  List<Member> get getAllMembers => allMemberList;

  Future<void> fetchPerson() async {
    fetchCount++;
    emit(UsersInProgress());
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('socios').get();

      final memberList =
          querySnapshot.docs.map((doc) => Member.fromDoc(doc)).toList();

      memberList.sort((a, b) {
        return int.parse(b.memberNumber!).compareTo(int.parse(a.memberNumber!));
      });

      allMemberList.clear();
      allMemberList.addAll(memberList);

      if (birthdayMemberList.isNotEmpty) {
        birthdayMemberList.clear();
      }

      _getBirthdayMemberList(allMemberList);

      birthdayMemberList.sort((a, b) {
        return a.dateOfBirth!.compareTo(b.dateOfBirth!);
      });

      emit(
        UsersSuccess(
            personList: memberList,
            fetchCount: fetchCount,
            birthdayMemberList: birthdayMemberList),
      );
    } on Object catch (e) {
      emit(UserFailure(errorMessage: e.toString()));
    }
  }

  void searchBoxChanged(String query) {
    var tempList = allMemberList
        .where((member) =>
            (member.name!.toLowerCase().contains(query.toLowerCase())) ||
            member.memberNumber!.contains(query) ||
            (member.phoneNumber != null && member.phoneNumber!.contains(query)))
        .toList();
    emit(SearchBoxChangedSuccess(
      personList: tempList,
      fetchCount: fetchCount,
      birthdayMemberList: birthdayMemberList,
    ));
  }

  void _getBirthdayMemberList(List<Member> members) {
    final dayNow = DateTime.now().day;
    final monthNow = DateTime.now().month;
    final yearNow = DateTime.now().year;

    final membersWithDateOfBirth = members
        .where((member) =>
            member.dateOfBirth != null && member.dateOfBirth!.isNotEmpty)
        .toList();

    final membersList = membersWithDateOfBirth
        .where((member) =>
            member.dateOfBirth != null &&
            member.dateOfBirth!.getMonthNumber().contains(monthNow.toString()))
        .toList();

    for (var i = 0; i < membersList.length; i++) {
      final member = membersList[i];
      if (member.dateOfBirth == null ||
          int.parse(member.dateOfBirth!.getDayNumber()) < dayNow) continue;
      final memberAge =
          yearNow - int.parse(member.dateOfBirth!.getYearOfBirth());
      birthdayMemberList.add(member.copyWith(age: memberAge));
    }
  }

  void reOrderList(OrderType orderType) {
    List<Member> tempList = List.from(allMemberList);
    if (orderType == OrderType.onlyActives) {
      tempList = allMemberList.where((member) => member.isActive!).toList();
    } else if (orderType == OrderType.notActives) {
      tempList = allMemberList.where((member) => !member.isActive!).toList();
    } else if (orderType == OrderType.alphabetical) {
      tempList.sort((a, b) {
        return a.name!.compareTo(b.name!);
      });
    } else if (orderType == OrderType.numerical) {
      tempList.sort((a, b) {
        return int.parse(a.memberNumber!).compareTo(int.parse(b.memberNumber!));
      });
    }

    emit(
      UsersSuccess(
        personList: tempList,
        fetchCount: fetchCount,
        birthdayMemberList: birthdayMemberList,
      ),
    );
  }
}
