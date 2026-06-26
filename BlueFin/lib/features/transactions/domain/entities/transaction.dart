enum TransactionType {income, expense}

class Transaction {
  final String id;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String description;
  final TransactionType type;

  const Transaction({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.description,
    required this.type,
  });

  Transaction copyWith({
    String? id,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? description,
    TransactionType? type,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      description: description ?? this.description,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Transaction &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              amount == other.amount &&
              categoryId == other.categoryId &&
              date == other.date &&
              description == other.description &&
              type == other.type;

  @override
  int get hashCode => Object.hash(id, amount, categoryId, date, description, type);

  @override
  String toString() =>
      'Transaction(id: $id, amount: $amount, category: $categoryId, date: $date, description: $description, type: $type)';
}