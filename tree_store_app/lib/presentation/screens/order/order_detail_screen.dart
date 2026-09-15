import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_url.dart';
import '../../../domain/entities/order.dart';
import '../../blocs/order_bloc.dart';
import '../../widgets/primary_button.dart';

class OrderDetailScreen extends StatefulWidget {
  final String id;
  const OrderDetailScreen({super.key, required this.id});
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure orders are loaded so we can find this one in state
    final state = context.read<OrderBloc>().state;
    if (state is! OrdersLoaded) {
      context.read<OrderBloc>().add(const OrderLoadAll());
    }
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
    final canPop = GoRouter.of(context).canPop();
    return Scaffold(
      appBar: AppBar(
        leading: canPop
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())
            : IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/orders')),
        title: Text('#${widget.id.substring(0, 8).toUpperCase()}'),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is! OrdersLoaded) {
            return const SizedBox.shrink();
          }
          final order = state.orders.where((o) => o.id == widget.id).firstOrNull;
          if (order == null) return const Center(child: Text('Không tìm thấy đơn hàng'));

          return ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              _statusBanner(order),
              _timeline(order),
              _addressSection(order),
              _itemsSection(order),
              _summarySection(order),
            ],
          );
        },
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: const BoxDecoration(color: AppColors.paper, border: Border(top: BorderSide(color: AppColors.line2))),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.line2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Liên hệ shop', style: TextStyle(color: AppColors.ink)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: PrimaryButton(label: 'Theo dõi')),
          ],
        ),
      ),
    );
  }

  Widget _statusBanner(Order o) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.green700, AppColors.green600]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          const Positioned(right: -10, bottom: -10, child: Icon(Icons.local_shipping_outlined, size: 80, color: Colors.white12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TRẠNG THÁI', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
              const SizedBox(height: 4),
              Text(_statusText(o.status), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 2),
              Text(_statusDesc(o.status), style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeline(Order o) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tiến trình đơn hàng', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _tlItem('Đặt hàng thành công', 'Vừa xong', true, true),
          _tlItem('Đã xác nhận', 'Đang xử lý', false, false),
          _tlItem('Giao hàng thành công', 'Dự kiến 2-3 ngày', false, false, isLast: true),
        ],
      ),
    );
  }

  Widget _tlItem(String t, String s, bool done, bool now, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(shape: BoxShape.circle, color: done || now ? AppColors.green700 : AppColors.line2, boxShadow: now ? [BoxShadow(color: AppColors.green700.withOpacity(0.2), blurRadius: 8, spreadRadius: 4)] : null),
            ),
            if (!isLast) Container(width: 2, height: 30, color: done ? AppColors.green700 : AppColors.line2),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: now ? AppColors.green700 : AppColors.ink)),
            Text(s, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
        ),
      ],
    );
  }

  Widget _addressSection(Order o) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📍 Giao đến', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('${o.receiverName ?? "Người nhận"} · ${o.phoneNumber ?? ""}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(o.addressLine ?? "Chưa có địa chỉ", style: const TextStyle(fontSize: 13, color: AppColors.ink2, height: 1.4)),
        ],
      ),
    );
  }

  Widget _itemsSection(Order o) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sản phẩm (${o.items.length})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...o.items.map((it) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.eco, color: AppColors.green700)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(it.productNameSnapshot, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis), const Text('Kèm chậu gốm', style: TextStyle(fontSize: 10, color: AppColors.muted))])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(_formatPrice(it.lineTotal), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.green700)), Text('×${it.quantity}', style: const TextStyle(fontSize: 10, color: AppColors.muted))]),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _summarySection(Order o) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line2)),
      child: Column(
        children: [
          _sumRow('Tạm tính', _formatPrice(o.subtotalPrice)),
          _sumRow('Phí giao hàng', _formatPrice(o.shippingFee)),
          _sumRow('Giảm giá', '-${_formatPrice(o.discountAmount)}', isTerra: true),
          const Divider(height: 24, color: AppColors.line2),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Tổng cộng · ${_paymentLabel(o)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)), Text(_formatPrice(o.totalPrice), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.green700))]),
        ],
      ),
    );
  }

  String _paymentLabel(Order o) {
    switch (o.paymentMethod) {
      case PaymentMethod.payos:
        return o.paymentStatus == PaymentStatus.paid ? 'Đã thanh toán' : 'PayOS';
      case PaymentMethod.bankTransfer:
        return 'Chuyển khoản';
      case PaymentMethod.eWallet:
        return 'Ví điện tử';
      case PaymentMethod.cod:
        return 'COD';
    }
  }

  Widget _sumRow(String l, String v, {bool isTerra = false}) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(fontSize: 13, color: AppColors.muted)), Text(v, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isTerra ? AppColors.terra : AppColors.ink))]));

  String _statusText(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.shipping:
        return 'Đang giao hàng';
      case OrderStatus.delivered:
        return 'Giao thành công';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }

  String _statusDesc(OrderStatus s) {
    switch (s) {
      case OrderStatus.shipping:
        return 'Đơn hàng đang trên đường đến bạn';
      case OrderStatus.delivered:
        return 'Đã giao vào 10/09/2026';
      default:
        return 'Chúng tôi đang chuẩn bị cây cho bạn';
    }
  }
}