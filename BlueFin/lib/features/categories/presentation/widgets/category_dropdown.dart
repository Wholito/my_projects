import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:BlueFin/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:BlueFin/features/categories/presentation/bloc/categories_state.dart';

class CategoryDropdown extends StatelessWidget {
  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;

  const CategoryDropdown({
    super.key,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return const CircularProgressIndicator();
        } else if (state is CategoriesLoaded) {
          final categories = state.categories;
          if (categories.isEmpty) {
            return const Text('Нет категорий. Создайте их в настройках.');
          }
          final effectiveValue = selectedCategoryId ?? (categories.isNotEmpty ? categories.first.id : null);
          return DropdownButtonFormField<String>(
            value: effectiveValue,
            decoration: const InputDecoration(
              labelText: 'Категория',
              border: OutlineInputBorder(),
            ),
            items: categories.map((category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Выберите категорию';
              }
              return null;
            },
          );
        } else if (state is CategoriesError) {
          return Text('Ошибка загрузки категорий: ${state.message}');
        } else {
          return const Text('Загрузите категории');
        }
      },
    );
  }
}