import '../../domain/entities/balance.dart';

class BalanceModel {
  final double amount;
  final String currency;
  final DateTime updatedAt;

  BalanceModel({required this.amount, required this.currency, required this.updatedAt});

  factory BalanceModel.fromDomain(Balance balance) => BalanceModel(
    amount: balance.amount,
    currency: balance.currency,
    updatedAt: balance.updatedAt,
  );

  Balance toDomain() => Balance(
    amount: amount,
    currency: currency,
    updatedAt: updatedAt,
  );

  factory BalanceModel.fromJson(Map<String, dynamic> json) => BalanceModel(
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] as String,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'currency': currency,
    'updatedAt': updatedAt.toIso8601String(),
  };
}