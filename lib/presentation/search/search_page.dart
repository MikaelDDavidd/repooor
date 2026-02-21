import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../providers/search_providers.dart';
import '../shared/widgets/app_empty_state.dart';
import '../shared/widgets/app_error_state.dart';
import '../shared/widgets/app_loading_state.dart';
import 'widgets/search_result_card.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = value.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(),
      ),
      body: _buildBody(query, results),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _controller,
      onChanged: _onQueryChanged,
      autofocus: true,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: 'Buscar produtos...',
        hintStyle: AppTextStyles.bodySecondary,
        border: InputBorder.none,
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                onPressed: () {
                  _controller.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                },
              )
            : null,
      ),
    );
  }

  Widget _buildBody(String query, AsyncValue<List<SearchResultItem>> results) {
    if (query.isEmpty) {
      return const AppEmptyState(
        icon: Icons.search,
        title: 'Digite para buscar',
        subtitle: 'Busque produtos por nome',
      );
    }

    return results.when(
      loading: () => const AppLoadingState(),
      error: (_, _) => AppErrorState(
        message: 'Erro ao buscar',
        onRetry: () => ref.invalidate(searchResultsProvider),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const AppEmptyState(
            icon: Icons.search_off,
            title: 'Nenhum produto encontrado',
            subtitle: 'Tente outro termo de busca',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, index) {
            final item = items[index];
            return SearchResultCard(
              product: item.product,
              pantryItem: item.pantryItem,
              lastPurchase: item.lastPurchase,
            );
          },
        );
      },
    );
  }
}
