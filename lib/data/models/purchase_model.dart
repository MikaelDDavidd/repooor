import '../../domain/entities/purchase.dart';
import '../../domain/entities/purchase_item.dart';

class PurchaseModel {
  const PurchaseModel({
    required this.id,
    required this.date,
    required this.type,
  });

  final String id;
  final String date;
  final String type;

  factory PurchaseModel.fromMap(Map<String, dynamic> map) {
    return PurchaseModel(
      id: map['id'] as String,
      date: map['date'] as String,
      type: map['type'] as String,
    );
  }

  factory PurchaseModel.fromEntity(Purchase entity) {
    return PurchaseModel(
      id: entity.id,
      date: entity.date.toIso8601String(),
      type: entity.type.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'type': type,
    };
  }

  Purchase toEntity({List<PurchaseItem> items = const []}) {
    return Purchase(
      id: id,
      date: DateTime.parse(date),
      type: PurchaseType.values.firstWhere((t) => t.name == type),
      items: items,
    );
  }
}
