import 'package:dartz/dartz.dart';
import 'package:BlueFin/core/errors/failures.dart';
import 'package:BlueFin/core/errors/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import '../models/token_model.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthLocalDataSource local;
  final IAuthRemoteDataSource remote;

  AuthRepositoryImpl(this.local, this.remote);

  @override
  Future<Either<Failure, User>> signIn(String email, String password) async {
    try {
      final (userModel, tokenModel) = await remote.signIn(email, password);
      await local.saveUserAndToken(userModel, tokenModel);
      await local.saveUserId(userModel.id);
      return Right(userModel.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signUp(String email, String password, String? name) async {
    try {
      final (userModel, tokenModel) = await remote.signUp(email, password, name);
      await local.saveUserAndToken(userModel, tokenModel);
      await local.saveUserId(userModel.id);
      return Right(userModel.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await local.getUser();
      if (user == null) {
        return Left(CacheFailure('Пользователь не найден'));
      }
      return Right(user.toDomain());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remote.signOut();
      await local.clearAll();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}