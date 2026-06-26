import 'package:equatable/equatable.dart';

abstract class BalanceEvent extends Equatable {
  const BalanceEvent();
  @override
  List<Object> get props => [];
}

class BalanceLoadRequested extends BalanceEvent {}

class BalanceUpdateRequested extends BalanceEvent {
  final double newAmount;
  const BalanceUpdateRequested(this.newAmount);
  @override
  List<Object> get props => [newAmount];
}

class BalanceAddIncomeRequested extends BalanceEvent {
  final double amount;
  const BalanceAddIncomeRequested(this.amount);
  @override
  List<Object> get props => [amount];
}

class BalanceAddExpenseRequested extends BalanceEvent {
  final double amount;
  const BalanceAddExpenseRequested(this.amount);
  @override
  List<Object> get props => [amount];
}