import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Загрузка...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }

  void _checkStatus(BuildContext context) {
    context.read<AuthBloc>().add(AuthCheckStatusRequested());
  }

  void _navigateBasedOnState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      Navigator.pushReplacementNamed(context, '/main');
    } else if (state is AuthUnauthenticated) {
      Navigator.pushReplacementNamed(context, '/signin');
    } else if (state is AuthError) {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }
}