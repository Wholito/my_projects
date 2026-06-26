import 'package:BlueFin/core/network/network_info.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/repositories/i_currency_repository.dart';
import '../datasources/currency_local_data_source.dart';
import '../datasources/currency_remote_data_source.dart';
import '../models/exchange_rate_model.dart';

class CurrencyRepositoryImpl implements ICurrencyRepository {
  final ICurrencyLocalDataSource local;
  final ICurrencyRemoteDataSource remote;
  final NetworkInfo networkInfo;

  CurrencyRepositoryImpl({
    required this.local,
    required this.remote,
    required this.networkInfo
  });

  @override
  Future<Either<Failure, List<ExchangeRate>>> getExchangeRates() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteRates = await remote.fetchRates();
        final domainRates = remoteRates.map((rate) => rate.toDomain()).toList();

        final modelsToSave = domainRates.map((r) =>
            ExchangeRateModel.fromDomain(r)).toList();
        await local.saveRates(modelsToSave);

        return Right(domainRates);
      } catch (e) {
        return await _getCachedRates();
      }
    } else return await _getCachedRates();
  }


   Future<Either<Failure, List<ExchangeRate>>> _getCachedRates() async{
    try{
      final localRates = await local.getRates();
      if (localRates.isNotEmpty) {
        return Right(localRates.map((model) => model.toDomain()).toList());
      } else return Left(ServerFailure('Нет сохраненных курсов'));
    } catch(e){
      return Left(CacheFailure('Нет сохраненных курсов'));
    }
   }

  @override
  Future<Either<Failure, double>> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    if (fromCurrency == toCurrency) {
      return Right(amount);
    }

    final ratesResult = await getExchangeRates();
    if (ratesResult.isLeft()) {
      return Left(ratesResult.fold((l) => l, (r) => throw Exception()));
    }

    final rates = ratesResult.fold((l) => <ExchangeRate>[], (r) => r);

    double amountInByn;

    if (fromCurrency == 'BYN') {
      amountInByn = amount;
    } else {
      final fromRate = rates.firstWhere(
            (r) => r.targetCurrency == fromCurrency,
        orElse: () => throw CacheFailure('Курс для $fromCurrency не найден'),
      );
      amountInByn = amount * fromRate.rate;
    }

    if (toCurrency == 'BYN') {
      return Right(amountInByn);
    } else {
      final toRate = rates.firstWhere(
            (r) => r.targetCurrency == toCurrency,
        orElse: () => throw CacheFailure('Курс для $toCurrency не найден'),
      );
      return Right(amountInByn / toRate.rate);
    }
  }

  @override
  Future<Either<Failure, void>> updateRate(ExchangeRate rate) async {
    try {
      final models = await local.getRates();
      final index = models.indexWhere(
            (r) => r.baseCurrency == rate.baseCurrency && r.targetCurrency == rate.targetCurrency,
      );
      if (index == -1) {
        models.add(ExchangeRateModel.fromDomain(rate));
      } else {
        models[index] = ExchangeRateModel.fromDomain(rate);
      }
      await local.saveRates(models);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}