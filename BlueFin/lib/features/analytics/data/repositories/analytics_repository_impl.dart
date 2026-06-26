import 'package:BlueFin/core/errors/failures.dart';
import 'package:BlueFin/features/analytics/domain/entities/spending_category.dart';
import 'package:BlueFin/features/analytics/domain/entities/spending_summary.dart';
import 'package:BlueFin/features/analytics/domain/repositories/i_analytics_repository.dart';
import 'package:BlueFin/features/categories/domain/entities/category.dart';
import 'package:BlueFin/features/categories/domain/repositories/i_category_repository.dart';
import 'package:BlueFin/features/transactions/domain/entities/transaction.dart';
import 'package:BlueFin/features/transactions/domain/repositories/i_transaction_repository.dart';
import 'package:dartz/dartz.dart';

class AnalyticsRepositoryImpl implements IAnalyticsRepository {
  final ITransactionRepository transactionRepository;
  final ICategoryRepository categoryRepository;

  AnalyticsRepositoryImpl({
    required this.transactionRepository,
    required this.categoryRepository,
  });

  @override
  Future<Either<Failure, SpendingSummary>> getSpendingSummary() async {
    final transactionsResult = await transactionRepository.getTransactions();
    final categoriesResult = await categoryRepository.getCategories();

    if (transactionsResult.isLeft()) {
      return Left(transactionsResult.fold((l) => l, (r) => throw Exception()));
    }
    if (categoriesResult.isLeft()) {
      return Left(categoriesResult.fold((l) => l, (r) => throw Exception()));
    }

    final transactions = transactionsResult.getOrElse(() => <Transaction>[]);
    final categories = categoriesResult.getOrElse(() => <Category>[]);
    final categoryMap = {for (var c in categories) c.id: c.name};

    return Right(_aggregate(transactions, categoryMap));
  }

  SpendingSummary _aggregate(
      List<Transaction> transactions,
      Map<String, String> categoryMap,
      ) {
    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> expenseMap = {};
    final Map<String, double> incomeMap = {};

    for (final tx in transactions) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
        incomeMap[tx.categoryId] = (incomeMap[tx.categoryId] ?? 0) + tx.amount;
      } else {
        totalExpense += tx.amount;
        expenseMap[tx.categoryId] = (expenseMap[tx.categoryId] ?? 0) + tx.amount;
      }
    }

    final expenseCategories = expenseMap.entries
        .map((e) => SpendingCategory(
      categoryId: e.key,
      categoryName: categoryMap[e.key] ?? e.key,
      amount: e.value,
    ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final incomeCategories = incomeMap.entries
        .map((e) => SpendingCategory(
      categoryId: e.key,
      categoryName: categoryMap[e.key] ?? e.key,
      amount: e.value,
    ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return SpendingSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      expenseCategories: expenseCategories,
      incomeCategories: incomeCategories,
    );
  }
}