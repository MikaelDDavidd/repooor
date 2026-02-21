import 'purchase_item.dart';

enum PurchaseType { main, midMonth }

class Purchase {
  const Purchase({
    required this.id,
    required this.date,
    required this.type,
    this.items = const [],
  });

  final String id;
  final DateTime date;
  final PurchaseType type;
  final List<PurchaseItem> items;

  int get totalItems => items.length;

  Purchase copyWith({
    String? id,
    DateTime? date,
    PurchaseType? type,
    List<PurchaseItem>? items,
  }) {
    return Purchase(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      items: items ?? this.items,
    );
  }
}
