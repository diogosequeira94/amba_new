import 'package:amba_new/features/members/bloc/edit_bloc.dart';
import 'package:amba_new/features/members/cubit/message_cubit.dart';
import 'package:amba_new/features/members/cubit/members_cubit.dart';
import 'package:amba_new/features/members/models/phone_message_member.dart';
import 'package:amba_new/features/members/view/member_details_page.dart';
import 'package:amba_new/features/members/view/messages_page.dart';
import 'package:amba_new/features/members/models/member.dart';
import 'package:amba_new/view/amba_splash.dart';
import 'package:amba_new/features/members/view/form_page.dart';
import 'package:amba_new/view/main_screen.dart';
import 'package:amba_new/view/pin_page.dart';
import 'package:amba_new/features/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/members/cubit/details_cubit.dart' show DetailsCubit;

final MembersCubit _usersCubit = MembersCubit()..fetchPerson();
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

      case '/pin':
        return MaterialPageRoute(builder: (_) => const PinLockPage());

      case '/home':
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<MembersCubit>.value(value: _usersCubit),
              BlocProvider<DetailsCubit>.value(value: _detailsCubit),
            ],
            child: const MainScreen(),
          ),
        );

      case '/details':
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<MembersCubit>.value(value: _usersCubit),
              BlocProvider<DetailsCubit>.value(value: _detailsCubit),
            ],
            child: const MemberDetailsPage(),
          ),
        );

      case '/create':
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<MembersCubit>.value(value: _usersCubit),
              BlocProvider<DetailsCubit>.value(value: _detailsCubit),
              BlocProvider<EditBloc>(create: (context) => EditBloc()),
            ],
            child: FormPage(
              member: (args as FormPageArguments).member,
              isEditing: args.isEditing,
            ),
          ),
        );
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsPage());

      case '/message':
        final eligibleMembersList = _usersCubit.getAllMembers
            .where(
              (member) =>
                  member.isActive! &&
                  member.phoneNumber!.isNotEmpty &&
                  member.phoneNumber!.length == 9 &&
                  member.phoneNumber!.startsWith('9'),
            )
            .toList();

        final phoneNumberList = eligibleMembersList
            .map((member) => PhoneMessageMember.fromMember(member))
            .toList();

        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<MembersCubit>.value(value: _usersCubit),
              BlocProvider<MessageCubit>(
                create: (context) =>
                    MessageCubit()..setupMembers(phoneNumberList),
              ),
            ],
            child: const MessagesPage(),
          ),
        );

      default:
        return MaterialPageRoute(builder: (_) => const SizedBox.shrink());
    }
  }

  void dispose() {
    _usersCubit.close();
  }
}
