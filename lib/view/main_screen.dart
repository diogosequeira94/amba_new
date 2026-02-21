import 'dart:ui';

import 'package:amba_new/bottom_bar/bottom_bar_bloc.dart';
import 'package:amba_new/cubit/quota/add_quota_cubit.dart';
import 'package:amba_new/cubit/users/users_cubit.dart';
import 'package:amba_new/router/app_router.dart';
import 'package:amba_new/view/add_quota_page.dart';
import 'package:amba_new/view/home_page.dart';
import 'package:amba_new/view/quotas_page.dart';
import 'package:amba_new/view/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late BottomBarBloc bottomBarBloc;

  @override
  void initState() {
    super.initState();
    bottomBarBloc = context.read<BottomBarBloc>();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<BottomBarBloc, BottomBarState>(
      builder: (context, state) {
        final index = _tabIndex(state.selectedTab);

        return Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: index,
            children: const [HomePage(), QuotasPage(), SettingsPage()],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              state.selectedTab == SelectedTab.home
                  ? Navigator.pushNamed(
                      context,
                      '/create',
                      arguments: const FormPageArguments(isEditing: false),
                    )
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider<UsersCubit>.value(
                              value: context.read<UsersCubit>(),
                            ),
                            BlocProvider(create: (_) => AddQuotaCubit()),
                          ],
                          child: const AddQuotaPage(),
                        ),
                      ),
                    );
            },
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                14,
                0,
                14,
                MediaQuery.of(context).viewPadding.bottom,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 26,
                          offset: const Offset(0, 14),
                          color: Colors.black.withOpacity(0.10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: GNav(
                        style: GnavStyle.google,
                        mainAxisAlignment: MainAxisAlignment.center,
                        gap: 10,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        tabBorderRadius: 18,
                        backgroundColor: Colors.transparent, // ✅ importante
                        color: theme.colorScheme.onSurface.withOpacity(0.60),
                        activeColor: theme.colorScheme.primary,
                        tabBackgroundColor: theme.colorScheme.primary
                            .withOpacity(0.12),
                        rippleColor: theme.colorScheme.primary.withOpacity(
                          0.12,
                        ),
                        hoverColor: theme.colorScheme.primary.withOpacity(0.08),
                        selectedIndex: index,
                        onTabChange: (i) {
                          if (i == 0) {
                            bottomBarBloc.add(
                              const BottomBarChanged(
                                selectedTab: SelectedTab.home,
                              ),
                            );
                          } else if (i == 1) {
                            bottomBarBloc.add(
                              const BottomBarChanged(
                                selectedTab: SelectedTab.transactions,
                              ),
                            );
                          } else if (i == 2) {
                            bottomBarBloc.add(
                              const BottomBarChanged(
                                selectedTab: SelectedTab.settings,
                              ),
                            );
                          }
                        },
                        tabs: const [
                          GButton(
                            icon: Icons.home_rounded,
                            text: 'Home',
                            style: GnavStyle.google,
                          ),
                          GButton(
                            icon: Icons.payment_outlined,
                            text: 'Quotas',
                            style: GnavStyle.google,
                          ),
                          GButton(
                            icon: Icons.settings_outlined,
                            text: 'Definições',
                            style: GnavStyle.google,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int _tabIndex(SelectedTab selectedTab) {
    if (selectedTab == SelectedTab.home) return 0;
    if (selectedTab == SelectedTab.transactions) return 1;
    if (selectedTab == SelectedTab.settings) return 2;
    return 0;
  }
}
