import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:BlueFin/features/balance/domain/entities/balance.dart';
import 'package:BlueFin/features/balance/presentation/bloc/balance_bloc.dart';
import 'package:BlueFin/features/balance/presentation/bloc/balance_state.dart';
import 'package:BlueFin/features/balance/presentation/screens/balance_screen.dart';

class MockBalanceBloc extends Mock implements BalanceBloc {}

void main() {
  late MockBalanceBloc mockBloc;
  final tBalance = Balance(amount: 1000.0, currency: 'BYN', updatedAt: DateTime.now());

  setUp(() {
    mockBloc = MockBalanceBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream<BalanceState>.empty());
    when(() => mockBloc.state).thenReturn(BalanceInitial());
  });

  testWidgets('should show balance amount when loaded', (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(BalanceLoaded(tBalance));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<BalanceBloc>.value(
          value: mockBloc,
          child: const BalanceScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('${tBalance.amount.toStringAsFixed(2)} ${tBalance.currency}'), findsOneWidget);
  });

  testWidgets('should show loading indicator when loading', (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(BalanceLoading());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<BalanceBloc>.value(
          value: mockBloc,
          child: const BalanceScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('should show error state message', (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(const BalanceError('Test error'));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<BalanceBloc>.value(
          value: mockBloc,
          child: const BalanceScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Ошибка загрузки баланса'), findsOneWidget);
  });
}