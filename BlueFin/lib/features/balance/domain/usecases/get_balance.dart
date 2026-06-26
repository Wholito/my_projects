import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/balance.dart';
import '../repositories/i_balance_repository.dart';

class GetBalanceUseCase implements UseCase<Balance, NoParams> {
  final IBalanceRepository repository;
  const GetBalanceUseCase(this.repository);

  @override
  Future<Either<Failure, Balance>> call(NoParams params) {
    return repository.getBalance();
  }
}