import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pisarik_guessr/screens/game/game_flow_screen.dart';
import 'package:pisarik_guessr/services/network_service.dart';
import 'package:pisarik_guessr/widgets/network_status_banner.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'firebase_options.dart';
import 'navigation/game_navigation.dart';
import 'providers/app_state.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'utils/russian_word_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await RussianWordLoader.getWords();
  runApp(const PisarikGuessrApp());
}

class PisarikGuessrApp extends StatelessWidget {
  const PisarikGuessrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()..init()),
        ChangeNotifierProvider(create: (_) => NetworkService()),
      ],
      child: MaterialApp(
        navigatorKey: rootNavigatorKey,
        title: 'Pisarik Guessr',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkWarm,
        home: const _RootScreen(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/game':
              final args = settings.arguments as String;
              return PageRouteBuilder(
                pageBuilder: (_, __, ___) => GameFlowScreen(gameId: args),
                transitionsBuilder: (_, a, __, c) =>
                    FadeTransition(opacity: a, child: c),
                transitionDuration: const Duration(milliseconds: 300),
              );
            default:
              return MaterialPageRoute(builder: (_) => const _RootScreen());
          }
        },
      ),
    );
  }
}

class _RootScreen extends StatelessWidget {
  const _RootScreen();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (appState.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (appState.user == null) {
      return const LoginScreen();
    }

    return const HomeScreen();
  }
}