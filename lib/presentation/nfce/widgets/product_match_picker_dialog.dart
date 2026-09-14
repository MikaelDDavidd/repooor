import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/nfce_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/nfce/imported_item_match.dart';
import '../../../domain/entities/nfce/match_type.dart';
import '../../../domain/entities/product.dart';
import 'create_product_inline_form.dart';
import 'product_match_suggestion_tile.dart';

class ProductMatchPickerDialog extends ConsumerStatefulWidget {
  const ProductMatchPickerDialog({super.key, required this.match});

  final ImportedItemMatch match;

  static Future<ImportedItemMatch?> show(
    BuildContext context,
    ImportedItemMatch match,
  ) {
    return showModalBottomSheet<ImportedItemMatch>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ProductMatchPickerDialog(match: match),
    );
  }

  @override
  ConsumerState<ProductMatchPickerDialog> createState() => _State();
}

class _State extends ConsumerState<ProductMatchPickerDialog> {
  late final TextEditingController _searchController;
  List<Product> _suggestions = const [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _suggestions = widget.match.suggestions;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    setState(() => _searching = true);
    final repo = ref.read(productMatchRepositoryProvider);
    final results = await repo.searchSuggestions(query);
    if (!mounted) return;
    setState(() {
      _suggestions = results;
      _searching = false;
    });
  }

  void _pick(Product product) {
    final updated = widget.match.copyWith(
      type: MatchType.exact,
      matchedProduct: product,
      resolvedUnit: product.unit,
      clearNewProductName: true,
      clearNewProductCategoryId: true,
    );
    Navigator.of(context).pop(updated);
  }

  Future<void> _createNew() async {
    final created = await CreateProductInlineForm.show(
      context,
      suggestedName: widget.match.newProductName ?? widget.match.source.rawName,
      suggestedUnit: widget.match.resolvedUnit,
      suggestedCategoryId: widget.match.newProductCategoryId,
    );
    if (created != null && mounted) _pick(created);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Vincular a um produto', style: AppTextStyles.heading2),
              const SizedBox(height: 4),
              Text(
                widget.match.source.rawName,
                style: AppTextStyles.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Buscar produto...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: _search,
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: LinearProgressIndicator(),
                      )
                    : (_suggestions.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Nenhuma sugestão',
                                style: AppTextStyles.bodySecondary,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView(
                              shrinkWrap: true,
                              children: _suggestions
                                  .map(
                                    (p) => ProductMatchSuggestionTile(
                                      product: p,
                                      isSelected:
                                          widget.match.matchedProduct?.id ==
                                          p.id,
                                      onTap: () => _pick(p),
                                    ),
                                  )
                                  .toList(),
                            )),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _createNew,
                icon: const Icon(Icons.add, color: AppColors.primaryStrong),
                label: const Text('Criar produto novo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
