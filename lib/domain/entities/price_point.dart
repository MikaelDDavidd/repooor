class PricePoint {
  const PricePoint({
    required this.date,
    required this.unitPrice,
    required this.quantity,
  });

  final DateTime date;
  final double unitPrice;
  final double quantity;
}
