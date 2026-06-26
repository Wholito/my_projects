import 'package:dartz/dartz.dart';
import 'package:BlueFin/core/errors/failures.dart';
import 'package:BlueFin/core/errors/exceptions.dart';
import 'package:BlueFin/core/network/network_info.dart';
import 'package:BlueFin/core/services/user_id_provider.dart';
import 'package:BlueFin/features/balance/domain/entities/balance.dart';
import 'package:BlueFin/features/balance/domain/repositories/i_balance_repository.dart';
import '../datasources/balance_local_data_source.dart';
import '../datasources/balance_remote_data_source.dart';
import '../models/balance_model.dart';

class BalanceRepositoryImpl implements IBalanceRepository {
  final IBalanceLocalDataSource local;
  final IBalanceRemoteDataSource remote;
  final NetworkInfo networkInfo;
  final UserIdProvider userIdProvider;

  BalanceRepositoryImpl({
    required this.local,
    required this.remote,
    required this.networkInfo,
    required this.userIdProvider,
  });

  @override
  Future<Either<Failure, Balance>> getBalance() async {
    final userId = userIdProvider.userId;
    if (userId.isEmpty) return Left(CacheFailure('Пользователь не авторизован'));

    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteBalance = await remote.fetchBalance(userId);
          await local.saveBalance(remoteBalance);
          return Right(remoteBalance.toDomain());
        } catch (e) {
          return _getLocalBalance();
        }
      } else {
        return _getLocalBalance();
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<Either<Failure, Balance>> _getLocalBalance() async {
    try {
      final localBalance = await local.getBalance();
      if (localBalance != null) {
        return Right(localBalance.toDomain());
      }
      final initial = Balance.initial('BYN');
      await local.saveBalance(BalanceModel.fromDomain(initial));
      return Right(initial);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Balance>> updateBalance(Balance newBalance) async {
    final userId = userIdProvider.userId;
    if (userId.isEmpty) return Left(CacheFailure('Пользователь не авторизован'));

    try {
      final model = BalanceModel.fromDomain(newBalance);
      await local.saveBalance(model);

      if (await networkInfo.isConnected) {
        try {
          await remote.updateBalance(model, userId);
        } catch (e) {
        }
      }
      return Right(newBalance);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}