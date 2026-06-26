import 'package:BlueFin/core/errors/failures.dart';
import 'package:BlueFin/core/usecases/usecase.dart';
import 'package:BlueFin/features/categories/domain/entities/category.dart';
import 'package:BlueFin/features/categories/domain/repositories/i_category_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteCategoryParams{
    final String id;
    const DeleteCategoryParams(this.id);
}

class DeleteCategoryUseCase implements UseCase<void, DeleteCategoryParams> {
  final ICategoryRepository repository;
  const DeleteCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteCategoryParams params) {
    return repository.deleteCategory(params.id);
  }

}