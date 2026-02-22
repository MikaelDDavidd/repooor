import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/product.dart';

class ProductPickerDialog extends StatefulWidget {
  const ProductPickerDialog({
    super.key,
    required this.products,
    required this.categories,
  });

  final List<Product> products;
  final List<Category> categories;

  static Future<Product?> show(
    BuildContext context, {
    required List<Product> products,
    required List<Category> categories,
  }) {
    return Navigator.of(context).push<Product>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ProductPickerDialog(
          products: products,
          categories: categories,
        ),
      ),
    );
  }

  @override
  State<ProductPickerDialog> createState() => _ProductPickerDialogState();
}

class _ProductPickerDialogState extends State<ProductPickerDialog> {
  static const _headerHeight = 32.0;
  static const _tileHeight = 72.0;

  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';

  late final Map<String, Category> _categoryMap;

  @override
  void initState() {
    super.initState();
    _categoryMap = {for (final c in widget.categories) c.id: c};
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _query = value.toLowerCase());
    });
  }

  List<Product> get _filtered {
    final sorted = List<Product>.from(widget.products)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (_query.isEmpty) return sorted;
    return sorted.where((p) => p.name.toLowerCase().contains(_query)).toList();
  }

  Map<String, List<Product>> _groupByLetter(List<Product> products) {
    final map = <String, List<Product>>{};
    for (final p in products) {
      final letter = p.name[0].toUpperCase();
      map.putIfAbsent(letter, () => []).add(p);
    }
    return map;
  }

  List<String> _availableLetters(Map<String, List<Product>> grouped) {
    return grouped.keys.toList()..sort();
  }

  Map<String, double> _letterOffsets(List<String> letters, Map<String, List<Product>> grouped) {
    final offsets = <String, double>{};
    var offset = 0.0;
    for (final letter in letters) {
      offsets[letter] = offset;
      offset += _headerHeight + grouped[letter]!.length * _tileHeight;
    }
    return offsets;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final grouped = _groupByLetter(filtered);
    final letters = _availableLetters(grouped);
    final offsets = _letterOffsets(letters, grouped);

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: const InputDecoration(
            hintText: 'Buscar produto...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.textSecondary),
          ),
          style: AppTextStyles.body,
        ),
      ),
      body: filtered.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    _query.isEmpty
                        ? 'Nenhum produto disponivel'
                        : 'Nenhum produto encontrado',
                    style: AppTextStyles.heading2,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(right: 24),
                  itemCount: letters.length,
                  itemBuilder: (context, sectionIndex) {
                    final letter = letters[sectionIndex];
                    final products = grouped[letter]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _LetterHeader(letter: letter),
                        ...products.map((p) => _ProductPickerTile(
                              product: p,
                              category: _categoryMap[p.categoryId],
                              onTap: () => Navigator.of(context).pop(p),
                            )),
                      ],
                    );
                  },
                ),
                if (letters.length > 1)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: _AlphabetSidebar(
                      letters: letters,
                      onLetterSelected: (letter) {
                        final target = offsets[letter];
                        if (target == null) return;
                        _scrollController.animateTo(
                          target,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}

class _LetterHeader extends StatelessWidget {
  const _LetterHeader({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      color: AppColors.backgroundSecondary,
      child: Text(letter, style: AppTextStyles.bodySecondary.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

class _ProductPickerTile extends StatelessWidget {
  const _ProductPickerTile({
    required this.product,
    required this.category,
    required this.onTap,
  });

  final Product product;
  final Category? category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: category != null
                        ? Color(category!.color).withValues(alpha: 0.15)
                        : AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    category != null ? IconData(category!.icon, fontFamily: 'MaterialIcons') : Icons.category,
                    color: category != null ? Color(category!.color) : AppColors.textSecondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: AppTextStyles.body),
                      const SizedBox(height: 2),
                      Text(
                        '${category?.name ?? ''} · ${product.unit}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlphabetSidebar extends StatelessWidget {
  const _AlphabetSidebar({
    required this.letters,
    required this.onLetterSelected,
  });

  final List<String> letters;
  final ValueChanged<String> onLetterSelected;

  String _letterFromPosition(double dy, double totalHeight) {
    final index = (dy / totalHeight * letters.length).clamp(0, letters.length - 1).toInt();
    return letters[index];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final local = box.globalToLocal(details.globalPosition);
        onLetterSelected(_letterFromPosition(local.dy, box.size.height));
      },
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox;
        final local = box.globalToLocal(details.globalPosition);
        onLetterSelected(_letterFromPosition(local.dy, box.size.height));
      },
      child: Container(
        width: 20,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: letters
              .map((l) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Text(
                      l,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
