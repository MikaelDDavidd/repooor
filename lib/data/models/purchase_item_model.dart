import '../../domain/entities/purchase_item.dart';

class PurchaseItemModel {
  const PurchaseItemModel({
    required this.id,
    required this.purchaseId,
    required this.productId,
    required this.quantity,
  });

  final String id;
  final String purchaseId;
  final String productId;
  final double quantity;

  factory PurchaseItemModel.fromMap(Map<String, dynamic> map) {
    return PurchaseItemModel(
      id: map['id'] as String,
      purchaseId: map['purchase_id'] as String,
      productId: map['product_id'] as String,
      quantity: (map['quantity'] as num).toDouble(),
    );
  }

  factory PurchaseItemModel.fromEntity(PurchaseItem entity) {
    return PurchaseItemModel(
      id: entity.id,
      purchaseId: entity.purchaseId,
      productId: entity.productId,
      quantity: entity.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_id': purchaseId,
      'product_id': productId,
      'quantity': quantity,
    };
  }

  PurchaseItem toEntity() {
    return PurchaseItem(
      id: id,
      purchaseId: purchaseId,
      productId: productId,
      quantity: quantity,
    );
  }
}
