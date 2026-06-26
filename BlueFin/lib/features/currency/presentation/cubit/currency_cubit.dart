import 'package:flutter_bloc/flutter_bloc.dart';
import 'currency_state.dart';
import '../../domain/usecases/get_exchange_rates.dart';
import '../../domain/usecases/convert_currency.dart';
import '../../../../core/usecases/usecase.dart';

class CurrencyCubit extends Cubit<CurrencyState> {
  final GetExchangeRatesUseCase getExchangeRates;
  final ConvertCurrencyUseCase convertCurrency;

  CurrencyCubit({
    required this.getExchangeRates,
    required this.convertCurrency,
  }) : super(CurrencyInitial());

  Future<void> loadRates() async {
    emit(CurrencyLoading());
    final result = await getExchangeRates(NoParams());
    result.fold(
          (failure) => emit(CurrencyError(failure.message)),
          (rates) => emit(CurrencyRatesLoaded(rates)),
    );
  }

  Future<void> convert({
    required String from,
    required String to,
    required double amount,
  }) async {
    emit(CurrencyLoading());
    final result = await convertCurrency(
      ConvertCurrencyParams(
        fromCurrency: from,
        toCurrency: to,
        amount: amount,
      ),
    );
    result.fold(
          (failure) => emit(CurrencyError(failure.message)),
          (resultAmount) => emit(
        CurrencyConversionResult(
          result: resultAmount,
          fromCurrency: from,
          toCurrency: to,
          amount: amount,
        ),
      ),
    );
  }
}