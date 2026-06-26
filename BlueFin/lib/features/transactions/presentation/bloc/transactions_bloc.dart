import 'package:flutter_bloc/flutter_bloc.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';
import 'package:BlueFin/features/transactions/domain/usecases/get_transactions.dart';
import 'package:BlueFin/features/transactions/domain/usecases/add_transaction.dart';
import 'package:BlueFin/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:BlueFin/features/transactions/domain/usecases/update_transaction.dart';
import 'package:BlueFin/core/usecases/usecase.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final GetTransactionsUseCase getTransactions;
  final AddTransactionUseCase addTransaction;
  final DeleteTransactionUseCase deleteTransaction;
  final UpdateTransactionUseCase updateTransaction;

  TransactionsBloc({
    required this.getTransactions,
    required this.addTransaction,
    required this.deleteTransaction,
    required this.updateTransaction,
  }) : super(TransactionsInitial()) {
    on<TransactionsLoadRequested>(_onLoad);
    on<TransactionAddRequested>(_onAdd);
    on<TransactionDeleteRequested>(_onDelete);
    on<TransactionUpdateRequested>(_onUpdate);
  }

  Future<void> _onLoad(
      TransactionsLoadRequested event,
      Emitter<TransactionsState> emit,
      ) async {
    emit(TransactionsLoading());
    final result = await getTransactions(NoParams());
    result.fold(
          (failure) => emit(TransactionsError(failure.message)),
          (transactions) => emit(TransactionsLoaded(transactions)),
    );
  }

  Future<void> _onAdd(
      TransactionAddRequested event,
      Emitter<TransactionsState> emit,
      ) async {
    emit(TransactionsLoading());
    final result = await addTransaction(AddTransactionParams(event.transaction));
    result.fold(
          (failure) => emit(TransactionsError(failure.message)),
          (_) {
        add(TransactionsLoadRequested());
      },
    );
  }

  Future<void> _onDelete(
      TransactionDeleteRequested event,
      Emitter<TransactionsState> emit,
      ) async {
    emit(TransactionsLoading());
    final result = await deleteTransaction(DeleteTransactionParams(event.id));
    result.fold(
          (failure) => emit(TransactionsError(failure.message)),
          (_) {
        add(TransactionsLoadRequested());
      },
    );
  }

  Future<void> _onUpdate(
      TransactionUpdateRequested event,
      Emitter<TransactionsState> emit,
      ) async {
    emit(TransactionsLoading());
    final result = await updateTransaction(UpdateTransactionParams(event.transaction));
    result.fold(
          (failure) => emit(TransactionsError(failure.message)),
          (_) {
        add(TransactionsLoadRequested());
      },
    );
  }
}