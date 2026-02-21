import '../../domain/entities/product.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.unit,
  });

  final String id;
  final String name;
  final String categoryId;
  final String unit;

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      categoryId: map['category_id'] as String,
      unit: map['unit'] as String,
    );
  }

  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      categoryId: entity.categoryId,
      unit: entity.unit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'unit': unit,
    };
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      categoryId: categoryId,
      unit: unit,
    );
  }
}
