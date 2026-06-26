import 'package:BlueFin/core/errors/failures.dart';
import 'package:BlueFin/features/categories/domain/entities/category.dart';
import 'package:BlueFin/features/categories/domain/entities/category.dart';
import 'package:BlueFin/features/transactions/domain/entities/transaction.dart';
import 'package:dartz/dartz.dart';

abstract class ICategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, void>> addCategory(Category category);
  Future<Either<Failure, void>> updateCategory(Category category);
  Future<Either<Failure, void>> deleteCategory(String id);
}