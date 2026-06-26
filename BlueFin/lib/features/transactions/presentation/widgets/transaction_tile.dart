import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:BlueFin/features/transactions/domain/entities/transaction.dart';
import 'package:BlueFin/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:BlueFin/features/categories/presentation/bloc/categories_state.dart';

import '../../../categories/domain/entities/category.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final sign = isIncome ? '+' : '-';

    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        String categoryName = transaction.categoryId;
        if (state is CategoriesLoaded) {
          final category = state.categories.firstWhere(
                (cat) => cat.id == transaction.categoryId,
            orElse: () => Category(
              id: transaction.categoryId,
              name: 'Неизвестно',
              type: transaction.type,
            ),
          );
          categoryName = category.name;
        }
        return ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(
              isIncome ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
            ),
          ),
          title: Text(categoryName), // теперь имя
          subtitle: Text(transaction.description),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$sign${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: onDelete,
              ),
            ],
          ),
        );
      },
    );
  }
}