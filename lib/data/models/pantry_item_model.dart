import '../../domain/entities/pantry_item.dart';

class PantryItemModel {
  const PantryItemModel({
    required this.id,
    required this.productId,
    required this.currentQuantity,
    required this.idealQuantity,
  });

  final String id;
  final String productId;
  final double currentQuantity;
  final double idealQuantity;

  factory PantryItemModel.fromMap(Map<String, dynamic> map) {
    return PantryItemModel(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      currentQuantity: (map['current_quantity'] as num).toDouble(),
      idealQuantity: (map['ideal_quantity'] as num).toDouble(),
    );
  }

  factory PantryItemModel.fromEntity(PantryItem entity) {
    return PantryItemModel(
      id: entity.id,
      productId: entity.productId,
      currentQuantity: entity.currentQuantity,
      idealQuantity: entity.idealQuantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'current_quantity': currentQuantity,
      'ideal_quantity': idealQuantity,
    };
  }

  PantryItem toEntity() {
    return PantryItem(
      id: id,
      productId: productId,
      currentQuantity: currentQuantity,
      idealQuantity: idealQuantity,
    );
  }
}
