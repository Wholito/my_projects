import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_currency_repository.dart';

class ConvertCurrencyParams {
  final String fromCurrency;
  final String toCurrency;
  final double amount;

  const ConvertCurrencyParams({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
  });
}

class ConvertCurrencyUseCase implements UseCase<double, ConvertCurrencyParams> {
  final ICurrencyRepository repository;
  const ConvertCurrencyUseCase(this.repository);

  @override
  Future<Either<Failure, double>> call(ConvertCurrencyParams params) {
    return repository.convertCurrency(
      fromCurrency: params.fromCurrency,
      toCurrency: params.toCurrency,
      amount: params.amount,
    );
  }
}