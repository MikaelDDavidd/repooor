import '../../domain/entities/purchase_item.dart';

class PurchaseItemModel {
  const PurchaseItemModel({
    required this.id,
    required this.purchaseId,
    required this.productId,
    required this.quantity,
    this.unitPrice,
    this.plannedQuantity,
    this.plannedUnitPrice,
    this.picked = 0,
  });

  final String id;
  final String purchaseId;
  final String productId;
  final double quantity;
  final double? unitPrice;
  final double? plannedQuantity;
  final double? plannedUnitPrice;
  final int picked;

  static double? _toDouble(Object? raw) =>
      raw == null ? null : (raw as num).toDouble();

  factory PurchaseItemModel.fromMap(Map<String, dynamic> map) {
    return PurchaseItemModel(
      id: map['id'] as String,
      purchaseId: map['purchase_id'] as String,
      productId: map['product_id'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unitPrice: _toDouble(map['unit_price']),
      plannedQuantity: _toDouble(map['planned_quantity']),
      plannedUnitPrice: _toDouble(map['planned_unit_price']),
      picked: (map['picked'] as num?)?.toInt() ?? 0,
    );
  }

  factory PurchaseItemModel.fromEntity(PurchaseItem entity) {
    return PurchaseItemModel(
      id: entity.id,
      purchaseId: entity.purchaseId,
      productId: entity.productId,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      plannedQuantity: entity.plannedQuantity,
      plannedUnitPrice: entity.plannedUnitPrice,
      picked: entity.picked ? 1 : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_id': purchaseId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'planned_quantity': plannedQuantity,
      'planned_unit_price': plannedUnitPrice,
      'picked': picked,
    };
  }

  Map<String, dynamic> toRemoteMap({required int updatedAt}) {
    return {
      'purchaseId': purchaseId,
      'productId': productId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'plannedQuantity': plannedQuantity,
      'plannedUnitPrice': plannedUnitPrice,
      'picked': picked == 1,
      'updatedAt': updatedAt,
    };
  }

  PurchaseItem toEntity() {
    return PurchaseItem(
      id: id,
      purchaseId: purchaseId,
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      plannedQuantity: plannedQuantity,
      plannedUnitPrice: plannedUnitPrice,
      picked: picked == 1,
    );
  }
}
