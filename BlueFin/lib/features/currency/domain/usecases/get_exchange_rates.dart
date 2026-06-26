import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/exchange_rate.dart';
import '../repositories/i_currency_repository.dart';

class GetExchangeRatesUseCase implements UseCase<List<ExchangeRate>, NoParams> {
  final ICurrencyRepository repository;
  const GetExchangeRatesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ExchangeRate>>> call(NoParams params) {
    return repository.getExchangeRates();
  }
}