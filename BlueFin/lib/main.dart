import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/supabase_service.dart'; // <-- добавить импорт
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';
import 'features/auth/presentation/screens/sign_up_screen.dart';
import 'features/balance/presentation/bloc/balance_bloc.dart';
import 'features/categories/presentation/bloc/categories_bloc.dart';
import 'features/transactions/presentation/bloc/transactions_bloc.dart';
import 'features/analytics/presentation/bloc/analytics_bloc.dart';
import 'features/currency/presentation/cubit/currency_cubit.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'presentation/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Supabase ДО runApp и ДО DI (или после, но до первого использования)
  await SupabaseService().init();

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>()..add(AuthCheckStatusRequested()),
        ),
        BlocProvider<BalanceBloc>(
          create: (context) => di.sl<BalanceBloc>(),
        ),
        BlocProvider<TransactionsBloc>(
          create: (context) => di.sl<TransactionsBloc>(),
        ),
        BlocProvider<AnalyticsBloc>(
          create: (context) => di.sl<AnalyticsBloc>(),
        ),
        BlocProvider<CurrencyCubit>(
          create: (context) => di.sl<CurrencyCubit>(),
        ),
        BlocProvider<SettingsCubit>(
          create: (context) => di.sl<SettingsCubit>(),
        ),
        BlocProvider<CategoriesBloc>(
          create: (context) => di.sl<CategoriesBloc>(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/signin',
                  (Route<dynamic> route) => false,
            );
          }
        },
        child: MaterialApp(
          title: 'BlueFin',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/signin': (context) => const SignInScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/main': (context) => const MainScreen(),
          },
        ),
      ),
    );
  }
}