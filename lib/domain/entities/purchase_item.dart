class PurchaseItem {
  const PurchaseItem({
    required this.id,
    required this.purchaseId,
    required this.productId,
    required this.quantity,
  });

  final String id;
  final String purchaseId;
  final String productId;
  final double quantity;

  PurchaseItem copyWith({
    String? id,
    String? purchaseId,
    String? productId,
    double? quantity,
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
    );
  }
}
