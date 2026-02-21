class PantryItem {
  const PantryItem({
    required this.id,
    required this.productId,
    required this.currentQuantity,
    required this.idealQuantity,
  });

  final String id;
  final String productId;
  final double currentQuantity;
  final double idealQuantity;

  double get stockRatio =>
      idealQuantity > 0 ? currentQuantity / idealQuantity : 1.0;

  bool get isLowStock => stockRatio < 0.5;
  bool get isMediumStock => stockRatio >= 0.5 && stockRatio < 1.0;
  bool get isFullStock => stockRatio >= 1.0;

  double get deficit =>
      idealQuantity > currentQuantity ? idealQuantity - currentQuantity : 0;

  PantryItem copyWith({
    String? id,
    String? productId,
    double? currentQuantity,
    double? idealQuantity,
  }) {
    return PantryItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      idealQuantity: idealQuantity ?? this.idealQuantity,
    );
  }
}
