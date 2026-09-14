import 'purchase_item.dart';

enum PurchaseType { main, midMonth }

enum PurchaseStatus { planned, completed }

class Purchase {
  const Purchase({
    required this.id,
    required this.date,
    required this.type,
    this.status = PurchaseStatus.completed,
    this.items = const [],
  });

  final String id;
  final DateTime date;
  final PurchaseType type;
  final PurchaseStatus status;
  final List<PurchaseItem> items;

  bool get isPlanned => status == PurchaseStatus.planned;

  int get totalItems => items.length;

  int get pricedItemCount => items.where((i) => i.unitPrice != null).length;

  double? get totalPrice {
    final priced = items.where((i) => i.unitPrice != null);
    if (priced.isEmpty) return null;
    return priced.fold<double>(0, (sum, i) => sum + i.totalPrice!);
  }

  double? get plannedTotalPrice {
    final planned = items.where((i) => i.plannedTotalPrice != null);
    if (planned.isEmpty) return null;
    return planned.fold<double>(0, (sum, i) => sum + i.plannedTotalPrice!);
  }

  bool get hasPlannedPrices => plannedTotalPrice != null;

  int get pickedCount => items.where((i) => i.picked).length;

  bool get isFullyPicked => items.isNotEmpty && pickedCount == items.length;

  double get pickedTotal => items
      .where((i) => i.picked && i.totalPrice != null)
      .fold<double>(0, (sum, i) => sum + i.totalPrice!);

  double? get totalDifference {
    final planned = plannedTotalPrice;
    final actual = totalPrice;
    if (planned == null || actual == null) return null;
    return actual - planned;
  }

  Purchase copyWith({
    String? id,
    DateTime? date,
    PurchaseType? type,
    PurchaseStatus? status,
    List<PurchaseItem>? items,
  }) {
    return Purchase(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      status: status ?? this.status,
      items: items ?? this.items,
    );
  }
}
