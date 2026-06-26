import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/balance.dart';
import '../repositories/i_balance_repository.dart';

class AddIncomeParams {
  final double amount;
  const AddIncomeParams(this.amount);
}

class AddIncomeUseCase implements UseCase<Balance, AddIncomeParams> {
  final IBalanceRepository repository;
  const AddIncomeUseCase(this.repository);

  @override
  Future<Either<Failure, Balance>> call(AddIncomeParams params) async {
    final result = await repository.getBalance();
    return result.fold(
          (failure) => Left(failure),
          (balance) {
        final newBalance = balance.addIncome(params.amount);
        return repository.updateBalance(newBalance);
      },
    );
  }
}