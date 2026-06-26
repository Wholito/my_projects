import 'package:BlueFin/core/errors/failures.dart';
import 'package:BlueFin/core/usecases/usecase.dart';
import 'package:BlueFin/features/categories/domain/entities/category.dart';
import 'package:BlueFin/features/categories/domain/repositories/i_category_repository.dart';
import 'package:dartz/dartz.dart';

class AddCategoryParams {
  final Category category;
  const AddCategoryParams(this.category);
}

class AddCategoryUseCase implements UseCase<void, AddCategoryParams> {
  final ICategoryRepository repository;
  AddCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddCategoryParams params) {
    return repository.addCategory(params.category);
  }
}