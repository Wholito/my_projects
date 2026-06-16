import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shadow_find/providers/app_providers.dart';
import 'package:shadow_find/screens/game/feed_screen.dart';
import 'package:shadow_find/theme/app_theme.dart';

void main() {
  testWidgets('empty feed shows hint text', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => FeedProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const FeedScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Попроси друзей'), findsOneWidget);
  });
}
