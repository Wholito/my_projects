import '../../domain/entities/transaction.dart';
import 'package:BlueFin/features/categories/domain/entities/category.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String description;
  final String type;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.description,
    required this.type,
  });

  factory TransactionModel.fromDomain(Transaction transaction) => TransactionModel(
    id: transaction.id,
    amount: transaction.amount,
    categoryId: transaction.categoryId,
    date: transaction.date,
    description: transaction.description,
    type: transaction.type == TransactionType.income ? 'income' : 'expense',
  );

  Transaction toDomain() => Transaction(
    id: id,
    amount: amount,
    categoryId: categoryId,
    date: date,
    description: description,
    type: type == 'income' ? TransactionType.income : TransactionType.expense,
  );

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
    id: json['id'] as String,
    amount: (json['amount'] as num).toDouble(),
    categoryId: json['categoryId'] as String,
    date: DateTime.parse(json['date'] as String),
    description: json['description'] as String,
    type: json['type'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'categoryId': categoryId,
    'date': date.toIso8601String(),
    'description': description,
    'type': type,
  };
}