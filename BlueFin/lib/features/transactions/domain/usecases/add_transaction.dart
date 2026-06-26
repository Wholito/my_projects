import 'package:BlueFin/core/errors/failures.dart';
import 'package:BlueFin/core/usecases/usecase.dart';
import 'package:BlueFin/features/transactions/domain/entities/transaction.dart';
import 'package:BlueFin/features/transactions/domain/repositories/i_transaction_repository.dart';
import 'package:BlueFin/features/balance/domain/repositories/i_balance_repository.dart';
import 'package:dartz/dartz.dart';

class AddTransactionParams {
  final Transaction transaction;
  const AddTransactionParams(this.transaction);
}

class AddTransactionUseCase implements UseCase<void, AddTransactionParams> {
  final ITransactionRepository transactionRepository;
  final IBalanceRepository balanceRepository;

  AddTransactionUseCase({
    required this.transactionRepository,
    required this.balanceRepository,
  });

  @override
  Future<Either<Failure, void>> call(AddTransactionParams params) async {
    if (params.transaction.amount <= 0) {
      return Left(ServerFailure('Сумма должна быть больше нуля'));
    }

    final addResult = await transactionRepository.addTransaction(params.transaction);
    if (addResult.isLeft()) {
      return addResult;
    }

    final balanceResult = await balanceRepository.getBalance();
    return balanceResult.fold(
          (failure) => Left(failure),
          (currentBalance) async {
        if (params.transaction.type == TransactionType.expense &&
            !currentBalance.canSpend(params.transaction.amount)) {
          return Left(ServerFailure('Недостаточно средств'));
        }

        final newBalance = params.transaction.type == TransactionType.income
            ? currentBalance.addIncome(params.transaction.amount)
            : currentBalance.addExpense(params.transaction.amount);

        return balanceRepository.updateBalance(newBalance);
      },
    );
  }
}