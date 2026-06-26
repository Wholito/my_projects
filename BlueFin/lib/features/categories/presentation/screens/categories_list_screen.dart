import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:BlueFin/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:BlueFin/features/categories/presentation/bloc/categories_event.dart';
import 'package:BlueFin/features/categories/presentation/bloc/categories_state.dart';
import 'package:BlueFin/features/categories/domain/entities/category.dart';
import '../../../transactions/domain/entities/transaction.dart';
import 'add_edit_category_screen.dart';
import 'add_edit_category_screen.dart';

class CategoriesListScreen extends StatelessWidget {
  const CategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditCategoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<CategoriesBloc, CategoriesState>(
        listener: (context, state) {
          if (state is CategoriesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          if (state is CategoriesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CategoriesLoaded) {
            final categories = state.categories;
            if (categories.isEmpty) {
              return const Center(
                child: Text('Нет категорий. Добавьте первую!'),
              );
            }
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryTile(context, category);
              },
            );
          } else if (state is CategoriesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ошибка: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<CategoriesBloc>()
                          .add(CategoryLoadRequested());
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Загрузите категории'));
          }
        },
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, Category category) {
    final isIncome = category.type == TransactionType.income;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
        child: Icon(
          isIncome ? Icons.arrow_upward : Icons.arrow_downward,
          color: isIncome ? Colors.green : Colors.red,
        ),
      ),
      title: Text(category.name),
      subtitle: Text(isIncome ? 'Доход' : 'Расход'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditCategoryScreen(category: category),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteConfirmation(context, category.id);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить категорию?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<CategoriesBloc>().add(CategoryDeleteRequested(id));
              Navigator.pop(context);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
