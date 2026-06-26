import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/i_transaction_repository.dart';

class UpdateTransactionParams {
  final Transaction transaction;
  const UpdateTransactionParams(this.transaction);
}

class UpdateTransactionUseCase implements UseCase<void, UpdateTransactionParams> {
  final ITransactionRepository repository;
  const UpdateTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateTransactionParams params) {
    return repository.updateTransaction(params.transaction);
  }
}