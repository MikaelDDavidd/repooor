class Product {
  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.unit,
  });

  final String id;
  final String name;
  final String categoryId;
  final String unit;

  Product copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? unit,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      unit: unit ?? this.unit,
    );
  }
}
