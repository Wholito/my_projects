import 'package:BlueFin/core/errors/failures.dart';
import 'package:BlueFin/core/usecases/usecase.dart';
import 'package:BlueFin/features/categories/domain/entities/category.dart';
import 'package:BlueFin/features/categories/domain/repositories/i_category_repository.dart';
import 'package:dartz/dartz.dart';

class GetCategoriesUseCase implements UseCase<List<Category>, NoParams> {
  final ICategoryRepository repository;
  const GetCategoriesUseCase(this.repository);
  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) {
    return repository.getCategories();
  }
}