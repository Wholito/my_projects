import 'package:flutter_bloc/flutter_bloc.dart';
import 'balance_event.dart';
import 'balance_state.dart';
import '../../../domain/usecases/get_balance.dart';
import '../../../domain/usecases/add_income.dart';
import '../../../domain/usecases/add_expense.dart';
import '../../../domain/usecases/update_balance.dart';
import '../../../../core/usecases/usecase.dart';

class BalanceBloc extends Bloc<BalanceEvent, BalanceState> {
  final GetBalanceUseCase getBalance;
  final UpdateBalanceUseCase updateBalance;
  final AddIncomeUseCase addIncome;
  final AddExpenseUseCase addExpense;

  BalanceBloc({
    required this.getBalance,
    required this.updateBalance,
    required this.addIncome,
    required this.addExpense,
  }) : super(BalanceInitial()) {
    on<BalanceLoadRequested>(_onLoad);
    on<BalanceUpdateRequested>(_onUpdate);
    on<BalanceAddIncomeRequested>(_onAddIncome);
    on<BalanceAddExpenseRequested>(_onAddExpense);
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
    // Для обновления надо сначала получить текущий баланс, чтобы сохранить валюту и дату
    final currentResult = await getBalance(NoParams());
    await currentResult.fold(
      (failure) => emit(BalanceError(failure.message)),
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

  Future<void> _onAddIncome(
    BalanceAddIncomeRequested event,
    Emitter<BalanceState> emit,
  ) async {
    emit(BalanceLoading());
    final result = await addIncome(AddIncomeParams(event.amount));
    result.fold(
      (failure) => emit(BalanceError(failure.message)),
      (updated) => emit(BalanceLoaded(updated)),
    );
  }

  Future<void> _onAddExpense(
    BalanceAddExpenseRequested event,
    Emitter<BalanceState> emit,
  ) async {
    emit(BalanceLoading());
    final result = await addExpense(AddExpenseParams(event.amount));
    result.fold(
      (failure) => emit(BalanceError(failure.message)),
      (updated) => emit(BalanceLoaded(updated)),
    );
  }
}