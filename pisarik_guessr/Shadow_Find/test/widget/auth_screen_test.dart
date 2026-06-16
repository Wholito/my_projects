import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shadow_find/providers/app_providers.dart';
import 'package:shadow_find/screens/auth/auth_screen.dart';
import 'package:shadow_find/services/connectivity_service.dart';
import 'package:shadow_find/theme/app_theme.dart';

Widget _authHarness(ConnectivityService connectivity) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider.value(value: connectivity),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: const AuthScreen(),
    ),
  );
}

void main() {
  testWidgets('shows retry overlay when offline', (tester) async {
    final connectivity = ConnectivityService();
    connectivity.setStatusForTest(NetworkStatus.offline);

    await tester.pumpWidget(_authHarness(connectivity));
    await tester.pumpAndSettle();

    expect(find.text('Повторить'), findsOneWidget);
    expect(find.text('Нет подключения к интернету'), findsOneWidget);
  });

  testWidgets('login form visible when online', (tester) async {
    final connectivity = ConnectivityService();
    connectivity.setStatusForTest(NetworkStatus.online);

    await tester.pumpWidget(_authHarness(connectivity));
    await tester.pumpAndSettle();

    expect(find.text('Повторить'), findsNothing);
    expect(find.text('Войти'), findsAtLeastNWidgets(1));
    expect(find.byType(TextFormField), findsWidgets);
  });
}
