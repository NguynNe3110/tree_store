import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_url.dart';
import '../../../domain/entities/cart_item.dart';
import '../../blocs/cart_bloc.dart';
import '../../widgets/primary_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(const CartLoad());
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

  double _subtotal(List<CartItem> items) {
    double sum = 0;
    for (final it in items) {
      sum += (it.tree?.finalPrice ?? 0) * it.quantity;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading || state is CartInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CartError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, style: const TextStyle(color: AppColors.terra), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    PrimaryButton(label: 'Thử lại', onPressed: () => context.read<CartBloc>().add(const CartLoad())),
                  ],
                ),
              ),
            );
          }
          if (state is! CartLoaded) return const SizedBox.shrink();
          final items = state.items;
          if (items.isEmpty) return _emptyState(context);
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _cartCard(context, items[i]),
                ),
              ),
              _checkoutBar(context, items),
            ],
          );
        },
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.green50),
              child: const Center(child: Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.green700)),
            ),
            const SizedBox(height: 24),
            const Text('Giỏ hàng của bạn đang trống', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Hãy chọn vài chậu cây xinh để mang thiên nhiên về nhà nhé!', style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(width: 220, child: PrimaryButton(label: 'Khám phá cây cảnh', onPressed: () => context.go('/home'))),
          ],
        ),
      ),
    );
  }

  Widget _cartCard(BuildContext context, CartItem item) {
    final tree = item.tree;
    if (tree == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line2)),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.terra),
            const SizedBox(width: 12),
            const Expanded(child: Text('Không tải được sản phẩm', style: TextStyle(fontSize: 13, color: AppColors.terra))),
            IconButton(
              onPressed: item.id != null ? () => context.read<CartBloc>().add(CartRemove(item.id!)) : null,
              icon: const Icon(Icons.close, size: 18, color: AppColors.muted),
            ),
          ],
        ),
      );
    }
    final imgUrl = tree.images.isNotEmpty ? resolveImageUrl(tree.images.first.imageUrl) : '';
    final name = tree.name;
    final price = tree.finalPrice;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line2)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 76,
              height: 76,
              child: imgUrl.isEmpty
                  ? Container(color: AppColors.green50, child: const Center(child: Icon(Icons.eco, color: AppColors.green700)))
                  : Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.green50, child: const Center(child: Icon(Icons.eco, color: AppColors.green700)))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
                const SizedBox(height: 4),
                Text(_formatPrice(price), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.green700)),
                const SizedBox(height: 6),
                Text('SL: ${item.quantity}', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
          IconButton(
            onPressed: item.id != null ? () => context.read<CartBloc>().add(CartRemove(item.id!)) : null,
            icon: const Icon(Icons.close, size: 18, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _checkoutBar(BuildContext context, List<CartItem> items) {
    final total = _subtotal(items);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(color: AppColors.paper, border: Border(top: BorderSide(color: AppColors.line))),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${items.length} sản phẩm', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              Text(_formatPrice(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.green700)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(child: PrimaryButton(label: 'Thanh toán →', onPressed: () => context.push('/checkout'))),
        ],
      ),
    );
  }
}