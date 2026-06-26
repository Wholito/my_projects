  import '../../domain/entities/exchange_rate.dart';

  class ExchangeRateModel {
  final String baseCurrency;
  final String targetCurrency;
  final double rate;
  final DateTime updatedAt;

  ExchangeRateModel({
  required this.baseCurrency,
  required this.targetCurrency,
  required this.rate,
  required this.updatedAt,
  });

  factory ExchangeRateModel.fromDomain(ExchangeRate rate) => ExchangeRateModel(
  baseCurrency: rate.baseCurrency,
  targetCurrency: rate.targetCurrency,
  rate: rate.rate,
  updatedAt: rate.updatedAt,
  );

  ExchangeRate toDomain() => ExchangeRate(
  baseCurrency: baseCurrency,
  targetCurrency: targetCurrency,
  rate: rate,
  updatedAt: updatedAt,
  );

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) =>
  ExchangeRateModel(
  baseCurrency: json['baseCurrency'] as String,
  targetCurrency: json['targetCurrency'] as String,
  rate: (json['rate'] as num).toDouble(),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
  'baseCurrency': baseCurrency,
  'targetCurrency': targetCurrency,
  'rate': rate,
  'updatedAt': updatedAt.toIso8601String(),
  };
  }