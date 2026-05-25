import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_find/screens/splash/splash_screen.dart';
import 'package:shadow_find/theme/app_theme.dart';

void main() {
  testWidgets('SplashScreen shows app title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const SplashScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Shadow Find'), findsOneWidget);
    expect(find.text('Угадай, где сделан снимок'), findsOneWidget);
  });

  testWidgets('SplashScreen can be disposed without pending timers', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const SplashScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    expect(find.text('Shadow Find'), findsNothing);
  });
}
