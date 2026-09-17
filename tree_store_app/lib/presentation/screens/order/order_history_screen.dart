import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_url.dart';
import '../../../domain/entities/order.dart';
import '../../blocs/order_bloc.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});
  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    context.read<OrderBloc>().add(const OrderLoadAll());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
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
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Đơn hàng của tôi'),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          labelColor: AppColors.green700,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.green700,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Đang giao'),
            Tab(text: 'Đã giao'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OrderError) {
            return Center(
                child: Text(state.message,
                    style: const TextStyle(color: AppColors.terra)));
          }
          if (state is! OrdersLoaded) return const SizedBox.shrink();
          final orders = state.orders;

          return TabBarView(
            controller: _tabCtrl,
            children: [
              _orderList(orders),
              _orderList(orders
                  .where((o) => [
                        OrderStatus.pending,
                        OrderStatus.confirmed,
                        OrderStatus.shipping
                      ].contains(o.status))
                  .toList()),
              _orderList(orders
                  .where((o) => o.status == OrderStatus.delivered)
                  .toList()),
              _orderList(orders
                  .where((o) => o.status == OrderStatus.cancelled)
                  .toList()),
            ],
          );
        },
      ),
    );
  }

  Widget _orderList(List<Order> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.line2),
            SizedBox(height: 12),
            Text('Không có đơn hàng nào', style: TextStyle(color: AppColors.muted)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) => _orderCard(list[i]),
    );
  }

  Widget _orderCard(Order o) {
    if (o.items.isEmpty) return const SizedBox.shrink();
    
    final item = o.items.first;
    final otherCount = o.items.length - 1;
    final statusTxt = _statusLabel(o.status);
    final imgUrl = item.imageUrlSnapshot != null ? resolveImageUrl(item.imageUrlSnapshot) : '';

    return GestureDetector(
      onTap: () => context.push('/order/${o.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line2)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#${o.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: _statusColor(o.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(statusTxt,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(o.status))),
                ),
              ],
            ),
            const Divider(height: 20, color: AppColors.line2),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 56,
                    height: 56,
                    color: AppColors.green50,
                    child: imgUrl.isEmpty
                        ? const Icon(Icons.eco, color: AppColors.green700)
                        : Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.eco, color: AppColors.green700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${item.productNameSnapshot}${otherCount > 0 ? " + $otherCount sp khác" : ""}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('Tổng ${o.items.length} sản phẩm',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: AppColors.line2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng thanh toán',
                    style: TextStyle(fontSize: 11, color: AppColors.muted)),
                Text(_formatPrice(o.totalPrice),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 'CHỜ XÁC NHẬN';
      case OrderStatus.confirmed:
        return 'ĐÃ XÁC NHẬN';
      case OrderStatus.shipping:
        return 'ĐANG GIAO';
      case OrderStatus.delivered:
        return 'ĐÃ GIAO';
      case OrderStatus.cancelled:
        return 'ĐÃ HỦY';
    }
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.delivered:
        return AppColors.green700;
      case OrderStatus.shipping:
        return Colors.blue;
      case OrderStatus.cancelled:
        return AppColors.terra;
      default:
        return Colors.orange;
    }
  }
}