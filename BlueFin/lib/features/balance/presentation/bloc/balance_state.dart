import 'package:equatable/equatable.dart';
import '../../domain/entities/balance.dart';

abstract class BalanceState extends Equatable {
  const BalanceState();
  @override
  List<Object> get props => [];
}

class BalanceInitial extends BalanceState {}

class BalanceLoading extends BalanceState {}

class BalanceLoaded extends BalanceState {
  final Balance balance;
  const BalanceLoaded(this.balance);
  @override
  List<Object> get props => [balance];
}

class BalanceError extends BalanceState {
  final String message;
  const BalanceError(this.message);
  @override
  List<Object> get props => [message];
}