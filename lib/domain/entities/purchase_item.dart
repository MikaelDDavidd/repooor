class PurchaseItem {
  const PurchaseItem({
    required this.id,
    required this.purchaseId,
    required this.productId,
    required this.quantity,
    this.unitPrice,
    this.plannedQuantity,
    this.plannedUnitPrice,
    this.picked = false,
  });

  final String id;
  final String purchaseId;
  final String productId;
  final double quantity;
  final double? unitPrice;
  final double? plannedQuantity;
  final double? plannedUnitPrice;
  final bool picked;

  double? get totalPrice => unitPrice == null ? null : unitPrice! * quantity;

  double? get plannedTotalPrice =>
      plannedQuantity == null || plannedUnitPrice == null
      ? null
      : plannedUnitPrice! * plannedQuantity!;

  bool get wasPlanned => plannedQuantity != null;

  double? get priceDifference {
    final planned = plannedTotalPrice;
    final actual = totalPrice;
    if (planned == null || actual == null) return null;
    return actual - planned;
  }

  PurchaseItem copyWith({
    String? id,
    String? purchaseId,
    String? productId,
    double? quantity,
    double? unitPrice,
    bool clearUnitPrice = false,
    double? plannedQuantity,
    double? plannedUnitPrice,
    bool? picked,
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: clearUnitPrice ? null : (unitPrice ?? this.unitPrice),
      plannedQuantity: plannedQuantity ?? this.plannedQuantity,
      plannedUnitPrice: plannedUnitPrice ?? this.plannedUnitPrice,
      picked: picked ?? this.picked,
    );
  }
}
