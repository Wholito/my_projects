import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/balance.dart';

abstract class IBalanceRepository {
  Future<Either<Failure, Balance>> getBalance();

  Future<Either<Failure, Balance>> updateBalance(Balance newBalance);
}