import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/i_transaction_repository.dart';

class GetTransactionsUseCase implements UseCase<List<Transaction>, NoParams> {
  final ITransactionRepository repository;
  const GetTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Transaction>>> call(NoParams params) {
    return repository.getTransactions();
  }
}