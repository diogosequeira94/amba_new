import 'package:amba_new/bottom_bar/bottom_bar_bloc.dart';
import 'package:amba_new/cubit/quota/add_quota_cubit.dart';
import 'package:amba_new/router/app_router.dart';
import 'package:amba_new/view/add_quota_page.dart';
import 'package:amba_new/view/home_page.dart';
import 'package:amba_new/view/quotas_page.dart';
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
          // ✅ Importante para barra flutuante (body pode “passar” por trás)
          extendBody: true,

          // ✅ Nada de AppBar aqui (cada tab já é Scaffold)
          // ✅ Nada de FAB aqui (HomePage já tem FAB)
          body: IndexedStack(
            index: index,
            children: const [HomePage(), QuotasPage()],
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
                        builder: (_) => BlocProvider(
                          create: (_) => AddQuotaCubit(),
                          child: const AddQuotaPage(),
                        ),
                      ),
                    );
            },
            child: const Icon(Icons.add),
          ),

          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                  color: Colors.black.withOpacity(0.08),
                ),
              ],
              border: Border.all(color: theme.dividerColor.withOpacity(0.35)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: GNav(
                mainAxisAlignment: MainAxisAlignment.center,
                gap: 10.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18.0,
                  vertical: 14.0,
                ),
                tabBorderRadius: 18,
                backgroundColor: theme.colorScheme.surface,
                color: theme.colorScheme.onSurface.withOpacity(0.60),
                activeColor: theme.colorScheme.primary,
                tabBackgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                rippleColor: theme.colorScheme.primary.withOpacity(0.12),
                hoverColor: theme.colorScheme.primary.withOpacity(0.08),
                selectedIndex: index,
                onTabChange: (i) {
                  if (i == 0) {
                    bottomBarBloc.add(
                      const BottomBarChanged(selectedTab: SelectedTab.home),
                    );
                  } else if (i == 1) {
                    bottomBarBloc.add(
                      const BottomBarChanged(
                        selectedTab: SelectedTab.transactions,
                      ),
                    );
                  }
                },
                tabs: const [
                  GButton(icon: Icons.home_rounded, text: 'Home'),
                  GButton(icon: Icons.payment_outlined, text: 'Quotas'),
                ],
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
    return 0;
  }
}
