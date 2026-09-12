import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_url.dart';
import '../../../domain/entities/product.dart';
import '../../blocs/tree_bloc.dart';
import '../../widgets/primary_button.dart';

class ProductDetailScreen extends StatefulWidget {
  final String id;
  const ProductDetailScreen({super.key, required this.id});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TreeBloc>().add(TreeLoad(widget.id));
  }

  String _formatPrice(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()}₫';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TreeBloc, TreeState>(
        builder: (context, state) {
          if (state is TreeLoading || state is TreeInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TreeError) {
            return SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
                  ),
                  Expanded(child: Center(child: Text(state.message, style: const TextStyle(color: AppColors.terra)))),
                ],
              ),
            );
          }
          if (state is! TreeLoaded) return const SizedBox.shrink();
          final tree = state.tree;
          final heroImg = tree.images.isNotEmpty
              ? resolveImageUrl(tree.images.first.imageUrl)
              : '';
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
                actions: [IconButton(icon: const Icon(Icons.favorite_border, color: Colors.white), onPressed: () {})],
                flexibleSpace: FlexibleSpaceBar(
                  background: heroImg.isEmpty
                      ? Container(color: AppColors.green50, child: const Center(child: Icon(Icons.eco, size: 80, color: AppColors.green700)))
                      : Image.network(
                          heroImg,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: AppColors.green50, child: const Center(child: Icon(Icons.eco, size: 80, color: AppColors.green700))),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tree.categoryId != null ? 'DANH MỤC' : 'CÂY CẢNH',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.green700, letterSpacing: 0.05),
                      ),
                      const SizedBox(height: 4),
                      Text(tree.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink)),
                      const SizedBox(height: 8),
                      Row(children: [
                        ...List.generate(5, (_) => const Icon(Icons.star, size: 16, color: Colors.amber)),
                        const SizedBox(width: 4),
                        Text('Còn ${tree.stockQuantity}', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Text(_formatPrice(tree.finalPrice), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.green700)),
                        if (tree.onSale) ...[
                          const SizedBox(width: 8),
                          Text(_formatPrice(tree.price), style: const TextStyle(fontSize: 16, color: AppColors.muted, decoration: TextDecoration.lineThrough)),
                        ],
                      ]),
                      const SizedBox(height: 20),
                      const Text('Mô tả', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
                      const SizedBox(height: 8),
                      Text(tree.description ?? 'Chưa có mô tả', style: const TextStyle(fontSize: 13, color: AppColors.ink2, height: 1.6)),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: BlocBuilder<TreeBloc, TreeState>(
        builder: (context, state) {
          if (state is! TreeLoaded) return const SizedBox.shrink();
          final tree = state.tree;
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(color: AppColors.paper, border: Border(top: BorderSide(color: AppColors.line))),
            child: Row(
              children: [
                Container(width: 52, height: 52, decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.shopping_cart_outlined, color: AppColors.green700)),
                const SizedBox(width: 12),
                Expanded(child: PrimaryButton(label: 'Mua ngay · ${_formatPrice(tree.finalPrice)}', onPressed: () => context.push('/checkout'))),
              ],
            ),
          );
        },
      ),
    );
  }
}