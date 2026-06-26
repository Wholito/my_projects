import 'package:equatable/equatable.dart';
import 'package:BlueFin/features/transactions/domain/entities/transaction.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();
  @override
  List<Object> get props => [];
}

class TransactionsLoadRequested extends TransactionsEvent {}

class TransactionAddRequested extends TransactionsEvent {
  final Transaction transaction;
  const TransactionAddRequested(this.transaction);
  @override
  List<Object> get props => [transaction];
}

class TransactionDeleteRequested extends TransactionsEvent {
  final String id;
  const TransactionDeleteRequested(this.id);
  @override
  List<Object> get props => [id];
}

class TransactionUpdateRequested extends TransactionsEvent {
  final Transaction transaction;
  const TransactionUpdateRequested(this.transaction);
  @override
  List<Object> get props => [transaction];
}