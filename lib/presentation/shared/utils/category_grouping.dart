import '../../../domain/entities/category.dart';

class CategoryGroup<T> {
  CategoryGroup({required this.category, required this.items});

  final Category? category;
  final List<T> items;
}

List<CategoryGroup<T>> groupByCategory<T>({
  required List<T> items,
  required String Function(T) categoryIdOf,
  required List<Category> categories,
}) {
  final grouped = <String, List<T>>{};
  for (final item in items) {
    final id = categoryIdOf(item);
    grouped.putIfAbsent(id, () => []).add(item);
  }

  final result = <CategoryGroup<T>>[];

  for (final cat in categories) {
    final group = grouped.remove(cat.id);
    if (group != null && group.isNotEmpty) {
      result.add(CategoryGroup(category: cat, items: group));
    }
  }

  final remaining = grouped.values.expand((g) => g).toList();
  if (remaining.isNotEmpty) {
    result.add(CategoryGroup(category: null, items: remaining));
  }

  return result;
}
