import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng'), actions: [TextButton(onPressed: () {}, child: const Text('Sửa', style: TextStyle(color: AppColors.green700)))]),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CartError) {
            return Center(child: Text(state.message, style: const TextStyle(color: AppColors.terra)));
          }
          if (state is CartLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.line),
                  const SizedBox(height: 16),
                  const Text('Giỏ hàng trống', style: TextStyle(fontSize: 16, color: AppColors.muted)),
                  const SizedBox(height: 24),
                  PrimaryButton(label: 'Khám phá cây', onPressed: () => context.go('/home')),
                ],
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            Container(width: 76, height: 76, decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.eco, color: AppColors.green700)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.treeId.substring(0, 8), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)), // ponytail: treeId shown because cart API doesn't return tree name. upgrade when backend adds tree snapshot to cart response
                                  const SizedBox(height: 2),
                                  Text('SL: ${item.quantity}', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: item.quantity > 1 ? () => context.read<CartBloc>().add(CartAdd(item.treeId, -1)) : null, // ponytail: no decrement endpoint, re-add with qty-1 as workaround. upgrade when backend supports PATCH quantity
                                    icon: const Icon(Icons.remove, size: 16),
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  ),
                                  Text('${item.quantity}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                  IconButton(
                                    onPressed: () => context.read<CartBloc>().add(CartAdd(item.treeId)),
                                    icon: const Icon(Icons.add, size: 16),
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: item.id != null ? () => context.read<CartBloc>().add(CartRemove(item.id!)) : null,
                              icon: const Icon(Icons.close, size: 16, color: AppColors.muted),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.line))),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('${0} sản phẩm', style: TextStyle(color: AppColors.ink2)), const Text('Tạm tính', style: TextStyle(color: AppColors.ink))]),
                      const SizedBox(height: 12),
                      PrimaryButton(label: 'Thanh toán →', onPressed: () => context.push('/checkout')),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}