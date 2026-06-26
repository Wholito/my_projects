class SpendingCategory {
  final String categoryId;
  final String categoryName;
  final double amount;
  final int transactionCount;

  const SpendingCategory({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    this.transactionCount = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SpendingCategory &&
              runtimeType == other.runtimeType &&
              categoryId == other.categoryId &&
              categoryName == other.categoryName &&
              amount == other.amount;

  @override
  int get hashCode => Object.hash(categoryId, categoryName, amount);
}