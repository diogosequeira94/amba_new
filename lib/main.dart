import 'package:amba_new/features/bottom_bar/bottom_bar_bloc.dart';
import 'package:amba_new/firebase_options.dart';
import 'package:amba_new/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/quotas/cubit/quotas_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final currentYear = DateTime.now().year;
            return QuotasCubit()..fetchQuotas(year: currentYear);
          },
        ),
        BlocProvider(create: (context) => BottomBarBloc()),
      ],
      child: MaterialApp(
        title: 'Sócios da AMBA',
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: appRouter.onGenerateRoute,
        initialRoute: '/',
      ),
    );
  }
}
