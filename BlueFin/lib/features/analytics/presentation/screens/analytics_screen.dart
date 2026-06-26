import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/category_list_widget.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Аналитика'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AnalyticsBloc>().add(AnalyticsLoadRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<AnalyticsBloc, AnalyticsState>(
        listener: (context, state) {
          if (state is AnalyticsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnalyticsLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('Доходы', style: TextStyle(color: Colors.green)),
                              Text(
                                '${state.summary.totalIncome.toStringAsFixed(2)} ₽',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Расходы', style: TextStyle(color: Colors.red)),
                              Text(
                                '${state.summary.totalExpense.toStringAsFixed(2)} ₽',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Баланс', style: TextStyle(color: Colors.blue)),
                              Text(
                                '${(state.summary.totalIncome - state.summary.totalExpense).toStringAsFixed(2)} ₽',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Расходы по категориям',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  PieChartWidget(
                    categories: state.summary.expenseCategories,
                    totalAmount: state.summary.totalExpense,
                  ),
                  const SizedBox(height: 8),
                  CategoryListWidget(categories: state.summary.expenseCategories),
                  const SizedBox(height: 16),
                  const Text(
                    'Доходы по категориям',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  PieChartWidget(
                    categories: state.summary.incomeCategories,
                    totalAmount: state.summary.totalIncome,
                  ),
                  const SizedBox(height: 8),
                  CategoryListWidget(categories: state.summary.incomeCategories),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Нет данных'));
          }
        },
      ),
    );
  }
}