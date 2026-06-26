import 'package:flutter/material.dart';
import '../../domain/entities/spending_category.dart';

class CategoryListWidget extends StatelessWidget {
  final List<SpendingCategory> categories;

  const CategoryListWidget({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Text('Нет категорий');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (ctx, index) {
        final category = categories[index];
        return ListTile(
          leading: const Icon(Icons.category),
          title: Text(category.categoryId),
          trailing: Text('${category.amount.toStringAsFixed(2)} ₽'),
        );
      },
    );
  }
}