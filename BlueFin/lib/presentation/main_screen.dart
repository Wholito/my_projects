import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/balance/presentation/screens/balance_screen.dart';
import '../features/transactions/presentation/screens/transactions_list_screen.dart';
import '../features/transactions/presentation/bloc/transactions_bloc.dart';
import '../features/transactions/presentation/bloc/transactions_event.dart';
import '../features/analytics/presentation/screens/analytics_screen.dart';
import '../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../features/analytics/presentation/bloc/analytics_event.dart';
import '../features/currency/presentation/screens/currency_converter_screen.dart';
import '../features/currency/presentation/cubit/currency_cubit.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    BalanceScreen(),
    TransactionsListScreen(),
    AnalyticsScreen(),
    CurrencyConverterScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
            context.read<TransactionsBloc>().add(TransactionsLoadRequested());
          } else if (index == 2) {
            context.read<AnalyticsBloc>().add(AnalyticsLoadRequested());
          } else if (index == 3) {
            context.read<CurrencyCubit>().loadRates();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Баланс',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Транзакции',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Аналитика',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange),
            label: 'Валюты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.blue,
      ),
    );
  }
}