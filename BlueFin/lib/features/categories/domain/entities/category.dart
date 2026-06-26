import '../../../transactions/domain/entities/transaction.dart';

class Category {
  final String id;
  final String name;
  final TransactionType type;

  const Category({
    required this.id,
    required this.name,
    required this.type,
  });

  Category copyWith({
    String? id,
    String? name,
    TransactionType? type,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type;

  @override
  int get hashCode => Object.hash(name,type);

  String get transactionType => '$this.type';
}
