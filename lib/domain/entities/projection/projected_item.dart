import '../product.dart';

class ProjectedItem {
  const ProjectedItem({
    required this.product,
    required this.quantity,
    required this.currentQuantity,
    required this.idealQuantity,
    this.unitPrice,
    this.lastPriceDate,
    this.picked = false,
  });

  final Product product;
  final double quantity;
  final double currentQuantity;
  final double idealQuantity;
  final double? unitPrice;
  final DateTime? lastPriceDate;
  final bool picked;

  bool get hasPrice => unitPrice != null;

  double? get totalPrice => unitPrice == null ? null : unitPrice! * quantity;

  ProjectedItem copyWith({
    double? quantity,
    double? unitPrice,
    bool clearUnitPrice = false,
    bool? picked,
  }) {
    return ProjectedItem(
      product: product,
      quantity: quantity ?? this.quantity,
      currentQuantity: currentQuantity,
      idealQuantity: idealQuantity,
      unitPrice: clearUnitPrice ? null : (unitPrice ?? this.unitPrice),
      lastPriceDate: lastPriceDate,
      picked: picked ?? this.picked,
    );
  }
}
