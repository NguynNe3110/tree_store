import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_url.dart';
import '../../../domain/entities/product.dart';
import '../../blocs/cart_bloc.dart';
import '../../blocs/tree_bloc.dart';
import '../../widgets/primary_button.dart';

class ProductDetailScreen extends StatefulWidget {
  final String id;
  const ProductDetailScreen({super.key, required this.id});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _selectedImgIdx = 0;

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

  void _addToCart(Product tree) {
    context.read<CartBloc>().add(CartAdd(tree.id, _quantity));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã thêm vào giỏ hàng',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.green700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _buyNow(Product tree) {
    context.push('/checkout', extra: {
      'singleItem': tree,
      'quantity': _quantity,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
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
                    child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop()),
                  ),
                  Expanded(
                      child: Center(
                          child: Text(state.message,
                              style: const TextStyle(color: AppColors.terra)))),
                ],
              ),
            );
          }
          if (state is! TreeLoaded) return const SizedBox.shrink();
          final tree = state.tree;
          final images = tree.images;
          final mainImg = images.isNotEmpty
              ? resolveImageUrl(images[_selectedImgIdx].imageUrl)
              : '';

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        Container(
                          height: 420,
                          width: double.infinity,
                          color: AppColors.green50,
                          child: mainImg.isEmpty
                              ? const Center(
                                  child: Icon(Icons.eco,
                                      size: 80, color: AppColors.green700))
                              : Image.network(mainImg, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.eco,
                                          size: 80,
                                          color: AppColors.green700))),
                        ),
                        // Thumbnail List
                        if (images.length > 1)
                          Positioned(
                            right: 16,
                            bottom: 40,
                            child: Column(
                              children: List.generate(images.length, (i) {
                                final isSelected = _selectedImgIdx == i;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedImgIdx = i),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: isSelected
                                              ? AppColors.green700
                                              : Colors.white,
                                          width: 2),
                                      image: DecorationImage(
                                          image: NetworkImage(resolveImageUrl(
                                              images[i].imageUrl)),
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -24),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: AppColors.paper,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(24))),
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 160),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tree.categoryId != null
                                  ? 'CÂY TRONG NHÀ'
                                  : 'CÂY CẢNH',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.green700,
                                  letterSpacing: 0.8),
                            ),
                            const SizedBox(height: 6),
                            Text(tree.name,
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                    letterSpacing: -0.2)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ...List.generate(
                                    5,
                                    (i) => Icon(Icons.star,
                                        size: 14,
                                        color: i < 4
                                            ? Colors.amber
                                            : Colors.amber.withOpacity(0.3))),
                                const SizedBox(width: 6),
                                const Text('4.9',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink)),
                                const SizedBox(width: 4),
                                const Text('· 128 đánh giá',
                                    style: TextStyle(
                                        fontSize: 12, color: AppColors.muted)),
                                const SizedBox(width: 6),
                                Text('· Còn ${tree.stockQuantity}',
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.muted)),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(_formatPrice(tree.finalPrice),
                                    style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.green700)),
                                if (tree.onSale) ...[
                                  const SizedBox(width: 10),
                                  Text(_formatPrice(tree.price),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          color: AppColors.muted,
                                          decoration:
                                              TextDecoration.lineThrough)),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: AppColors.terraBg,
                                        borderRadius: BorderRadius.circular(6)),
                                    child: const Text('-20%',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.terra)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 24),
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 2.8,
                              children: [
                                _attr(Icons.straighten, 'Chiều cao', '60–70 cm'),
                                _attr(Icons.opacity, 'Tưới nước', '2 lần/tuần'),
                                _attr(Icons.wb_sunny_outlined, 'Ánh sáng',
                                    'Gián tiếp'),
                                _attr(Icons.eco_outlined, 'Độ khó', 'Dễ chăm'),
                                _attr(Icons.home_outlined, 'Vị trí', 'Trong nhà'),
                                _attr(Icons.bakery_dining_outlined, 'Chậu kèm',
                                    'Có · gốm'),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text('Mô tả',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink)),
                            const SizedBox(height: 8),
                            Text(
                              tree.description ??
                                  'Chưa có mô tả chi tiết cho sản phẩm này.',
                              style: const TextStyle(
                                  fontSize: 14, color: AppColors.ink2, height: 1.6),
                            ),
                            const SizedBox(height: 12),
                            const Text('Xem thêm',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.green700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Sticky Back button
              Positioned(
                top: 52,
                left: 16,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10)
                        ]),
                    child: const Icon(Icons.arrow_back, size: 20, color: AppColors.ink),
                  ),
                ),
              ),
              // Bottom Action Bar with Quantity Selector
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  decoration: const BoxDecoration(
                      color: AppColors.paper,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))
                      ],
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text('Số lượng',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                                color: AppColors.green50,
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              children: [
                                IconButton(
                                    onPressed: _quantity > 1
                                        ? () => setState(() => _quantity--)
                                        : null,
                                    icon: const Icon(Icons.remove, size: 18),
                                    color: AppColors.green700),
                                Text('$_quantity',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)),
                                IconButton(
                                    onPressed: _quantity < tree.stockQuantity
                                        ? () => setState(() => _quantity++)
                                        : null,
                                    icon: const Icon(Icons.add, size: 18),
                                    color: AppColors.green700),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _addToCart(tree),
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                  color: AppColors.green50,
                                  borderRadius: BorderRadius.circular(16)),
                              child: const Icon(Icons.shopping_cart_outlined,
                                  color: AppColors.green700, size: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: PrimaryButton(
                                  label:
                                      'Mua ngay · ${_formatPrice(tree.finalPrice * _quantity)}',
                                  onPressed: () => _buyNow(tree))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _attr(IconData icon, String lbl, String val) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.green50, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: AppColors.green700)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(lbl,
                    style:
                        const TextStyle(fontSize: 10, color: AppColors.muted)),
                Text(val,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}