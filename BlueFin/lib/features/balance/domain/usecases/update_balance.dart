import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/balance.dart';
import '../repositories/i_balance_repository.dart';

class UpdateBalanceParams {
  final Balance balance;
  const UpdateBalanceParams(this.balance);
}

class UpdateBalanceUseCase implements UseCase<Balance, UpdateBalanceParams> {
  final IBalanceRepository repository;
  const UpdateBalanceUseCase(this.repository);

  @override
  Future<Either<Failure, Balance>> call(UpdateBalanceParams params) {
    return repository.updateBalance(params.balance);
  }
}