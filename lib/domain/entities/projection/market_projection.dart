import 'projected_item.dart';

class MarketProjection {
  const MarketProjection({this.items = const []});

  final List<ProjectedItem> items;

  bool get isEmpty => items.isEmpty;

  int get totalItems => items.length;

  int get itemsWithoutPrice => items.where((i) => !i.hasPrice).length;

  bool get isPartial => itemsWithoutPrice > 0;

  double get estimatedTotal => items
      .where((i) => i.totalPrice != null)
      .fold<double>(0, (sum, i) => sum + i.totalPrice!);

  int get pickedCount => items.where((i) => i.picked).length;

  bool get isFullyPicked => items.isNotEmpty && pickedCount == items.length;

  double get pickedTotal => items
      .where((i) => i.picked && i.totalPrice != null)
      .fold<double>(0, (sum, i) => sum + i.totalPrice!);

  MarketProjection replaceItem(int index, ProjectedItem item) {
    final updated = [...items]..[index] = item;
    return MarketProjection(items: updated);
  }

  MarketProjection removeItem(int index) {
    final updated = [...items]..removeAt(index);
    return MarketProjection(items: updated);
  }
}
