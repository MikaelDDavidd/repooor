import '../../domain/entities/purchase.dart';
import '../../domain/entities/purchase_item.dart';

class PurchaseModel {
  const PurchaseModel({
    required this.id,
    required this.date,
    required this.type,
    required this.status,
  });

  final String id;
  final String date;
  final String type;
  final String status;

  factory PurchaseModel.fromMap(Map<String, dynamic> map) {
    return PurchaseModel(
      id: map['id'] as String,
      date: map['date'] as String,
      type: map['type'] as String,
      status: (map['status'] as String?) ?? PurchaseStatus.completed.name,
    );
  }

  factory PurchaseModel.fromEntity(Purchase entity) {
    return PurchaseModel(
      id: entity.id,
      date: entity.date.toIso8601String(),
      type: entity.type.name,
      status: entity.status.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'date': date, 'type': type, 'status': status};
  }

  Map<String, dynamic> toRemoteMap({required int updatedAt}) {
    return {
      'date': date,
      'type': type,
      'status': status,
      'updatedAt': updatedAt,
    };
  }

  Purchase toEntity({List<PurchaseItem> items = const []}) {
    return Purchase(
      id: id,
      date: DateTime.parse(date),
      type: PurchaseType.values.firstWhere((t) => t.name == type),
      status: PurchaseStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => PurchaseStatus.completed,
      ),
      items: items,
    );
  }
}
