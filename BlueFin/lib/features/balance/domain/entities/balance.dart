class Balance {
  final double amount;
  final String currency;
  final DateTime updatedAt;

  const Balance({
    required this.amount,
    required this.currency,
    required this.updatedAt,
  });

  factory Balance.initial([String currency = 'BYN']) {
    return Balance(
      amount: 0.0,
      currency: currency,
      updatedAt: DateTime.now(),
    );
  }

  Balance copyWith({
    double? amount,
    String? currency,
    DateTime? updatedAt,
  }) {
    return Balance(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool canSpend(double amountToSpend) => amount >= amountToSpend;

  Balance addIncome(double income) => copyWith(
    amount: amount + income,
    updatedAt: DateTime.now(),
  );

  Balance addExpense(double expense) => copyWith(
    amount: amount - expense,
    updatedAt: DateTime.now(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Balance &&
              runtimeType == other.runtimeType &&
              amount == other.amount &&
              currency == other.currency &&
              updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(amount, currency, updatedAt);

  @override
  String toString() => 'Balance(amount: $amount, currency: $currency, updatedAt: $updatedAt)';
}