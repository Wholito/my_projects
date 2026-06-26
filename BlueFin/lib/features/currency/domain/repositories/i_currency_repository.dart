import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/exchange_rate.dart';

abstract class ICurrencyRepository {
  Future<Either<Failure, List<ExchangeRate>>> getExchangeRates();

  Future<Either<Failure, double>> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  });

  Future<Either<Failure, void>> updateRate(ExchangeRate rate);
}