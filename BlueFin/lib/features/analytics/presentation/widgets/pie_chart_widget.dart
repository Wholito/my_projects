import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/spending_category.dart';

class PieChartWidget extends StatelessWidget {
  final List<SpendingCategory> categories;
  final double totalAmount;

  const PieChartWidget({
    super.key,
    required this.categories,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty || totalAmount == 0) {
      return const Center(
        child: Text('Нет данных для отображения'),
      );
    }

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final percentage = (category.amount / totalAmount) * 100;
            return PieChartSectionData(
              color: colors[index % colors.length],
              value: category.amount,
              title: '${percentage.toStringAsFixed(1)}%',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 30,
        ),
      ),
    );
  }
}