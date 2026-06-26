import 'package:BlueFin/features/categories/domain/entities/category.dart';
import 'package:BlueFin/features/transactions/domain/entities/transaction.dart';

class CategoryModel {
  final String id;
  final String name;
  final TransactionType type;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
  });

  factory CategoryModel.fromDomain(Category category) => CategoryModel(
    id: category.id,
    name: category.name,
    type: category.type,
  );

  Category toDomain() => Category(
    id: id,
    name: name,
    type: type,
  );

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'] as String,
    name: json['name'] as String,
    type: json['type'] == 'income'
        ? TransactionType.income
        : TransactionType.expense,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type == TransactionType.income ? 'income' : 'expense',
  };
}