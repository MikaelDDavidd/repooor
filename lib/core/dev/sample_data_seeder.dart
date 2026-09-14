import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/pantry_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/purchase_item.dart';
import '../di/providers.dart';
import '../constants/app_units.dart';

class SampleDataSeeder {
  SampleDataSeeder._();

  static const _uuid = Uuid();

  static Future<SeedResult> seed(WidgetRef ref) async {
    final categories = await ref.read(getAllCategoriesProvider).call();
    if (categories.isEmpty) {
      throw StateError('Categories not seeded yet');
    }
    final byName = {for (final c in categories) c.name: c};

    final products = await _seedProducts(ref, byName);
    await _seedPantry(ref, products);
    await _seedPurchases(ref, products);

    return SeedResult(productCount: products.length, purchaseCount: 4);
  }

  static Future<List<Product>> _seedProducts(
    WidgetRef ref,
    Map<String, Category> byName,
  ) async {
    final create = ref.read(createProductProvider);
    final specs = <_ProductSpec>[
      _ProductSpec('Arroz Tio João 5kg', 'Grãos', AppUnit.un),
      _ProductSpec('Feijão Carioca 1kg', 'Grãos', AppUnit.un),
      _ProductSpec('Leite Integral', 'Laticínios', AppUnit.l),
      _ProductSpec('Queijo Mussarela', 'Laticínios', AppUnit.kg),
      _ProductSpec('Banana Prata', 'Frutas', AppUnit.kg),
      _ProductSpec('Maçã Gala', 'Frutas', AppUnit.kg),
      _ProductSpec('Frango Inteiro', 'Carnes', AppUnit.kg),
      _ProductSpec('Café Pilão 500g', 'Bebidas', AppUnit.un),
      _ProductSpec('Detergente Ypê', 'Limpeza', AppUnit.un),
      _ProductSpec('Sabonete Dove', 'Higiene', AppUnit.un),
      _ProductSpec('Pão Francês', 'Padaria', AppUnit.kg),
      _ProductSpec('Macarrão Espaguete', 'Massas', AppUnit.un),
    ];
    final products = <Product>[];
    for (final s in specs) {
      final category = byName[s.categoryName];
      if (category == null) continue;
      final product = Product(
        id: _uuid.v4(),
        name: s.name,
        categoryId: category.id,
        unit: s.unit.label,
      );
      await create(product);
      products.add(product);
    }
    return products;
  }

  static Future<void> _seedPantry(WidgetRef ref, List<Product> products) async {
    final add = ref.read(addToPantryProvider);
    final pantrySpecs = <String, ({double current, double ideal})>{
      'Arroz Tio João 5kg': (current: 1, ideal: 2),
      'Feijão Carioca 1kg': (current: 2, ideal: 3),
      'Leite Integral': (current: 1, ideal: 4),
      'Café Pilão 500g': (current: 0, ideal: 2),
      'Detergente Ypê': (current: 3, ideal: 4),
      'Sabonete Dove': (current: 0, ideal: 6),
    };
    for (final product in products) {
      final spec = pantrySpecs[product.name];
      if (spec == null) continue;
      await add(
        PantryItem(
          id: _uuid.v4(),
          productId: product.id,
          currentQuantity: spec.current,
          idealQuantity: spec.ideal,
        ),
      );
    }
  }

  static Future<void> _seedPurchases(
    WidgetRef ref,
    List<Product> products,
  ) async {
    final byName = {for (final p in products) p.name: p};
    final now = DateTime.now();

    await _createPurchase(
      ref,
      date: DateTime(now.year, now.month, now.day - 2),
      type: PurchaseType.main,
      items: [
        _PurchaseItemSpec('Arroz Tio João 5kg', 2, 28.90),
        _PurchaseItemSpec('Feijão Carioca 1kg', 3, 8.50),
        _PurchaseItemSpec('Leite Integral', 6, 5.49),
        _PurchaseItemSpec('Queijo Mussarela', 0.5, 49.90),
        _PurchaseItemSpec('Frango Inteiro', 1.8, 15.90),
        _PurchaseItemSpec('Café Pilão 500g', 2, 18.99),
        _PurchaseItemSpec('Detergente Ypê', 4, 2.79),
        _PurchaseItemSpec('Macarrão Espaguete', 5, 4.49),
      ],
      byName: byName,
    );

    await _createPurchase(
      ref,
      date: DateTime(now.year, now.month, (now.day - 6).clamp(1, 28)),
      type: PurchaseType.midMonth,
      items: [
        _PurchaseItemSpec('Banana Prata', 1.2, 5.99),
        _PurchaseItemSpec('Maçã Gala', 0.8, 9.49),
        _PurchaseItemSpec('Pão Francês', 0.4, null),
        _PurchaseItemSpec('Leite Integral', 2, null),
      ],
      byName: byName,
    );

    final lastMonth = DateTime(now.year, now.month - 1, 15);
    await _createPurchase(
      ref,
      date: lastMonth,
      type: PurchaseType.main,
      items: [
        _PurchaseItemSpec('Arroz Tio João 5kg', 2, 26.50),
        _PurchaseItemSpec('Feijão Carioca 1kg', 2, 7.99),
        _PurchaseItemSpec('Leite Integral', 6, 4.99),
        _PurchaseItemSpec('Café Pilão 500g', 2, 17.49),
      ],
      byName: byName,
    );

    final twoMonthsAgo = DateTime(now.year, now.month - 2, 10);
    await _createPurchase(
      ref,
      date: twoMonthsAgo,
      type: PurchaseType.main,
      items: [
        _PurchaseItemSpec('Arroz Tio João 5kg', 1, 24.90),
        _PurchaseItemSpec('Leite Integral', 4, 4.49),
        _PurchaseItemSpec('Café Pilão 500g', 1, 16.90),
      ],
      byName: byName,
    );
  }

  static Future<void> _createPurchase(
    WidgetRef ref, {
    required DateTime date,
    required PurchaseType type,
    required List<_PurchaseItemSpec> items,
    required Map<String, Product> byName,
  }) async {
    final createPurchase = ref.read(createPurchaseProvider);
    final addItem = ref.read(addPurchaseItemProvider);

    final purchaseId = _uuid.v4();
    await createPurchase(Purchase(id: purchaseId, date: date, type: type));

    for (final spec in items) {
      final product = byName[spec.productName];
      if (product == null) continue;
      await addItem(
        PurchaseItem(
          id: _uuid.v4(),
          purchaseId: purchaseId,
          productId: product.id,
          quantity: spec.quantity,
          unitPrice: spec.unitPrice,
        ),
      );
    }
  }
}

class SeedResult {
  const SeedResult({required this.productCount, required this.purchaseCount});

  final int productCount;
  final int purchaseCount;
}

class _ProductSpec {
  const _ProductSpec(this.name, this.categoryName, this.unit);
  final String name;
  final String categoryName;
  final AppUnit unit;
}

class _PurchaseItemSpec {
  const _PurchaseItemSpec(this.productName, this.quantity, this.unitPrice);
  final String productName;
  final double quantity;
  final double? unitPrice;
}
