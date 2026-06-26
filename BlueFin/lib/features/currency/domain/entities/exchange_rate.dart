class ExchangeRate {
  final String baseCurrency;
  final String targetCurrency;
  final double rate;
  final DateTime updatedAt;

  const ExchangeRate({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.updatedAt,
  });

  ExchangeRate copyWith({
    String? baseCurrency,
    String? targetCurrency,
    double? rate,
    DateTime? updatedAt,
  }) {
    return ExchangeRate(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      rate: rate ?? this.rate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ExchangeRate &&
              runtimeType == other.runtimeType &&
              baseCurrency == other.baseCurrency &&
              targetCurrency == other.targetCurrency &&
              rate == other.rate &&
              updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(baseCurrency, targetCurrency, rate, updatedAt);

  @override
  String toString() =>
      'ExchangeRate(baseCurrency: $baseCurrency, targetCurrency: $targetCurrency, rate: $rate, updatedAt: $updatedAt)';
}