import 'spending_category.dart';

class SpendingSummary {
  final double totalIncome;
  final double totalExpense;
  final List<SpendingCategory> expenseCategories;
  final List<SpendingCategory> incomeCategories;

  const SpendingSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.expenseCategories,
    required this.incomeCategories,
  });
}