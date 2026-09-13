import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/search_bloc.dart';
import '../../widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  final String title;
  const ProductListScreen({super.key, required this.title});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    // Re-use SearchBloc logic to load all products (or featured ones depending on the context).
    // For now, loading all by dispatching an empty query.
    context.read<SearchBloc>().add(const SearchQuery(''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SearchError) {
            return Center(child: Text(state.message, style: const TextStyle(color: AppColors.terra)));
          }

          final items = state is SearchLoaded ? state.results : (state is SearchSuggestionsLoaded ? state.suggestions : []);

          if (items.isEmpty) {
            return const Center(
              child: Text('Không có sản phẩm nào', style: TextStyle(color: AppColors.muted)),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final p = items[i];
              return ProductCard(
                product: p,
                onTap: () => context.push('/product/${p.id}'),
              );
            },
          );
        },
      ),
    );
  }
}