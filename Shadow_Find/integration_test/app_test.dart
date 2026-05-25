import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shadow_find/providers/app_providers.dart';
import 'package:shadow_find/screens/auth/auth_screen.dart';
import 'package:shadow_find/services/connectivity_service.dart';
import 'package:shadow_find/theme/app_theme.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('auth flow shows login and retry when offline', (tester) async {
    final connectivity = ConnectivityService();
    connectivity.setStatusForTest(NetworkStatus.offline);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider.value(value: connectivity),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const AuthScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Повторить'), findsOneWidget);

    await tester.tap(find.text('Повторить'));
    await tester.pump();

    connectivity.setStatusForTest(NetworkStatus.online);
    await tester.pumpAndSettle();

    expect(find.text('Создать аккаунт'), findsOneWidget);
    expect(find.text('Войти'), findsWidgets);
  });
}
