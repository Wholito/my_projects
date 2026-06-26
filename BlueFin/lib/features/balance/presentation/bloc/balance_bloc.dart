import 'package:flutter_bloc/flutter_bloc.dart';
import 'balance_event.dart';
import 'balance_state.dart';
import '../../domain/usecases/get_balance.dart';
import '../../domain/usecases/update_balance.dart';
import '../../../../core/usecases/usecase.dart';

class BalanceBloc extends Bloc<BalanceEvent, BalanceState> {
  final GetBalanceUseCase getBalance;
  final UpdateBalanceUseCase updateBalance;

  BalanceBloc({
    required this.getBalance,
    required this.updateBalance,
  }) : super(BalanceInitial()) {
    on<BalanceLoadRequested>(_onLoad);
    on<BalanceUpdateRequested>(_onUpdate);
  }

  Future<void> _onLoad(
      BalanceLoadRequested event,
      Emitter<BalanceState> emit,
      ) async {
    emit(BalanceLoading());
    final result = await getBalance(NoParams());
    result.fold(
          (failure) => emit(BalanceError(failure.message)),
          (balance) => emit(BalanceLoaded(balance)),
    );
  }

  Future<void> _onUpdate(
      BalanceUpdateRequested event,
      Emitter<BalanceState> emit,
      ) async {
    emit(BalanceLoading());
    final currentResult = await getBalance(NoParams());
    await currentResult.fold(
          (failure) async => emit(BalanceError(failure.message)),
          (currentBalance) async {
        final newBalance = currentBalance.copyWith(
          amount: event.newAmount,
          updatedAt: DateTime.now(),
        );
        final result = await updateBalance(UpdateBalanceParams(newBalance));
        result.fold(
              (failure) => emit(BalanceError(failure.message)),
              (updated) => emit(BalanceLoaded(updated)),
        );
      },
    );
  }
}