class NfceRawItem {
  const NfceRawItem({
    required this.rawName,
    required this.quantity,
    required this.unitRaw,
    this.code,
    this.unitPrice,
  });

  final String rawName;
  final double quantity;
  final String unitRaw;
  final String? code;
  final double? unitPrice;

  double? get totalPrice => unitPrice == null ? null : unitPrice! * quantity;
}
