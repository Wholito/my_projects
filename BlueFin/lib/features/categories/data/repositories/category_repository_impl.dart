import 'package:dartz/dartz.dart';
import 'package:BlueFin/core/errors/failures.dart';
import 'package:BlueFin/core/errors/exceptions.dart';
import 'package:BlueFin/core/network/network_info.dart';
import 'package:BlueFin/core/services/user_id_provider.dart';
import 'package:BlueFin/features/categories/domain/entities/category.dart';
import 'package:BlueFin/features/categories/domain/repositories/i_category_repository.dart';
import '../datasources/category_local_data_source.dart';
import '../datasources/category_remote_data_source.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements ICategoryRepository {
  final ICategoryLocalDataSource local;
  final ICategoryRemoteDataSource remote;
  final NetworkInfo networkInfo;
  final UserIdProvider userIdProvider;

  CategoryRepositoryImpl({
    required this.local,
    required this.remote,
    required this.networkInfo,
    required this.userIdProvider,
  });

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    final userId = userIdProvider.userId;
    if (userId.isEmpty) return Left(CacheFailure('Пользователь не авторизован'));

    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteList = await remote.fetchCategories(userId);
          await local.saveCategories(remoteList);
          return Right(remoteList.map((e) => e.toDomain()).toList());
        } catch (e) {
          return _getLocalCategories();
        }
      } else {
        return _getLocalCategories();
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Category>>> _getLocalCategories() async {
    try {
      final list = await local.getCategories();
      return Right(list.map((e) => e.toDomain()).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addCategory(Category category) async {
    final userId = userIdProvider.userId;
    if (userId.isEmpty) return Left(CacheFailure('Пользователь не авторизован'));

    try {
      final model = CategoryModel.fromDomain(category);
      final list = await local.getCategories();
      list.add(model);
      await local.saveCategories(list);

      if (await networkInfo.isConnected) {
        try {
          await remote.addCategory(model, userId);
        } catch (e) {
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(Category category) async {
    final userId = userIdProvider.userId;
    if (userId.isEmpty) return Left(CacheFailure('Пользователь не авторизован'));

    try {
      final model = CategoryModel.fromDomain(category);
      final list = await local.getCategories();
      final index = list.indexWhere((e) => e.id == category.id);
      if (index != -1) {
        list[index] = model;
        await local.saveCategories(list);
      }

      if (await networkInfo.isConnected) {
        try {
          await remote.updateCategory(model, userId);
        } catch (e) {
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    final userId = userIdProvider.userId;
    if (userId.isEmpty) return Left(CacheFailure('Пользователь не авторизован'));

    try {
      final list = await local.getCategories();
      list.removeWhere((e) => e.id == id);
      await local.saveCategories(list);

      if (await networkInfo.isConnected) {
        try {
          await remote.deleteCategory(id, userId);
        } catch (e) {
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}