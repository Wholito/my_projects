import 'package:BlueFin/core/errors/failures.dart';
import 'package:BlueFin/core/usecases/usecase.dart';
import 'package:BlueFin/features/categories/domain/entities/category.dart';
import 'package:BlueFin/features/categories/domain/repositories/i_category_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateCategoryParams {
  final Category category;
  const UpdateCategoryParams(this.category);
}

class UpdateCategoryUseCase implements UseCase<void, UpdateCategoryParams> {
  final ICategoryRepository repository;
  const UpdateCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateCategoryParams params) {
    return repository.updateCategory(params.category);
  }

}