import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_url.dart';
import '../../../domain/entities/address.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/repositories/order_repository.dart';
import '../../../domain/usecases/order/create_order_usecase.dart';
import '../../../domain/usecases/profile/get_addresses_usecase.dart';
import '../../blocs/cart_bloc.dart';
import '../../blocs/order_bloc.dart';
import '../../widgets/primary_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _noteCtrl = TextEditingController();
  String _paymentMethod = 'cod';
  Address? _address;
  bool _loadingAddress = true;

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(const CartLoad());
    _loadAddress();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAddress() async {
    final result = await sl<GetAddressesUsecase>()();
    result.fold(
      (_) => setState(() => _loadingAddress = false),
      (list) {
        final defaultAddr = list.where((a) => a.isDefault).isNotEmpty ? list.firstWhere((a) => a.isDefault) : (list.isNotEmpty ? list.first : null);
        setState(() {
          _address = defaultAddr;
          _loadingAddress = false;
        });
      },
    );
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

  void _placeOrder(List<CartItem> items) {
    final addr = _address;
    if (addr == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thêm địa chỉ giao hàng'), backgroundColor: AppColors.terra));
      return;
    }
    if (items.isEmpty) return;
    final orderItems = items.map((c) => OrderItemInput(treeId: c.treeId, quantity: c.quantity)).toList();
    context.read<OrderBloc>().add(OrderCreate(CreateOrderParams(
          customerName: addr.receiverName,
          phoneNumber: addr.phoneNumber,
          addressLine: addr.fullAddress,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          items: orderItems,
          paymentMethod: _paymentMethod,
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderCreated) {
            context.go('/order-success?id=${state.order.id}');
          } else if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.terra));
          }
        },
        builder: (context, orderState) {
          return BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              if (cartState is! CartLoaded) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = cartState.items;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                children: [
                  _addressCard(),
                  const SizedBox(height: 16),
                  _itemsCard(items),
                  const SizedBox(height: 16),
                  _paymentCard(),
                  const SizedBox(height: 16),
                  TextField(controller: _noteCtrl, maxLines: 2, decoration: const InputDecoration(hintText: 'Ghi chú cho shop...', fillColor: AppColors.green50)),
                  const SizedBox(height: 120),
                ],
              );
            },
          );
        },
      ),
      bottomSheet: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          if (cartState is! CartLoaded) return const SizedBox.shrink();
          final items = cartState.items;
          final total = _subtotal(items);
          final isCreating = context.watch<OrderBloc>().state is OrderLoading;
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(color: AppColors.paper, border: Border(top: BorderSide(color: AppColors.line))),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tổng cộng', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                    Text(_formatPrice(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.green700)),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: isCreating
                      ? const Center(child: CircularProgressIndicator())
                      : PrimaryButton(label: 'Đặt hàng', onPressed: () => _placeOrder(items)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _addressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.location_on, color: AppColors.green700, size: 20),
            const SizedBox(width: 8),
            const Text('Địa chỉ giao hàng', style: TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton(onPressed: () => context.push('/addresses'), child: const Text('Quản lý')),
          ]),
          const SizedBox(height: 4),
          if (_loadingAddress)
            const Padding(padding: EdgeInsets.all(8), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
          else if (_address == null)
            const Text('Chưa có địa chỉ. Bấm "Quản lý" để thêm.', style: TextStyle(fontSize: 13, color: AppColors.terra))
          else ...[
            Text(_address!.receiverName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            Text(_address!.phoneNumber, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            Text(_address!.fullAddress, style: const TextStyle(fontSize: 13, color: AppColors.ink2)),
          ],
        ],
      ),
    );
  }

  Widget _itemsCard(List<CartItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sản phẩm (${items.length})', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...items.map((it) {
            final tree = it.tree;
            final imgUrl = (tree?.images.isNotEmpty ?? false) ? resolveImageUrl(tree!.images.first.imageUrl) : '';
            final name = tree?.name ?? it.treeId.substring(0, 8);
            final price = tree?.finalPrice ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: imgUrl.isEmpty
                          ? Container(color: AppColors.green50, child: const Icon(Icons.eco, size: 20, color: AppColors.green700))
                          : Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.green50, child: const Icon(Icons.eco, size: 20, color: AppColors.green700))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                  Text('×${it.quantity}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  const SizedBox(width: 8),
                  Text(_formatPrice(price * it.quantity), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.green700)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _paymentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Phương thức thanh toán', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          RadioListTile<String>(
            value: 'cod',
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v ?? 'cod'),
            title: const Text('Thanh toán khi nhận hàng (COD)'),
            dense: true,
            activeColor: AppColors.green700,
          ),
          RadioListTile<String>(
            value: 'bank_transfer',
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v ?? 'cod'),
            title: const Text('Chuyển khoản ngân hàng'),
            subtitle: const Text('VCB · TCB · MB', style: TextStyle(fontSize: 11, color: AppColors.muted)),
            dense: true,
            activeColor: AppColors.green700,
          ),
        ],
      ),
    );
  }
}