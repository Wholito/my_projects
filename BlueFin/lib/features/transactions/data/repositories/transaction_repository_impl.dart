import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import '../datasources/transaction_local_data_source.dart';
import '../models/transaction_model.dart';

import 'package:dartz/dartz.dart';
import 'package:BlueFin/core/errors/failures.dart';
import 'package:BlueFin/core/errors/exceptions.dart';
import 'package:BlueFin/core/network/network_info.dart';
import 'package:BlueFin/core/services/user_id_provider.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import '../datasources/transaction_local_data_source.dart';
import '../datasources/transaction_remote_data_source.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements ITransactionRepository {
  final ITransactionLocalDataSource local;
  final ITransactionRemoteDataSource remote;
  final NetworkInfo networkInfo;
  final UserIdProvider userIdProvider;

  TransactionRepositoryImpl({
    required this.local,
    required this.remote,
    required this.networkInfo,
    required this.userIdProvider,
  });

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    final userId = userIdProvider.userId;
    if (userId.isEmpty) return Left(CacheFailure('Пользователь не авторизован'));

    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteList = await remote.fetchTransactions(userId);
          await local.saveTransactions(remoteList);
          return Right(remoteList.map((e) => e.toDomain()).toList());
        } catch (e) {
          return _getLocalTransactions();
        }
      } else {
        return _getLocalTransactions();
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Transaction>>> _getLocalTransactions() async {
    try {
      final list = await local.getTransactions();
      return Right(list.map((e) => e.toDomain()).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(Transaction transaction) async {
    final userId = userIdProvider.userId;
    if (userId.isEmpty) return Left(CacheFailure('Пользователь не авторизован'));

    try {
      final model = TransactionModel.fromDomain(transaction);
      final list = await local.getTransactions();
      list.add(model);
      await local.saveTransactions(list);

      if (await networkInfo.isConnected) {
        try {
          await remote.addTransaction(model, userId);
        } catch (e) {
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    final userId = userIdProvider.userId;
    if (userId.isEmpty) return Left(CacheFailure('Пользователь не авторизован'));

    try {
      final list = await local.getTransactions();
      list.removeWhere((e) => e.id == id);
      await local.saveTransactions(list);

      if (await networkInfo.isConnected) {
        try {
          await remote.deleteTransaction(id, userId);
        } catch (e) {
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(Transaction transaction) async {
    final userId = userIdProvider.userId;
    if (userId.isEmpty) return Left(CacheFailure('Пользователь не авторизован'));

    try {
      final model = TransactionModel.fromDomain(transaction);
      final list = await local.getTransactions();
      final index = list.indexWhere((e) => e.id == transaction.id);
      if (index != -1) {
        list[index] = model;
        await local.saveTransactions(list);
      }

      if (await networkInfo.isConnected) {
        try {
          await remote.updateTransaction(model, userId);
        } catch (e) {
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}