import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_transaction_repository.dart';

class DeleteTransactionParams {
  final String id;
  const DeleteTransactionParams(this.id);
}

class DeleteTransactionUseCase implements UseCase<void, DeleteTransactionParams> {
  final ITransactionRepository repository;
  const DeleteTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTransactionParams params) {
    return repository.deleteTransaction(params.id);
  }
}