import 'package:BlueFin/features/categories/domain/entities/category.dart';
import 'package:BlueFin/features/categories/presentation/bloc/categories_event.dart';
import 'package:equatable/equatable.dart';

abstract class CategoriesState extends Equatable{
  const CategoriesState();

  @override
  List<Object> get props => [];
}

class CategoriesInitial extends CategoriesState{

}

class CategoriesLoading extends CategoriesState{

}

class CategoriesLoaded extends CategoriesState{
  final List<Category> categories;
  const CategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class CategoriesError extends CategoriesState{
  final String message;
  const CategoriesError(this.message);

  @override
  List<Object> get props => [message];
}

class CategoriesOperationSuccess extends CategoriesState{
  final String message;
  const CategoriesOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}