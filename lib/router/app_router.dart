import 'package:amba_new/bloc/edit_bloc.dart';
import 'package:amba_new/cubit/details/details_cubit.dart';
import 'package:amba_new/cubit/messages/message_cubit.dart';
import 'package:amba_new/cubit/users/users_cubit.dart';
import 'package:amba_new/models/member.dart';
import 'package:amba_new/models/phone_message_member.dart';
import 'package:amba_new/view/amba_splash.dart';
import 'package:amba_new/view/details_page.dart';
import 'package:amba_new/view/form_page.dart';
import 'package:amba_new/view/home_page.dart';
import 'package:amba_new/view/messages_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final UsersCubit _usersCubit = UsersCubit()..fetchPerson();
final DetailsCubit _detailsCubit = DetailsCubit();

class FormPageArguments {
  final Member? member;
  final bool isEditing;
  const FormPageArguments({this.member, this.isEditing = false});
}

class AppRouter {
  Route onGenerateRoute(RouteSettings routeSettings) {
    final args = routeSettings.arguments;
    switch (routeSettings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/home':
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(providers: [
            BlocProvider<UsersCubit>.value(
              value: _usersCubit,
            ),
            BlocProvider<DetailsCubit>.value(
              value: _detailsCubit,
            ),
          ], child: const HomePage()),
        );
      case '/details':
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(providers: [
            BlocProvider<UsersCubit>.value(
              value: _usersCubit,
            ),
            BlocProvider<DetailsCubit>.value(
              value: _detailsCubit,
            ),
          ], child: const DetailsPage()),
        );
      case '/create':
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<UsersCubit>.value(
                value: _usersCubit,
              ),
              BlocProvider<DetailsCubit>.value(
                value: _detailsCubit,
              ),
              BlocProvider<EditBloc>(
                create: (context) => EditBloc(),
              )
            ],
            child: FormPage(
              member: (args as FormPageArguments).member,
              isEditing: args.isEditing,
            ),
          ),
        );
      case '/message':
        final eligibleMembersList = _usersCubit.getAllMembers
            .where((member) =>
                member.isActive! &&
                member.phoneNumber!.isNotEmpty &&
                member.phoneNumber!.length == 9 && member.phoneNumber!.startsWith('9'))
            .toList();
        final phoneNumberList = eligibleMembersList
            .map((member) => PhoneMessageMember.fromMember(member))
            .toList();
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<UsersCubit>.value(
                value: _usersCubit,
              ),
              BlocProvider<MessageCubit>(
                create: (context) =>
                    MessageCubit()..setupMembers(phoneNumberList),
              )
            ],
            child: const MessagesPage(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const SizedBox.shrink(),
        );
    }
  }

  void dispose() {
    _usersCubit.close();
  }
}
