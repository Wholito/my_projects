import 'package:BlueFin/core/usecases/usecase.dart';
import 'package:BlueFin/features/categories/domain/entities/category.dart';
import 'package:BlueFin/features/categories/domain/usecases/add_category.dart';
import 'package:BlueFin/features/categories/domain/usecases/delete_category.dart';
import 'package:BlueFin/features/categories/domain/usecases/get_categories.dart';
import 'package:BlueFin/features/categories/domain/usecases/update_category.dart';
import 'package:BlueFin/features/categories/presentation/bloc/categories_event.dart';
import 'package:BlueFin/features/categories/presentation/bloc/categories_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final AddCategoryUseCase addCategory;
  final DeleteCategoryUseCase deleteCategory;
  final GetCategoriesUseCase getCategories;
  final UpdateCategoryUseCase updateCategory;

  CategoriesBloc({
    required this.addCategory,
    required this.deleteCategory,
    required this.getCategories,
    required this.updateCategory,
  }) : super(CategoriesInitial()) {
    on<CategoryLoadRequested>(_onLoad);
    on<CategoryAddRequested>(_onAdd);
    on<CategoryDeleteRequested>(_onDelete);
    on<CategoryUpdateRequested>(_onUpdate);
  }

  Future<void> _onLoad(
      CategoryLoadRequested event,
      Emitter<CategoriesState> emit,
      ) async {
    emit(CategoriesLoading());
    final result = await getCategories(NoParams());
    result.fold(
          (failure) => emit(CategoriesError(failure.message)),
          (categories) => emit(CategoriesLoaded(categories)),
    );
  }

  Future<void> _onAdd(
      CategoryAddRequested event,
      Emitter<CategoriesState> emit,
      ) async {
    emit(CategoriesLoading());
    final result = await addCategory(AddCategoryParams(event.category));
    result.fold(
          (failure) => emit(CategoriesError(failure.message)),
          (_) {
        add(CategoryLoadRequested());
      },
    );
  }

  Future<void> _onDelete(
      CategoryDeleteRequested event,
      Emitter<CategoriesState> emit,
      ) async {
    emit(CategoriesLoading());
    final result = await deleteCategory(DeleteCategoryParams(event.id));
    result.fold(
          (failure) => emit(CategoriesError(failure.message)),
          (_) {
        add(CategoryLoadRequested());
      },
    );
  }

  Future<void> _onUpdate(
      CategoryUpdateRequested event,
      Emitter<CategoriesState> emit,
      ) async {
    emit(CategoriesLoading());
    final result = await updateCategory(UpdateCategoryParams(event.category));
    result.fold(
          (failure) => emit(CategoriesError(failure.message)),
          (_) {
        add(CategoryLoadRequested());
      },
    );
  }
}