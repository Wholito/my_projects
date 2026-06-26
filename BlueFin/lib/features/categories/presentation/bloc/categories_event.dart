import 'package:BlueFin/features/categories/domain/entities/category.dart';
import 'package:equatable/equatable.dart';

abstract class CategoriesEvent extends Equatable{
  const CategoriesEvent();
  @override
  List<Object> get props => [];
}

class CategoryAddRequested extends CategoriesEvent {
  final Category category;
  CategoryAddRequested(this.category);

  @override
  List<Object> get props => [category];
}

class CategoryUpdateRequested extends CategoriesEvent{
  final Category category;
  CategoryUpdateRequested(this.category);

  @override
  List<Object> get props => [category];
}

class CategoryDeleteRequested extends CategoriesEvent{
  final String id;
  CategoryDeleteRequested(this.id);

  @override
  List<Object> get props => [id];
}

class CategoryLoadRequested extends CategoriesEvent{}