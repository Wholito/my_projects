import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/balance.dart';
import '../repositories/i_balance_repository.dart';

class AddExpenseParams {
  final double amount;
  const AddExpenseParams(this.amount);
}

class AddExpenseUseCase implements UseCase<Balance, AddExpenseParams> {
  final IBalanceRepository repository;
  const AddExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, Balance>> call(AddExpenseParams params) async {
    final result = await repository.getBalance();
    return result.fold(
          (failure) => Left(failure),
          (balance) {
        if (!balance.canSpend(params.amount)) {
          return Left(ServerFailure('Недостаточно средств'));
        }
        final newBalance = balance.addExpense(params.amount);
        return repository.updateBalance(newBalance);
      },
    );
  }
}