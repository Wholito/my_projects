import 'package:equatable/equatable.dart';
import '../../domain/entities/exchange_rate.dart';

abstract class CurrencyState extends Equatable {
  const CurrencyState();
  @override
  List<Object> get props => [];
}

class CurrencyInitial extends CurrencyState {}

class CurrencyLoading extends CurrencyState {}

class CurrencyRatesLoaded extends CurrencyState {
  final List<ExchangeRate> rates;
  const CurrencyRatesLoaded(this.rates);
  @override
  List<Object> get props => [rates];
}

class CurrencyConversionResult extends CurrencyState {
  final double result;
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  const CurrencyConversionResult({
    required this.result,
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
  });
  @override
  List<Object> get props => [result, fromCurrency, toCurrency, amount];
}

class CurrencyError extends CurrencyState {
  final String message;
  const CurrencyError(this.message);
  @override
  List<Object> get props => [message];
}