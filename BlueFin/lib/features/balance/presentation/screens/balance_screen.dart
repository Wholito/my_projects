import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/balance_bloc.dart';
import '../bloc/balance_event.dart';
import '../bloc/balance_state.dart';
import '../widgets/balance_card.dart';

class BalanceScreen extends StatelessWidget {
  const BalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Баланс'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BalanceBloc>().add(BalanceLoadRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<BalanceBloc, BalanceState>(
        listener: (context, state) {
          if (state is BalanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is BalanceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BalanceLoaded) {
            return Center(
              child: BalanceCard(balance: state.balance),
            );
          } else {
            return const Center(child: Text('Ошибка загрузки баланса'));
          }
        },
      ),
    );
  }
}